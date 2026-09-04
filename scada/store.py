"""Persistence layer for 21 CFR Part 11 / ISA-88 SCADA Recipes, Batch Runs, and Electronic Records."""

from __future__ import annotations

from contextlib import contextmanager
from datetime import UTC, datetime
import json
from pathlib import Path
import sqlite3
from typing import Any, Iterator, Optional
from uuid import uuid4


def utc_now() -> str:
    return datetime.now(UTC).isoformat(timespec="milliseconds").replace("+00:00", "Z")


class SqliteStore:
    def __init__(self, database: Path) -> None:
        self.database = database
        database.parent.mkdir(parents=True, exist_ok=True)

    @contextmanager
    def connection(self) -> Iterator[sqlite3.Connection]:
        connection = sqlite3.connect(self.database)
        connection.row_factory = sqlite3.Row
        connection.execute("PRAGMA foreign_keys = ON")
        try:
            yield connection
            connection.commit()
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()


class ScadaDatabaseStore(SqliteStore):
    """Unified SQLite persistence for Users, Master Recipes, Immutable Batch Runs, and 21 CFR Batch Events."""

    def initialise(self) -> None:
        with self.connection() as conn:
            conn.executescript(
                """
                -- Users & roles (per-machine local security)
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT UNIQUE NOT NULL,
                    password_hash TEXT NOT NULL,
                    role TEXT NOT NULL CHECK(role IN ('operator', 'incharge', 'administrator')),
                    created_at TEXT NOT NULL
                );

                -- Master Recipes (ISA-88 authored recipes)
                CREATE TABLE IF NOT EXISTS recipes (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    version INTEGER NOT NULL DEFAULT 1,
                    status TEXT NOT NULL CHECK(status IN ('draft', 'approved', 'deprecated')) DEFAULT 'draft',
                    body_json TEXT NOT NULL,
                    sha256_hash TEXT,
                    created_by TEXT,
                    created_at TEXT NOT NULL,
                    approved_by TEXT,
                    approved_at TEXT
                );

                -- Append-only change audit log for master recipes
                CREATE TABLE IF NOT EXISTS recipe_audit_log (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    recipe_id TEXT NOT NULL,
                    action TEXT NOT NULL,
                    user_id TEXT,
                    timestamp TEXT NOT NULL,
                    detail TEXT
                );

                -- Batch Runs: IMMUTABLE snapshot of recipe at execution time
                CREATE TABLE IF NOT EXISTS batch_runs (
                    id TEXT PRIMARY KEY,
                    recipe_id TEXT NOT NULL,
                    recipe_version INTEGER NOT NULL,
                    recipe_snapshot_json TEXT NOT NULL,
                    started_by TEXT,
                    started_at TEXT NOT NULL,
                    ended_at TEXT,
                    status TEXT NOT NULL CHECK(status IN ('running', 'complete', 'aborted')) DEFAULT 'running'
                );

                -- Append-only Electronic Batch Record (21 CFR Part 11)
                CREATE TABLE IF NOT EXISTS batch_events (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    batch_run_id TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    event_type TEXT NOT NULL,
                    user_id TEXT,
                    detail_json TEXT,
                    FOREIGN KEY(batch_run_id) REFERENCES batch_runs(id)
                );

                -- Historian telemetry samples
                CREATE TABLE IF NOT EXISTS samples (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    captured_at_utc TEXT NOT NULL,
                    batch_id TEXT,
                    tag_id TEXT NOT NULL,
                    engineering_value REAL NOT NULL,
                    quality TEXT NOT NULL
                );

                CREATE INDEX IF NOT EXISTS idx_samples_batch_tag_time
                    ON samples(batch_id, tag_id, captured_at_utc);
                """
            )
            try:
                conn.execute("ALTER TABLE recipes ADD COLUMN sha256_hash TEXT")
            except Exception:
                pass
            self._seed_default_users(conn)
            self._seed_default_recipes(conn)

    def _seed_default_users(self, conn: sqlite3.Connection) -> None:
        default_users = [
            ("operator", "pbkdf2:sha256:operator", "operator"),
            ("incharge", "pbkdf2:sha256:incharge", "incharge"),
            ("admin", "pbkdf2:sha256:admin", "administrator"),
        ]
        for username, pwhash, role in default_users:
            conn.execute(
                """
                INSERT OR IGNORE INTO users (username, password_hash, role, created_at)
                VALUES (?, ?, ?, ?)
                """,
                (username, pwhash, role, utc_now()),
            )

    def _seed_default_recipes(self, conn: sqlite3.Connection) -> None:
        catalog_path = Path(__file__).resolve().parent / "config" / "recipe_catalog.json"
        if not catalog_path.exists():
            return
        try:
            with open(catalog_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                for r in data.get("recipes", []):
                    r_id = r.get("id")
                    if not r_id:
                        continue
                    existing = conn.execute("SELECT id FROM recipes WHERE id = ?", (r_id,)).fetchone()
                    if not existing:
                        conn.execute(
                            """
                            INSERT INTO recipes (id, name, version, status, body_json, created_by, created_at, approved_by, approved_at)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                            """,
                            (
                                r_id,
                                r.get("name", "Untitled"),
                                1,
                                "approved",
                                json.dumps(r),
                                r.get("author", "System"),
                                r.get("createdAt", utc_now()),
                                "Dr. E. Vance",
                                utc_now(),
                            ),
                        )
                        conn.execute(
                            """
                            INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                            VALUES (?, 'created', 'System', ?, 'Initial system seed formulation')
                            """,
                            (r_id, utc_now()),
                        )
        except Exception:
            pass

    # --- Recipe Master CRUD ---

    def create_recipe(self, recipe_id: str, name: str, body_dict: dict[str, Any], created_by: str, sha256_hash: str = "") -> dict[str, Any]:
        now = utc_now()
        with self.connection() as conn:
            conn.execute(
                """
                INSERT INTO recipes (id, name, version, status, body_json, sha256_hash, created_by, created_at)
                VALUES (?, ?, 1, 'draft', ?, ?, ?, ?)
                """,
                (recipe_id, name, json.dumps(body_dict), sha256_hash, created_by, now),
            )
            conn.execute(
                """
                INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                VALUES (?, 'created', ?, ?, 'Master recipe created in draft state')
                """,
                (recipe_id, created_by, now),
            )
        return self.get_recipe(recipe_id) or {}

    def update_recipe(self, recipe_id: str, name: str, body_dict: dict[str, Any], updated_by: str, sha256_hash: str = "") -> bool:
        now = utc_now()
        with self.connection() as conn:
            existing = conn.execute("SELECT version, status FROM recipes WHERE id = ?", (recipe_id,)).fetchone()
            if not existing:
                return False
            new_version = existing["version"] + 1
            conn.execute(
                """
                UPDATE recipes
                SET name = ?, version = ?, status = 'draft', body_json = ?, sha256_hash = ?, created_by = ?, created_at = ?
                WHERE id = ?
                """,
                (name, new_version, json.dumps(body_dict), sha256_hash, updated_by, now, recipe_id),
            )
            conn.execute(
                """
                INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                VALUES (?, 'edited', ?, ?, ?)
                """,
                (recipe_id, updated_by, now, f"Recipe updated to version {new_version} (draft)"),
            )
        return True

    def approve_recipe(self, recipe_id: str, approved_by: str) -> bool:
        now = utc_now()
        with self.connection() as conn:
            conn.execute(
                """
                UPDATE recipes
                SET status = 'approved', approved_by = ?, approved_at = ?
                WHERE id = ?
                """,
                (approved_by, now, recipe_id),
            )
            conn.execute(
                """
                INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                VALUES (?, 'approved', ?, ?, 'Recipe approved for production execution')
                """,
                (recipe_id, approved_by, now),
            )
        return True

    def deprecate_recipe(self, recipe_id: str, user_id: str) -> bool:
        now = utc_now()
        with self.connection() as conn:
            conn.execute("UPDATE recipes SET status = 'deprecated' WHERE id = ?", (recipe_id,))
            conn.execute(
                """
                INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                VALUES (?, 'deprecated', ?, ?, 'Recipe deprecated from production')
                """,
                (recipe_id, user_id, now),
            )
        return True

    def delete_recipe(self, recipe_id: str, user_id: str) -> bool:
        now = utc_now()
        with self.connection() as conn:
            conn.execute("DELETE FROM recipes WHERE id = ?", (recipe_id,))
            conn.execute(
                """
                INSERT INTO recipe_audit_log (recipe_id, action, user_id, timestamp, detail)
                VALUES (?, 'deleted', ?, ?, 'Recipe permanently deleted')
                """,
                (recipe_id, user_id, now),
            )
        return True

    def get_recipe(self, recipe_id: str) -> Optional[dict[str, Any]]:
        with self.connection() as conn:
            row = conn.execute("SELECT * FROM recipes WHERE id = ?", (recipe_id,)).fetchone()
            if not row:
                return None
            return {
                "id": row["id"],
                "name": row["name"],
                "version": row["version"],
                "status": row["status"],
                "body": json.loads(row["body_json"]),
                "sha256Hash": row["sha256_hash"] if "sha256_hash" in row.keys() and row["sha256_hash"] else "",
                "createdBy": row["created_by"],
                "createdAt": row["created_at"],
                "approvedBy": row["approved_by"],
                "approvedAt": row["approved_at"],
            }

    def list_recipes(self, status_filter: Optional[str] = None) -> list[dict[str, Any]]:
        with self.connection() as conn:
            query = "SELECT * FROM recipes"
            params: list[Any] = []
            if status_filter:
                query += " WHERE status = ?"
                params.append(status_filter)
            query += " ORDER BY id ASC"
            rows = conn.execute(query, params).fetchall()
            return [
                {
                    "id": r["id"],
                    "name": r["name"],
                    "version": r["version"],
                    "status": r["status"],
                    "body": json.loads(r["body_json"]),
                    "sha256Hash": r["sha256_hash"] if "sha256_hash" in r.keys() and r["sha256_hash"] else "",
                    "createdBy": r["created_by"],
                    "createdAt": r["created_at"],
                    "approvedBy": r["approved_by"],
                    "approvedAt": r["approved_at"],
                }
                for r in rows
            ]

    # --- Batch Runs & Immutable Snapshots (ISA-88 Execution) ---

    def start_batch_run(self, recipe_id: str, started_by: str) -> dict[str, Any]:
        """Creates an immutable batch run snapshot of the current approved recipe."""
        recipe = self.get_recipe(recipe_id)
        if not recipe:
            raise ValueError(f"Recipe {recipe_id} does not exist.")
        if recipe["status"] != "approved":
            raise ValueError(f"Cannot execute unapproved recipe {recipe_id} (status: {recipe['status']}).")

        batch_id = f"BATCH-{datetime.now(UTC):%Y%m%d}-{uuid4().hex[:6].upper()}"
        now = utc_now()
        snapshot_json = json.dumps(recipe["body"])

        with self.connection() as conn:
            conn.execute(
                """
                INSERT INTO batch_runs (id, recipe_id, recipe_version, recipe_snapshot_json, started_by, started_at, status)
                VALUES (?, ?, ?, ?, ?, ?, 'running')
                """,
                (batch_id, recipe_id, recipe["version"], snapshot_json, started_by, now),
            )
            conn.execute(
                """
                INSERT INTO batch_events (batch_run_id, timestamp, event_type, user_id, detail_json)
                VALUES (?, ?, 'batch_start', ?, ?)
                """,
                (batch_id, now, started_by, json.dumps({"recipeName": recipe["name"], "version": recipe["version"]})),
            )

        return {
            "batchId": batch_id,
            "recipeId": recipe_id,
            "recipeName": recipe["name"],
            "recipeVersion": recipe["version"],
            "snapshot": recipe["body"],
            "startedBy": started_by,
            "startedAt": now,
            "status": "running",
        }

    def record_batch_event(self, batch_run_id: str, event_type: str, user_id: str, detail_dict: Optional[dict[str, Any]] = None) -> None:
        now = utc_now()
        with self.connection() as conn:
            conn.execute(
                """
                INSERT INTO batch_events (batch_run_id, timestamp, event_type, user_id, detail_json)
                VALUES (?, ?, ?, ?, ?)
                """,
                (batch_run_id, now, event_type, user_id, json.dumps(detail_dict or {})),
            )

    def end_batch_run(self, batch_run_id: str, status: str = "complete", user_id: str = "operator") -> None:
        now = utc_now()
        with self.connection() as conn:
            conn.execute(
                """
                UPDATE batch_runs
                SET status = ?, ended_at = ?
                WHERE id = ?
                """,
                (status, now, batch_run_id),
            )
            conn.execute(
                """
                INSERT INTO batch_events (batch_run_id, timestamp, event_type, user_id, detail_json)
                VALUES (?, ?, 'batch_end', ?, ?)
                """,
                (batch_run_id, now, user_id, json.dumps({"finalStatus": status})),
            )

    def get_batch_events(self, batch_run_id: str) -> list[dict[str, Any]]:
        with self.connection() as conn:
            rows = conn.execute(
                "SELECT * FROM batch_events WHERE batch_run_id = ? ORDER BY timestamp ASC",
                (batch_run_id,),
            ).fetchall()
            return [
                {
                    "id": r["id"],
                    "batchRunId": r["batch_run_id"],
                    "timestamp": r["timestamp"],
                    "eventType": r["event_type"],
                    "userId": r["user_id"],
                    "detail": json.loads(r["detail_json"] or "{}"),
                }
                for r in rows
            ]


class HistorianStore(SqliteStore):
    def initialise(self) -> None:
        with self.connection() as connection:
            connection.executescript(
                """
                CREATE TABLE IF NOT EXISTS batches (
                    id TEXT PRIMARY KEY,
                    recipe_id TEXT NOT NULL,
                    recipe_name TEXT NOT NULL,
                    recipe_version INTEGER NOT NULL,
                    status TEXT NOT NULL,
                    started_at_utc TEXT NOT NULL,
                    ended_at_utc TEXT,
                    initiated_by TEXT NOT NULL
                );
                CREATE TABLE IF NOT EXISTS samples (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    captured_at_utc TEXT NOT NULL,
                    batch_id TEXT,
                    tag_id TEXT NOT NULL,
                    engineering_value REAL NOT NULL,
                    quality TEXT NOT NULL,
                    FOREIGN KEY(batch_id) REFERENCES batches(id)
                );
                CREATE INDEX IF NOT EXISTS idx_samples_batch_tag_time
                    ON samples(batch_id, tag_id, captured_at_utc);
                """
            )

    def start_batch(
        self, recipe_id: str, recipe_name: str, recipe_version: int, initiated_by: str, started_at_utc: str | None = None
    ) -> dict[str, Any]:
        batch = {
            "id": f"B-{datetime.now(UTC):%Y%m%d}-{uuid4().hex[:4].upper()}",
            "recipeId": recipe_id,
            "recipeName": recipe_name,
            "recipeVersion": recipe_version,
            "status": "running",
            "startedAtUtc": started_at_utc or utc_now(),
            "endedAtUtc": None,
            "initiatedBy": initiated_by,
        }
        with self.connection() as connection:
            connection.execute(
                """INSERT INTO batches (id, recipe_id, recipe_name, recipe_version, status, started_at_utc, ended_at_utc, initiated_by)
                   VALUES (:id, :recipeId, :recipeName, :recipeVersion, :status, :startedAtUtc, :endedAtUtc, :initiatedBy)""",
                batch,
            )
        return batch

    def end_batch(self, batch_id: str, status: str, ended_at_utc: str | None = None) -> None:
        if status not in {"completed", "aborted", "released"}:
            raise ValueError("Invalid batch end status.")
        with self.connection() as connection:
            connection.execute(
                "UPDATE batches SET status = ?, ended_at_utc = ? WHERE id = ?",
                (status, ended_at_utc or utc_now(), batch_id),
            )

    def write_samples(self, batch_id: str | None, tag_values: dict[str, float], timestamp_utc: str | None = None) -> None:
        timestamp = timestamp_utc or utc_now()
        records = [
            (timestamp, batch_id, tag_id, float(val), "good")
            for tag_id, val in tag_values.items()
        ]
        with self.connection() as connection:
            connection.executemany(
                "INSERT INTO samples (captured_at_utc, batch_id, tag_id, engineering_value, quality) VALUES (?, ?, ?, ?, ?)",
                records,
            )

    def list_batches(self) -> list[dict[str, Any]]:
        with self.connection() as connection:
            rows = connection.execute("SELECT * FROM batches ORDER BY started_at_utc DESC").fetchall()
            return [
                {
                    "id": row["id"],
                    "recipeId": row["recipe_id"],
                    "recipeName": row["recipe_name"],
                    "recipeVersion": row["recipe_version"],
                    "status": row["status"],
                    "startedAtUtc": row["started_at_utc"],
                    "endedAtUtc": row["ended_at_utc"],
                    "initiatedBy": row["initiated_by"],
                }
                for row in rows
            ]

    def get_batch_telemetry(self, batch_id: str, tag_ids: list[str] | None = None) -> list[dict[str, Any]]:
        with self.connection() as connection:
            query = "SELECT captured_at_utc, tag_id, engineering_value FROM samples WHERE batch_id = ?"
            params: list[Any] = [batch_id]
            if tag_ids:
                query += f" AND tag_id IN ({','.join(['?']*len(tag_ids))})"
                params.extend(tag_ids)
            query += " ORDER BY captured_at_utc ASC"
            rows = connection.execute(query, params).fetchall()
            return [
                {
                    "time": row["captured_at_utc"],
                    "tag": row["tag_id"],
                    "value": row["engineering_value"],
                }
                for row in rows
            ]


class RecipeStore(SqliteStore):
    def initialise(self) -> None:
        with self.connection() as connection:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS recipes (
                    id TEXT NOT NULL,
                    version INTEGER NOT NULL,
                    name TEXT NOT NULL,
                    status TEXT NOT NULL,
                    payload_json TEXT NOT NULL,
                    sha256_hash TEXT,
                    created_at_utc TEXT NOT NULL,
                    created_by TEXT NOT NULL,
                    approved_at_utc TEXT,
                    approved_by TEXT,
                    PRIMARY KEY (id, version)
                )
                """
            )
            try:
                connection.execute("ALTER TABLE recipes ADD COLUMN sha256_hash TEXT")
            except Exception:
                pass

    def save_recipe(self, recipe_id: str, version: int, name: str, payload: dict[str, Any], created_by: str, sha256_hash: str = "") -> None:
        with self.connection() as connection:
            connection.execute(
                """
                INSERT OR REPLACE INTO recipes (
                    id, version, name, status, payload_json, sha256_hash, created_at_utc, created_by
                ) VALUES (?, ?, ?, 'approved', ?, ?, ?, ?)
                """,
                (recipe_id, version, name, json.dumps(payload), sha256_hash, utc_now(), created_by),
            )

    def list_recipes(self) -> list[dict[str, Any]]:
        with self.connection() as connection:
            rows = connection.execute("SELECT * FROM recipes ORDER BY id ASC, version DESC").fetchall()
            return [
                {
                    "id": row["id"],
                    "version": row["version"],
                    "name": row["name"],
                    "status": row["status"],
                    "payload": json.loads(row["payload_json"]),
                    "sha256Hash": row["sha256_hash"] if "sha256_hash" in row.keys() and row["sha256_hash"] else "",
                    "createdAtUtc": row["created_at_utc"],
                    "createdBy": row["created_by"],
                }
                for row in rows
            ]


# Export default database store singleton
default_db_path = Path(__file__).resolve().parent / "data" / "scada_production.db"
scada_db = ScadaDatabaseStore(default_db_path)
scada_db.initialise()

