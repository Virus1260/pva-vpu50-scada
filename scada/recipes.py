"""
PVA Systems VPU-50 SCADA - Recipe Execution Engine & Catalog Manager
Compliant with ISA-88 Batch Control and 21 CFR Part 11 Electronic Records.
"""

from __future__ import annotations

import json
import os
import time
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Optional


class DeviceType(str, Enum):
    AGITATOR = "agitator"
    HOMOGENIZER = "homogenizer"
    VACUUM = "vacuum"
    HEATER = "heater"
    COOLER = "cooler"
    FILL_VALVE = "fillValve"
    DRAIN_VALVE = "drainValve"


class StopConditionType(str, Enum):
    TIMER = "timer"
    LEVEL_BELOW = "level_below"
    LEVEL_ABOVE = "level_above"
    TEMP_ABOVE = "temp_above"
    TEMP_BELOW = "temp_below"
    MANUAL = "manual"
    VESSEL_EMPTY = "vessel_empty"


@dataclass
class StopCondition:
    type: StopConditionType
    value: float = 0.0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> StopCondition:
        cond_type = StopConditionType(data.get("type", "timer"))
        value = float(data.get("value", 0.0))
        return cls(type=cond_type, value=value)

    def to_dict(self) -> Dict[str, Any]:
        return {"type": self.type.value, "value": self.value}


@dataclass
class RecipeOperation:
    id: str
    device: DeviceType
    action: str = "on"  # on, off, ramp
    delay_seconds: int = 0
    duration_seconds: int = 0
    speed: Optional[float] = None
    ramp_from: Optional[float] = None
    ramp_to: Optional[float] = None
    temperature: Optional[float] = None
    level: Optional[float] = None
    stop_condition: Optional[StopCondition] = None

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> RecipeOperation:
        stop_cond = None
        if "stopCondition" in data and data["stopCondition"]:
            stop_cond = StopCondition.from_dict(data["stopCondition"])
        return cls(
            id=data.get("id", ""),
            device=DeviceType(data.get("device", "agitator")),
            action=data.get("action", "on"),
            delay_seconds=int(data.get("delaySeconds", 0)),
            duration_seconds=int(data.get("durationSeconds", 0)),
            speed=data.get("speed"),
            ramp_from=data.get("rampFrom"),
            ramp_to=data.get("rampTo"),
            temperature=data.get("temperature"),
            level=data.get("level"),
            stop_condition=stop_cond,
        )

    def to_dict(self) -> Dict[str, Any]:
        res: Dict[str, Any] = {
            "id": self.id,
            "device": self.device.value,
            "action": self.action,
            "delaySeconds": self.delay_seconds,
            "durationSeconds": self.duration_seconds,
        }
        if self.speed is not None:
            res["speed"] = self.speed
        if self.ramp_from is not None:
            res["rampFrom"] = self.ramp_from
        if self.ramp_to is not None:
            res["rampTo"] = self.ramp_to
        if self.temperature is not None:
            res["temperature"] = self.temperature
        if self.level is not None:
            res["level"] = self.level
        if self.stop_condition is not None:
            res["stopCondition"] = self.stop_condition.to_dict()
        return res


@dataclass
class RecipeStep:
    id: int
    name: str
    description: str
    operations: List[RecipeOperation] = field(default_factory=list)
    require_confirm: bool = False
    confirm_message: str = ""
    confirm_timeout: int = 0

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> RecipeStep:
        ops = [RecipeOperation.from_dict(op) for op in data.get("operations", [])]
        return cls(
            id=int(data.get("id", 1)),
            name=data.get("name", ""),
            description=data.get("description", ""),
            operations=ops,
            require_confirm=bool(data.get("requireConfirm", False)),
            confirm_message=data.get("confirmMessage", ""),
            confirm_timeout=int(data.get("confirmTimeout", 0)),
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "requireConfirm": self.require_confirm,
            "confirmMessage": self.confirm_message,
            "confirmTimeout": self.confirm_timeout,
            "operations": [op.to_dict() for op in self.operations],
        }


@dataclass
class Ingredient:
    sr: int
    name: str
    phase: str
    qty: str

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> Ingredient:
        return cls(
            sr=int(data.get("sr", 1)),
            name=data.get("name", ""),
            phase=data.get("phase", "A"),
            qty=data.get("qty", ""),
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "sr": self.sr,
            "name": self.name,
            "phase": self.phase,
            "qty": self.qty,
        }


@dataclass
class Recipe:
    id: str
    name: str
    version: str
    author: str
    approval_status: str
    created_at: str
    estimated_duration_sec: int
    batch_size_kg: float
    ingredients: List[Ingredient] = field(default_factory=list)
    steps: List[RecipeStep] = field(default_factory=list)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> Recipe:
        ingredients = [Ingredient.from_dict(ing) for ing in data.get("ingredients", [])]
        steps = [RecipeStep.from_dict(step) for step in data.get("steps", [])]
        return cls(
            id=data.get("id", "REC-001"),
            name=data.get("name", "Untitled Recipe"),
            version=data.get("version", "1.0.0"),
            author=data.get("author", "Operator"),
            approval_status=data.get("approvalStatus", "DRAFT"),
            created_at=data.get("createdAt", ""),
            estimated_duration_sec=int(data.get("estimatedDurationSec", 0)),
            batch_size_kg=float(data.get("batchSizeKg", 50.0)),
            ingredients=ingredients,
            steps=steps,
        )

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "version": self.version,
            "author": self.author,
            "approvalStatus": self.approval_status,
            "createdAt": self.created_at,
            "estimatedDurationSec": self.estimated_duration_sec,
            "batchSizeKg": self.batch_size_kg,
            "ingredients": [ing.to_dict() for ing in self.ingredients],
            "steps": [step.to_dict() for step in self.steps],
        }


class RecipeCatalog:
    """Manages the catalog of pre-made and user-created recipe templates."""

    def __init__(self, catalog_path: Optional[Path] = None):
        if catalog_path is None:
            catalog_path = Path(__file__).resolve().parent / "config" / "recipe_catalog.json"
        self.catalog_path = catalog_path
        self.recipes: Dict[str, Recipe] = {}
        self.load_catalog()

    def load_catalog(self) -> None:
        if self.catalog_path.exists():
            with open(self.catalog_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                for r_data in data.get("recipes", []):
                    recipe = Recipe.from_dict(r_data)
                    self.recipes[recipe.id] = recipe

    def get_recipe(self, recipe_id: str) -> Optional[Recipe]:
        return self.recipes.get(recipe_id)

    def list_recipes(self) -> List[Recipe]:
        return list(self.recipes.values())

    def save_recipe(self, recipe: Recipe) -> None:
        self.recipes[recipe.id] = recipe
        self.persist()

    def persist(self) -> None:
        data = {
            "catalogVersion": "3.0.0",
            "facility": "PVA Systems VPU-50 Pharmaceutical & Personal Care Mixing Skid",
            "compliance": "21 CFR Part 11 / GAMP-5 Compliant Recipe Matrix",
            "recipes": [r.to_dict() for r in self.recipes.values()],
        }
        with open(self.catalog_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)


@dataclass
class OperationRunState:
    op_id: str
    device: str
    action: str
    status: str  # waiting, delayed, running, done
    elapsed_sec: float
    remaining_sec: float
    total_duration: float
    current_speed: Optional[float] = None
    progress: float = 0.0


class RecipeExecutionEngine:
    """State machine executing ISA-88 recipe steps and sub-step operations."""

    def __init__(self, recipe: Optional[Recipe] = None):
        self.recipe: Optional[Recipe] = recipe
        self.is_running: bool = False
        self.is_paused: bool = False
        self.current_step_index: int = -1
        self.step_elapsed_sec: float = 0.0
        self.batch_elapsed_sec: float = 0.0
        self.manual_waiting: bool = False
        self.confirm_active: bool = False
        self.confirm_message: str = ""
        self.confirm_timeout: int = 0
        self.last_tick_time: Optional[float] = None

    def load_recipe(self, recipe: Recipe) -> None:
        self.recipe = recipe
        self.reset()

    def reset(self) -> None:
        self.is_running = False
        self.is_paused = False
        self.current_step_index = -1
        self.step_elapsed_sec = 0.0
        self.batch_elapsed_sec = 0.0
        self.manual_waiting = False
        self.confirm_active = False
        self.confirm_message = ""
        self.confirm_timeout = 0
        self.last_tick_time = None

    def start(self) -> bool:
        if not self.recipe or not self.recipe.steps:
            return False
        self.is_running = True
        self.is_paused = False
        self.current_step_index = 0
        self.step_elapsed_sec = 0.0
        self.batch_elapsed_sec = 0.0
        self.last_tick_time = time.time()
        self._check_step_confirmation()
        return True

    def pause(self) -> None:
        self.is_paused = True

    def resume(self) -> None:
        self.is_paused = False
        self.last_tick_time = time.time()

    def stop(self) -> None:
        self.is_running = False
        self.is_paused = False

    def confirm_hold_point(self, operator_id: str) -> bool:
        if self.confirm_active:
            self.confirm_active = False
            self.manual_waiting = False
            return True
        return False

    def _check_step_confirmation(self) -> None:
        if not self.recipe or self.current_step_index < 0 or self.current_step_index >= len(self.recipe.steps):
            return
        step = self.recipe.steps[self.current_step_index]
        if step.require_confirm:
            self.confirm_active = True
            self.manual_waiting = True
            self.confirm_message = step.confirm_message
            self.confirm_timeout = step.confirm_timeout

    def tick(self, dt: float, process_values: Optional[Dict[str, float]] = None) -> None:
        if not self.is_running or self.is_paused or self.confirm_active:
            return

        self.step_elapsed_sec += dt
        self.batch_elapsed_sec += dt

        if not self.recipe or self.current_step_index < 0 or self.current_step_index >= len(self.recipe.steps):
            return

        step = self.recipe.steps[self.current_step_index]
        
        # Check if all operations in the step are complete
        all_done = True
        for op in step.operations:
            op_total = op.delay_seconds + op.duration_seconds
            if op.stop_condition and op.stop_condition.type == StopConditionType.TIMER:
                if self.step_elapsed_sec < op_total:
                    all_done = False
            elif op.stop_condition and process_values:
                # Process condition checks
                cond = op.stop_condition
                if cond.type == StopConditionType.TEMP_ABOVE:
                    pv_temp = process_values.get("vessel_temp", 0.0)
                    if pv_temp < cond.value / 10.0:
                        all_done = False
                elif cond.type == StopConditionType.TEMP_BELOW:
                    pv_temp = process_values.get("vessel_temp", 100.0)
                    if pv_temp > cond.value / 10.0:
                        all_done = False
                elif cond.type == StopConditionType.LEVEL_ABOVE:
                    pv_level = process_values.get("tank_level", 0.0)
                    if pv_level < cond.value:
                        all_done = False
            elif self.step_elapsed_sec < op_total:
                all_done = False

        if all_done and (len(step.operations) > 0 or self.step_elapsed_sec >= 5.0):
            # Advance to next step
            self.current_step_index += 1
            self.step_elapsed_sec = 0.0
            if self.current_step_index >= len(self.recipe.steps):
                # Batch finished!
                self.is_running = False
            else:
                self._check_step_confirmation()

    def get_execution_snapshot(self) -> Dict[str, Any]:
        if not self.recipe or self.current_step_index < 0:
            return {
                "recipeLoaded": False,
                "recipeName": "",
                "totalSteps": 0,
                "currentStepIndex": -1,
                "currentStepName": "",
                "stepTimerSec": 0,
                "batchTimerSec": 0,
                "manualWaiting": False,
                "confirmActive": False,
                "confirmMessage": "",
                "confirmTimeout": 0,
                "operations": [],
            }

        step = (
            self.recipe.steps[self.current_step_index]
            if self.current_step_index < len(self.recipe.steps)
            else None
        )
        step_name = step.name if step else "COMPLETE"
        
        op_states: List[Dict[str, Any]] = []
        if step:
            for op in step.operations:
                op_total = op.delay_seconds + op.duration_seconds
                op_elapsed = max(0.0, self.step_elapsed_sec - op.delay_seconds)
                remaining = max(0.0, op.duration_seconds - op_elapsed)
                
                status = "waiting"
                if self.step_elapsed_sec < op.delay_seconds:
                    status = "delayed"
                elif op_elapsed >= op.duration_seconds and op.duration_seconds > 0:
                    status = "done"
                else:
                    status = "running"

                progress = 1.0
                if op.duration_seconds > 0:
                    progress = min(1.0, op_elapsed / op.duration_seconds)

                op_states.append({
                    "opId": op.id,
                    "device": op.device.value,
                    "action": op.action,
                    "status": status,
                    "elapsedSec": op_elapsed,
                    "remainingSec": remaining,
                    "totalDuration": op.duration_seconds,
                    "currentSpeed": op.speed,
                    "progress": progress,
                })

        # Calculate BOM ingredient phase statuses (pending / active / done)
        ingredient_statuses: List[Dict[str, Any]] = []
        if self.recipe and self.recipe.ingredients:
            total_steps = max(1, len(self.recipe.steps))
            progress_ratio = max(0.0, float(self.current_step_index) / float(total_steps))
            for ing in self.recipe.ingredients:
                p = ing.phase.upper()
                st = "pending"
                if p == "A":
                    st = "done" if progress_ratio >= 0.2 else "active"
                elif p == "B":
                    st = "done" if progress_ratio >= 0.4 else ("active" if progress_ratio >= 0.2 else "pending")
                elif p == "C":
                    st = "done" if progress_ratio >= 0.65 else ("active" if progress_ratio >= 0.4 else "pending")
                elif p == "D":
                    st = "done" if progress_ratio >= 0.8 else ("active" if progress_ratio >= 0.65 else "pending")
                elif p == "E":
                    st = "done" if progress_ratio >= 0.9 else ("active" if progress_ratio >= 0.8 else "pending")
                elif p == "F":
                    st = "done" if progress_ratio >= 1.0 else ("active" if progress_ratio >= 0.9 else "pending")
                ingredient_statuses.append({
                    "sr": ing.sr,
                    "name": ing.name,
                    "phase": ing.phase,
                    "qty": ing.qty,
                    "status": st,
                })

        return {
            "recipeLoaded": True,
            "recipeName": self.recipe.name,
            "totalSteps": len(self.recipe.steps),
            "currentStepIndex": self.current_step_index,
            "currentStepName": step_name,
            "stepTimerSec": int(self.step_elapsed_sec),
            "batchTimerSec": int(self.batch_elapsed_sec),
            "manualWaiting": self.manual_waiting,
            "confirmActive": self.confirm_active,
            "confirmMessage": self.confirm_message,
            "confirmTimeout": self.confirm_timeout,
            "operations": op_states,
            "ingredients": ingredient_statuses,
        }

    def move_step(self, step_id: int, direction: int) -> bool:
        """Moves a step up (-1) or down (+1) in the sequence."""
        if not self.recipe:
            return False
        idx = next((i for i, s in enumerate(self.recipe.steps) if s.id == step_id), -1)
        target_idx = idx + direction
        if idx < 0 or target_idx < 0 or target_idx >= len(self.recipe.steps):
            return False
        self.recipe.steps[idx], self.recipe.steps[target_idx] = (
            self.recipe.steps[target_idx],
            self.recipe.steps[idx],
        )
        return True

    def add_step(self, name: str, description: str = "") -> RecipeStep:
        """Adds a new parent step with auto-incremented ID."""
        if not self.recipe:
            self.recipe = Recipe(
                id="REC-NEW",
                name="New Recipe",
                version="1.0.0",
                author="Operator",
                approval_status="DRAFT",
                created_at="",
                estimated_duration_sec=0,
                batch_size_kg=50.0,
            )
        new_id = max([s.id for s in self.recipe.steps], default=0) + 1
        new_step = RecipeStep(id=new_id, name=name, description=description)
        self.recipe.steps.append(new_step)
        return new_step

    def remove_step(self, step_id: int) -> bool:
        """Removes a parent step by ID."""
        if not self.recipe:
            return False
        initial_len = len(self.recipe.steps)
        self.recipe.steps = [s for s in self.recipe.steps if s.id != step_id]
        return len(self.recipe.steps) < initial_len

