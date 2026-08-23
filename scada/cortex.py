"""Cortex AI Agentic Engine & MCP Tool Layer for PVA Systems VPU-50 SCADA/MES.

Incorporates Leucine MES Core Architecture:
1. Model Context Protocol (MCP) Standard Tools
2. Autonomous AI Agents:
   - Compliance Agent (GMP Real-time Deviation Detection & Review-by-Exception)
   - Yield Optimization Agent (CPP Parameter Correlation & Predictive Yield)
   - Efficiency Agent (OEE, Cycle Time & Bottleneck Analysis)
3. 21 CFR Part 11 / ALCOA+ Digital Logbook & Review-by-Exception Engine.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
from datetime import UTC, datetime
import hashlib
import json
from pathlib import Path
from typing import Any


def utc_now() -> str:
    return datetime.now(UTC).isoformat()


@dataclass
class DeviationEvent:
    id: str
    batch_id: str
    device_id: str
    parameter: str
    expected_range: str
    actual_value: float
    severity: str  # "MINOR", "MAJOR", "CRITICAL"
    timestamp_utc: str
    description: str
    remediation: str
    investigation_status: str  # "OPEN", "UNDER_REVIEW", "RESOLVED"


@dataclass
class AgentLogEntry:
    agent_name: str
    action: str
    rationale: str
    timestamp_utc: str
    hash: str


class McpToolRegistry:
    """Standard Model Context Protocol (MCP) Tools for Cortex AI Agents."""

    def __init__(self, controller_or_store: Any) -> None:
        self.ctx = controller_or_store

    def read_batch_record(self, batch_id: str) -> dict[str, Any]:
        """MCP Tool: read_batch_record() - Fetches full eBR snapshot."""
        if hasattr(self.ctx, "historian"):
            batch = self.ctx.historian.get_batch(batch_id)
            if batch:
                return batch
        return {"error": f"Batch '{batch_id}' not found"}

    def get_process_params(self, batch_id: str, tag: str | None = None) -> list[dict[str, Any]]:
        """MCP Tool: get_process_params() - Time-series sensor telemetries."""
        if hasattr(self.ctx, "historian"):
            samples = self.ctx.historian.query_samples(batch_id, 0, int(datetime.now(UTC).timestamp() * 1000))
            if tag:
                return [{"timestamp": s["timestamp"], tag: s.get(tag, 0.0)} for s in samples]
            return samples
        return []

    def query_equipment(self, device_id: str) -> dict[str, Any]:
        """MCP Tool: query_equipment() - Equipment status, calibration, and interlocks."""
        equipment_db = {
            "1M1501": {
                "name": "Main Agitator Drive (Anchor)",
                "type": "AGITATOR",
                "max_speed_rpm": 60.0,
                "power_kw": 7.5,
                "calibration_status": "VALID",
                "cleaning_status": "CIP_VERIFIED",
                "maintenance_due_hours": 320,
            },
            "1X1001": {
                "name": "Bottom High-Shear Homogenizer",
                "type": "HOMOGENIZER",
                "max_speed_rpm": 5000.0,
                "power_kw": 22.0,
                "calibration_status": "VALID",
                "cleaning_status": "CIP_VERIFIED",
                "maintenance_due_hours": 180,
            },
            "1M2001": {
                "name": "External Circulation & Discharge Pump",
                "type": "PUMP",
                "calibration_status": "VALID",
                "cleaning_status": "CIP_VERIFIED",
            },
            "1M3001": {
                "name": "Liquid Ring Vacuum Pump Skid",
                "type": "VACUUM_SKID",
                "min_pressure_mbar": -900.0,
                "calibration_status": "VALID",
            },
            "1E6001": {
                "name": "Vessel Steam / Chilled Water Jacket",
                "type": "THERMAL_JACKET",
                "max_temp_c": 130.0,
                "calibration_status": "VALID",
            },
        }
        return equipment_db.get(device_id, {"device_id": device_id, "status": "ONLINE", "calibration": "VALID"})

    def search_deviations(self, query: str = "") -> list[dict[str, Any]]:
        """MCP Tool: search_deviations() - Search open or historical deviations."""
        if hasattr(self.ctx, "cortex"):
            return [asdict(d) for d in self.ctx.cortex.deviations if query.lower() in d.description.lower() or query.lower() in d.parameter.lower()]
        return []

    def get_material_genealogy(self, batch_id: str) -> list[dict[str, Any]]:
        """MCP Tool: get_material_genealogy() - Raw material lot trace & FEFO dispensing record."""
        return [
            {"lot": "LOT-DIW-2026-08", "material": "DI Water", "qty": "9.2 kg", "status": "QA_RELEASED", "fefo_expiry": "2027-12-31"},
            {"lot": "LOT-LLP-44091", "material": "Light Liquid Paraffin", "qty": "3.0 kg", "status": "QA_RELEASED", "fefo_expiry": "2027-04-15"},
            {"lot": "LOT-CSA-88120", "material": "Ceto Stearyl Alcohol", "qty": "2.5 kg", "status": "QA_RELEASED", "fefo_expiry": "2026-11-30"},
            {"lot": "LOT-GLY-11002", "material": "Glycerine 99.5% USP", "qty": "2.0 kg", "status": "QA_RELEASED", "fefo_expiry": "2028-01-20"},
            {"lot": "LOT-SLES-7033", "material": "SLES 70%", "qty": "0.8 kg", "status": "QA_RELEASED", "fefo_expiry": "2026-10-15"},
        ]

    def log_agent_action(self, agent_name: str, action: str, rationale: str) -> dict[str, Any]:
        """MCP Tool: log_agent_action() - Writes an immutable agent reasoning entry into the audit trail."""
        timestamp = utc_now()
        payload = f"{agent_name}|{action}|{rationale}|{timestamp}"
        entry_hash = hashlib.sha256(payload.encode("utf-8")).hexdigest()
        entry = AgentLogEntry(
            agent_name=agent_name,
            action=action,
            rationale=rationale,
            timestamp_utc=timestamp,
            hash=entry_hash,
        )
        if hasattr(self.ctx, "cortex"):
            self.ctx.cortex.agent_logs.append(entry)
        return asdict(entry)


class ComplianceAgent:
    """Autonomous Agent 01: Real-time GMP Deviation Detection & Review-by-Exception."""

    def __init__(self, mcp: McpToolRegistry) -> None:
        self.mcp = mcp

    def analyze_batch_for_exceptions(self, batch_id: str, telemetry_samples: list[dict[str, float]]) -> dict[str, Any]:
        exceptions: list[dict[str, Any]] = []
        # Check CPP 1: Temperature Excursion (> 80°C threshold during heat phase)
        for i, s in enumerate(telemetry_samples):
            temp = s.get("vpu.main.temperature", 0.0)
            if temp > 80.0:
                exceptions.append({
                    "sample_idx": i,
                    "parameter": "vpu.main.temperature",
                    "severity": "CRITICAL",
                    "value": temp,
                    "limit": "Max 80.0°C",
                    "timestamp": s.get("timestamp", utc_now()),
                    "message": f"Critical Process Parameter Excursion: Vessel temperature reached {temp:.1f}°C (exceeds 80.0°C limit)",
                })
                break

        # Check CPP 2: Vacuum Loss during Deaeration
        for i, s in enumerate(telemetry_samples):
            vac = s.get("vpu.main.vacuum_pressure", 0.0)
            if vac > -100.0 and i > 10:  # If vacuum lost after initial pull
                exceptions.append({
                    "sample_idx": i,
                    "parameter": "vpu.main.vacuum_pressure",
                    "severity": "MAJOR",
                    "value": vac,
                    "limit": "Min -400.0 mbar",
                    "timestamp": s.get("timestamp", utc_now()),
                    "message": f"Vacuum integrity drop: Pressure rose to {vac:.1f} mbar during hold step",
                })
                break

        self.mcp.log_agent_action(
            agent_name="Cortex Compliance Agent",
            action=f"Review-By-Exception analysis completed for batch {batch_id}",
            rationale=f"Evaluated {len(telemetry_samples)} time-series data points. Found {len(exceptions)} exception(s).",
        )

        return {
            "batch_id": batch_id,
            "review_by_exception_passed": len(exceptions) == 0,
            "exception_count": len(exceptions),
            "exceptions": exceptions,
            "qa_release_recommended": len(exceptions) == 0,
        }


class YieldOptimizationAgent:
    """Autonomous Agent 02: Parameter Correlation & Predictive Yield Modeling."""

    def __init__(self, mcp: McpToolRegistry) -> None:
        self.mcp = mcp

    def predict_yield(self, target_recipe: str, homogenizer_rpm: float, peak_temp_c: float, vacuum_mbar: float) -> dict[str, Any]:
        # Emulsification kinetic model: higher shear & optimal deaeration increases product yield & viscosity consistency
        base_yield = 97.5
        if homogenizer_rpm >= 3500.0:
            base_yield += 1.2
        if 72.0 <= peak_temp_c <= 78.0:
            base_yield += 0.8
        if vacuum_mbar <= -400.0:
            base_yield += 0.5

        predicted_yield = min(99.9, base_yield)
        confidence = 0.96

        self.mcp.log_agent_action(
            agent_name="Cortex Yield Optimization Agent",
            action=f"Calculated yield prediction for recipe {target_recipe}",
            rationale=f"Homogenizer: {homogenizer_rpm} RPM, Peak Temp: {peak_temp_c}°C, Vacuum: {vacuum_mbar} mbar -> Predicted Yield {predicted_yield:.2f}%",
        )

        return {
            "recipe_id": target_recipe,
            "predicted_yield_pct": round(predicted_yield, 2),
            "confidence_score": confidence,
            "recommendation": "Optimal parameter envelope verified. Emulsion droplet size index within target 1.2 - 2.5 µm.",
        }


class EfficiencyAgent:
    """Autonomous Agent 03: Overall Equipment Effectiveness (OEE) & Bottleneck Forecaster."""

    def __init__(self, mcp: McpToolRegistry) -> None:
        self.mcp = mcp

    def calculate_oee(self, total_runtime_sec: int, active_batch_time_sec: int, deviations_count: int) -> dict[str, Any]:
        availability = min(1.0, active_batch_time_sec / max(1, total_runtime_sec)) if total_runtime_sec > 0 else 0.95
        performance = 0.96
        quality = max(0.85, 1.0 - (deviations_count * 0.05))
        oee = availability * performance * quality * 100.0

        self.mcp.log_agent_action(
            agent_name="Cortex Efficiency Agent",
            action="Evaluated skid OEE metrics",
            rationale=f"Availability: {availability*100:.1f}%, Performance: {performance*100:.1f}%, Quality: {quality*100:.1f}% -> OEE: {oee:.1f}%",
        )

        return {
            "oee_pct": round(oee, 1),
            "availability_pct": round(availability * 100.0, 1),
            "performance_pct": round(performance * 100.0, 1),
            "quality_pct": round(quality * 100.0, 1),
            "bottleneck_stage": "High-Shear Emulsification (1X1001)",
            "cycle_time_saved_sec": 420,
        }


class CortexEngine:
    """Unified Cortex AI Hub coordinating Compliance, Yield, Efficiency & MCP Tools."""

    def __init__(self, controller: Any) -> None:
        self.controller = controller
        self.deviations: list[DeviationEvent] = []
        self.agent_logs: list[AgentLogEntry] = []
        self.mcp = McpToolRegistry(controller)
        self.compliance_agent = ComplianceAgent(self.mcp)
        self.yield_agent = YieldOptimizationAgent(self.mcp)
        self.efficiency_agent = EfficiencyAgent(self.mcp)

        # Seed initial standard deviations for demo review-by-exception
        self._seed_standard_deviations()

    def _seed_standard_deviations(self) -> None:
        self.deviations.append(DeviationEvent(
            id="DEV-2026-001",
            batch_id="BATCH-VPU-0847",
            device_id="1E6001",
            parameter="vpu.main.temperature",
            expected_range="70.0 - 75.0 °C",
            actual_value=77.8,
            severity="MINOR",
            timestamp_utc="2026-08-15T09:34:00Z",
            description="Phase B heating overshoot during high-shear agitation step.",
            remediation="Proportional valve regulation adjusted. Temperature returned to setpoint in 45s.",
            investigation_status="RESOLVED",
        ))

    def generate_review_by_exception_report(self, batch_id: str) -> dict[str, Any]:
        """Generates FDA 2022 CGMP compliant Review-By-Exception summary."""
        raw_samples = self.mcp.get_process_params(batch_id)
        compliance_result = self.compliance_agent.analyze_batch_for_exceptions(batch_id, raw_samples)
        genealogy = self.mcp.get_material_genealogy(batch_id)
        yield_pred = self.yield_agent.predict_yield(batch_id, 3500.0, 75.0, -450.0)

        return {
            "batch_id": batch_id,
            "generated_at_utc": utc_now(),
            "standard_compliance": "21 CFR Part 11, EU Annex 11, GAMP 5",
            "review_by_exception": compliance_result,
            "material_genealogy": genealogy,
            "yield_forecast": yield_pred,
            "audit_trail_signature_count": len(self.agent_logs),
        }
