import { NextRequest, NextResponse } from "next/server";
import { readPlcState, writePlcOutput, writeAllOutputsOff, writePlcRegister } from "@/lib/modbus";

export const dynamic = "force-dynamic";

export async function GET() {
  const snapshot = await readPlcState();
  return NextResponse.json(snapshot);
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const action = body.action;

    if (action === "set_output") {
      const outputIdx = parseInt(body.output, 10);
      const state = Boolean(body.state);
      if (isNaN(outputIdx) || outputIdx < 0 || outputIdx > 15) {
        return NextResponse.json({ success: false, error: "Invalid output index (0-15)" }, { status: 400 });
      }
      const ok = await writePlcOutput(outputIdx, state);
      return NextResponse.json({ success: ok, output: outputIdx, state });
    }

    if (action === "all_off") {
      const ok = await writeAllOutputsOff();
      return NextResponse.json({ success: ok, message: "All outputs turned off" });
    }

    if (action === "set_register") {
      const registerOffset = parseInt(body.register, 10);
      const value = parseInt(body.value, 10);
      if (isNaN(registerOffset) || isNaN(value)) {
        return NextResponse.json({ success: false, error: "Invalid register offset or value" }, { status: 400 });
      }
      const ok = await writePlcRegister(registerOffset, value);
      return NextResponse.json({ success: ok, register: registerOffset, value });
    }

    return NextResponse.json({ success: false, error: `Unknown action: ${action}` }, { status: 400 });
  } catch (err: any) {
    return NextResponse.json({ success: false, error: err.message || String(err) }, { status: 500 });
  }
}

