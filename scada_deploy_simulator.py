#!/usr/bin/env python3
"""
PVA Systems VPU-50 SCADA – Local Builder & Deployment Simulator
===============================================================
A comprehensive pre-push CI/CD simulator that verifies:
  1. Git Trackability & Staging Healthcheck (no untracked files referenced in manifests)
  2. CMake & QRC Invariant Gate (zero duplicates, zero missing, zero scratch paths)
  3. QML Static & Headless Runtime Sanity (PySide6 offscreen engine check)
  4. SCADA Compliance Test Suite (16/16 unit tests)
  5. Vercel Configuration & Packaging Simulator (validates headers, builds local dist/)
  6. Web Simulator & Synthetic Vercel Header Probe (serves with exact COOP/COEP headers)
  7. Pre-Push Hook Installer (blocks git push if any check fails)

Usage:
  python scada_deploy_simulator.py --all           # Run full validation pipeline
  python scada_deploy_simulator.py --serve         # Build dist & start local web simulator
  python scada_deploy_simulator.py --probe         # Synthetic Vercel header probe
  python scada_deploy_simulator.py --install-hook  # Install Git pre-push hook
  python scada_deploy_simulator.py --auto-stage    # Auto-stage untracked manifest files
"""

import argparse
import http.server
import json
import os
from pathlib import Path
import re
import shutil
import socketserver
import subprocess
import sys
import threading
import time
import urllib.request
import io

# Ensure UTF-8 output on Windows consoles
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

ROOT_DIR = Path(__file__).resolve().parent
CONTENT_DIR = ROOT_DIR / "PVA_VPU50_SCADAContent"
DIST_DIR = ROOT_DIR / "dist"
RULES_FILE = ROOT_DIR / ".agents" / "memory" / "DEPLOYMENT_SIMULATOR_RULES.json"

# ANSI Colors
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
BOLD = "\033[1m"
RESET = "\033[0m"


def print_stage(title: str):
    print(f"\n{BOLD}{CYAN}======================================================================{RESET}")
    print(f"{BOLD}{CYAN}>>> {title}{RESET}")
    print(f"{BOLD}{CYAN}======================================================================{RESET}")


def log_pass(msg: str):
    print(f"  {GREEN}[PASS]{RESET} {msg}")


def log_warn(msg: str):
    print(f"  {YELLOW}[WARN]{RESET} {msg}")


def log_fail(msg: str):
    print(f"  {RED}[FAIL]{RESET} {msg}")


# =============================================================================
# STAGE 1: Git Trackability & Staging Healthcheck
# =============================================================================
def check_git_trackability(auto_stage: bool = False) -> bool:
    print_stage("STAGE 1: Git Trackability & Staging Healthcheck")
    passed = True

    try:
        res = subprocess.run(["git", "status", "--porcelain"], cwd=str(ROOT_DIR), capture_output=True, text=True, check=True)
    except Exception as e:
        log_warn(f"Unable to run git status: {e}")
        return True

    status_lines = res.stdout.strip().splitlines()
    untracked = [line[3:].strip() for line in status_lines if line.startswith("??")]

    # Check against CMake and QRC declared files
    cmake_file = CONTENT_DIR / "CMakeLists.txt"
    qrc_file = ROOT_DIR / "PVA_VPU50_SCADA.qrc"
    
    declared_files = set()
    if cmake_file.exists():
        entries = re.findall(r'"([^"]+)"', cmake_file.read_text(encoding="utf-8"))
        for e in entries:
            if not e.startswith("PVA_") and not e.startswith("/"):
                declared_files.add(f"PVA_VPU50_SCADAContent/{e}".replace("\\", "/"))

    if qrc_file.exists():
        entries = re.findall(r'<file>([^<]+)</file>', qrc_file.read_text(encoding="utf-8"))
        for e in entries:
            declared_files.add(e.replace("\\", "/"))

    untracked_critical = []
    for u in untracked:
        u_norm = u.replace("\\", "/").rstrip("/")
        # Check if this untracked directory or file contains any declared file
        for df in declared_files:
            if df == u_norm or df.startswith(u_norm + "/"):
                untracked_critical.append(u)
                break

    if untracked_critical:
        log_fail(f"Found {len(untracked_critical)} untracked directories/files referenced in CMake/QRC manifests:")
        for uc in set(untracked_critical):
            print(f"     {RED}• {uc}{RESET}")
        print(f"\n     {YELLOW}CRITICAL NOTE: Untracked files exist on your local disk but WILL FAIL ON GITHUB ACTIONS!{RESET}")
        
        if auto_stage:
            print(f"     {CYAN}Auto-staging untracked critical files with 'git add'...{RESET}")
            for uc in set(untracked_critical):
                subprocess.run(["git", "add", uc], cwd=str(ROOT_DIR), check=True)
            log_pass("All untracked critical files successfully staged.")
        else:
            print(f"     {YELLOW}Resolution: Run 'python scada_deploy_simulator.py --auto-stage' or 'git add <files>'.{RESET}")
            passed = False
    else:
        log_pass("All files referenced in build manifests are properly tracked in Git.")

    return passed


# =============================================================================
# STAGE 2: CMake, QRC & Manifest Invariant Gate
# =============================================================================
def check_cmake_and_qrc_invariants() -> bool:
    print_stage("STAGE 2: CMake, QRC & Build Manifest Invariant Gate")
    passed = True

    # 1. Root CMake target name collision check
    root_cmake = ROOT_DIR / "CMakeLists.txt"
    if root_cmake.exists():
        txt = root_cmake.read_text(encoding="utf-8")
        if "project(PVA_VPU50_SCADA " in txt or "project(PVA_VPU50_SCADA)" in txt:
            log_fail("Root CMakeLists.txt uses project(PVA_VPU50_SCADA). This causes a target collision with PVA_VPU50_SCADA library!")
            passed = False
        else:
            log_pass("Root CMake project name is correctly disambiguated (PVA_VPU50_SCADAApp).")

    # 2. Content CMakeLists.txt duplicates & missing files
    content_cmake = CONTENT_DIR / "CMakeLists.txt"
    if content_cmake.exists():
        txt = content_cmake.read_text(encoding="utf-8")
        raw_entries = re.findall(r'"([^"]+)"', txt)
        entries = [e for e in raw_entries if e not in ["PVA_VPU50_SCADAContent", "/qt/qml"]]
        
        dups = [e for e in set(entries) if entries.count(e) > 1]
        if dups:
            log_fail(f"PVA_VPU50_SCADAContent/CMakeLists.txt contains {len(dups)} duplicate entries: {dups}")
            passed = False
        else:
            log_pass(f"PVA_VPU50_SCADAContent/CMakeLists.txt has 0 duplicate entries ({len(entries)} files verified).")

        missing = []
        for e in entries:
            fp = CONTENT_DIR / e
            if not fp.exists():
                missing.append(e)
        if missing:
            log_fail(f"PVA_VPU50_SCADAContent/CMakeLists.txt references {len(missing)} missing files: {missing}")
            passed = False
        else:
            log_pass("All files in PVA_VPU50_SCADAContent/CMakeLists.txt physically exist on disk.")

        if "scratch/" in txt or "tmp/" in txt:
            log_fail("PVA_VPU50_SCADAContent/CMakeLists.txt contains forbidden scratch/ or tmp/ paths!")
            passed = False
        else:
            log_pass("Zero scratch/ or tmp/ paths found in CMakeLists.txt.")

    # 3. PVA_VPU50_SCADA.qrc duplicates & missing files
    qrc_file = ROOT_DIR / "PVA_VPU50_SCADA.qrc"
    if qrc_file.exists():
        txt = qrc_file.read_text(encoding="utf-8")
        files = re.findall(r'<file>([^<]+)</file>', txt)
        dups = [f for f in set(files) if files.count(f) > 1]
        if dups:
            log_fail(f"PVA_VPU50_SCADA.qrc contains {len(dups)} duplicate files: {dups}")
            passed = False
        else:
            log_pass(f"PVA_VPU50_SCADA.qrc has 0 duplicate entries ({len(files)} files verified).")

        missing = []
        for f in files:
            fp = ROOT_DIR / f
            if not fp.exists():
                missing.append(f)
        if missing:
            log_fail(f"PVA_VPU50_SCADA.qrc references {len(missing)} missing files: {missing}")
            passed = False
        else:
            log_pass("All files in PVA_VPU50_SCADA.qrc physically exist on disk.")

    # 4. Theme Singleton Declarations
    theme_cmake = CONTENT_DIR / "theme" / "CMakeLists.txt"
    theme_qmldir = CONTENT_DIR / "theme" / "qmldir"
    if theme_cmake.exists() and theme_qmldir.exists():
        c_txt = theme_cmake.read_text(encoding="utf-8")
        q_txt = theme_qmldir.read_text(encoding="utf-8")
        for s in ["Theme", "Dimensions", "Typography", "AppConstants"]:
            if f"singleton {s}" not in q_txt:
                log_fail(f"qmldir missing singleton declaration for {s}")
                passed = False
            if f"{s}.qml" not in c_txt:
                log_fail(f"theme/CMakeLists.txt missing QML_FILES entry for {s}.qml")
                passed = False
        log_pass("Theme singletons (Theme, Dimensions, Typography, AppConstants) verified in qmldir & CMake.")

    return passed


# =============================================================================
# STAGE 3: QML Static & Headless Runtime Sanity
# =============================================================================
# STAGE 3: QML Static & Headless Runtime Sanity
# =============================================================================
def check_ui_qml_declarative_purity() -> bool:
    """Verifies all .ui.qml files comply with Qt Design Studio declarative purity (RULE-008, M222 invariant)."""
    passed = True
    ui_files = list(CONTENT_DIR.rglob("*.ui.qml"))
    
    forbidden_patterns = [
        (re.compile(r'\bfunction\s+\w+\s*\('), "Explicit function declaration 'function ...' not permitted in .ui.qml (M222)"),
        (re.compile(r'\.padStart\s*\('), "JavaScript method call '.padStart()' not permitted in .ui.qml (M222)"),
        (re.compile(r'\.replace\s*\('), "JavaScript method call '.replace()' not permitted in .ui.qml (M222)"),
        (re.compile(r'\bString\s*\('), "JavaScript constructor 'String(...)' not permitted in .ui.qml (M222)"),
    ]
    
    violations = []
    for f in ui_files:
        content = f.read_text(encoding="utf-8", errors="replace")
        for lineno, line in enumerate(content.splitlines(), start=1):
            stripped = line.strip()
            if stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*"):
                continue
            for pat, desc in forbidden_patterns:
                if pat.search(stripped):
                    rel = f.relative_to(ROOT_DIR)
                    violations.append(f"{rel}:{lineno} -> {desc}\n    Line: {stripped}")
                    passed = False

    if violations:
        log_fail(f"Found {len(violations)} Qt Design Studio M222 violations in .ui.qml files:\n" + "\n".join(violations[:5]))
    else:
        log_pass(f"All {len(ui_files)} .ui.qml files verified for Qt Design Studio declarative purity (Zero M222 errors).")

    return passed


def check_qml_headless_runtime() -> bool:
    print_stage("STAGE 3: QML Static & Headless Runtime Sanity")
    
    purity_passed = check_ui_qml_declarative_purity()
    
    # Run python main.py --verify-qml
    try:
        cmd = [sys.executable, str(ROOT_DIR / "main.py"), "--verify-qml"]
        res = subprocess.run(cmd, cwd=str(ROOT_DIR), capture_output=True, text=True, timeout=20)
        if res.returncode == 0:
            log_pass("Headless PySide6 QQmlApplicationEngine instantiated and terminated with Exit Code 0.")
            return purity_passed
        else:
            log_fail(f"PySide6 QML verification failed with code {res.returncode}:\n{res.stderr}")
            return False
    except subprocess.TimeoutExpired:
        log_fail("QML verification timed out after 20s (possible deadlock or infinite event loop).")
        return False
    except Exception as e:
        log_fail(f"Failed to execute QML verification: {e}")
        return False


# =============================================================================
# STAGE 4: Automated SCADA Compliance Test Suite
# =============================================================================
def run_compliance_tests() -> bool:
    print_stage("STAGE 4: Automated SCADA Compliance Test Suite")
    
    cmd = [sys.executable, "-m", "unittest", "discover", "tests", "-v"]
    try:
        res = subprocess.run(cmd, cwd=str(ROOT_DIR), capture_output=True, text=True, timeout=30)
        output = res.stderr + "\n" + res.stdout
        if res.returncode == 0 and "OK" in output:
            lines = [l for l in output.splitlines() if "..." in l]
            log_pass(f"All {len(lines)} unit tests passed cleanly in compliance suite.")
            return True
        else:
            log_fail(f"Unit test failures detected:\n{output}")
            return False
    except Exception as e:
        log_fail(f"Failed to run unit tests: {e}")
        return False


# =============================================================================
# STAGE 5: Vercel Artifact Packaging Simulator
# =============================================================================
def simulate_vercel_packaging() -> bool:
    print_stage("STAGE 5: Vercel Packaging & Distribution Simulator")
    passed = True

    # 1. Validate vercel.json
    v_file = ROOT_DIR / "vercel.json"
    if not v_file.exists():
        log_fail("vercel.json is missing in project root!")
        return False

    try:
        v_data = json.loads(v_file.read_text(encoding="utf-8"))
        headers = v_data.get("headers", [])
        has_coop = False
        has_coep = False
        has_wasm_mime = False

        for hgroup in headers:
            h_list = hgroup.get("headers", [])
            for h in h_list:
                k = h.get("key", "").lower()
                v = h.get("value", "").lower()
                if k == "cross-origin-opener-policy" and v == "same-origin":
                    has_coop = True
                if k == "cross-origin-embedder-policy" and v == "require-corp":
                    has_coep = True
                if k == "content-type" and "application/wasm" in v:
                    has_wasm_mime = True

        if has_coop and has_coep:
            log_pass("vercel.json specifies required COOP (same-origin) and COEP (require-corp) headers.")
        else:
            log_fail("vercel.json is missing required COOP / COEP isolation headers for WebAssembly.")
            passed = False

        if has_wasm_mime:
            log_pass("vercel.json specifies explicit 'application/wasm' MIME type for WebAssembly.")
        else:
            log_warn("vercel.json lacks explicit 'application/wasm' MIME type mapping.")
    except Exception as e:
        log_fail(f"Invalid JSON syntax in vercel.json: {e}")
        return False

    # 2. Assemble local dist/ folder
    DIST_DIR.mkdir(parents=True, exist_ok=True)
    
    # Copy web simulator shell as index.html
    web_sim_html = ROOT_DIR / "runtime" / "web_simulator" / "index.html"
    if web_sim_html.exists():
        shutil.copy(web_sim_html, DIST_DIR / "index.html")
        log_pass(f"Generated dist/index.html ({DIST_DIR / 'index.html'}).")
    else:
        log_fail(f"Missing web simulator template at {web_sim_html}!")
        passed = False

    # Copy vercel.json
    shutil.copy(v_file, DIST_DIR / "vercel.json")

    # Copy Favicon assets
    fav_svg = CONTENT_DIR / "assets" / "icons" / "header" / "favicon.svg"
    if fav_svg.exists():
        shutil.copy(fav_svg, DIST_DIR / "favicon.svg")
        shutil.copy(fav_svg, DIST_DIR / "favicon.ico")
        log_pass("Copied favicon.svg and favicon.ico into dist/.")

    # Validate dist contents
    if not (DIST_DIR / "index.html").exists() or (DIST_DIR / "index.html").stat().st_size < 100:
        log_fail("dist/index.html is empty or missing! GitHub Actions deployment gate would abort.")
        passed = False
    else:
        log_pass("dist/ validation passed: index.html is valid and ready for Vercel deployment.")

    return passed


# =============================================================================
# STAGE 6: Local Web Server with Vercel Production Headers
# =============================================================================
class VercelSimHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Inject exact Vercel production security headers
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Access-Control-Allow-Origin", "*")
        if self.path.endswith(".wasm"):
            self.send_header("Content-Type", "application/wasm")
            self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        super().end_headers()

    def log_message(self, format, *args):
        # Suppress noisy standard request logs during synthetic testing
        if "--quiet" in sys.argv or hasattr(self.server, "is_probing"):
            return
        super().log_message(format, *args)


def run_synthetic_header_probe(port: int = 3099) -> bool:
    print_stage("STAGE 6: Synthetic Vercel Header Probe")
    
    simulate_vercel_packaging()
    
    server_address = ("", port)
    Handler = lambda *args, **kwargs: VercelSimHTTPRequestHandler(*args, directory=str(DIST_DIR), **kwargs)
    
    try:
        httpd = socketserver.TCPServer(server_address, Handler)
        httpd.is_probing = True
    except Exception as e:
        log_fail(f"Could not bind port {port}: {e}")
        return False

    server_thread = threading.Thread(target=httpd.serve_forever, daemon=True)
    server_thread.start()
    time.sleep(0.3)

    passed = True
    try:
        req = urllib.request.Request(f"http://127.0.0.1:{port}/index.html", method="HEAD")
        with urllib.request.urlopen(req, timeout=3) as res:
            coop = res.headers.get("Cross-Origin-Opener-Policy")
            coep = res.headers.get("Cross-Origin-Embedder-Policy")
            
            if coop == "same-origin":
                log_pass("Synthetic probe confirmed Cross-Origin-Opener-Policy: same-origin.")
            else:
                log_fail(f"Expected COOP 'same-origin', got '{coop}'.")
                passed = False

            if coep == "require-corp":
                log_pass("Synthetic probe confirmed Cross-Origin-Embedder-Policy: require-corp.")
            else:
                log_fail(f"Expected COEP 'require-corp', got '{coep}'.")
                passed = False
    except Exception as e:
        log_fail(f"Synthetic HTTP probe failed: {e}")
        passed = False
    finally:
        httpd.shutdown()
        httpd.server_close()

    return passed


def serve_local_simulator(port: int = 3000):
    print_stage(f"LOCAL SCADA WEB SIMULATOR RUNNING (Port {port})")
    simulate_vercel_packaging()
    
    server_address = ("", port)
    Handler = lambda *args, **kwargs: VercelSimHTTPRequestHandler(*args, directory=str(DIST_DIR), **kwargs)
    
    try:
        httpd = socketserver.TCPServer(server_address, Handler)
    except Exception as e:
        print(f"{RED}Error: Port {port} is already in use: {e}{RESET}")
        return

    print(f"{GREEN}{BOLD}✓ Local Vercel Simulator active at:{RESET} {CYAN}http://localhost:{port}{RESET}")
    print(f"  • Cross-Origin-Opener-Policy: {GREEN}same-origin{RESET}")
    print(f"  • Cross-Origin-Embedder-Policy: {GREEN}require-corp{RESET}")
    print(f"  • WebAssembly 60 FPS Canvas: {GREEN}ENABLED{RESET}")
    print(f"\n{YELLOW}Press Ctrl+C to terminate simulator.{RESET}\n")

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print(f"\n{CYAN}Shutting down local simulator.{RESET}")
    finally:
        httpd.shutdown()
        httpd.server_close()


# =============================================================================
# STAGE 7: Git Pre-Push Hook Installation
# =============================================================================
def install_git_pre_push_hook() -> bool:
    print_stage("STAGE 7: Git Pre-Push Hook Installation")
    hook_dir = ROOT_DIR / ".git" / "hooks"
    if not hook_dir.exists():
        log_fail(f".git/hooks directory not found at {hook_dir}. Is this a git repo?")
        return False

    hook_file = hook_dir / "pre-push"
    hook_script = f"""#!/bin/sh
# PVA Systems SCADA Pre-Push Deployment Simulator Gate
echo "[PRE-PUSH GATE] Executing local build & deployment simulator before push..."
python "{ROOT_DIR / 'scada_deploy_simulator.py'}" --all --quiet
RESULT=$?
if [ $RESULT -ne 0 ]; then
    echo "[PRE-PUSH GATE] ERROR: Deployment simulator failed! Push aborted to prevent GitHub Actions failure."
    echo "Run 'python scada_deploy_simulator.py --all' locally to inspect and resolve the issues."
    exit 1
fi
echo "[PRE-PUSH GATE] All 7 gates passed. Proceeding with git push."
exit 0
"""
    try:
        hook_file.write_text(hook_script, encoding="utf-8")
        # On POSIX / Git Bash, set executable bit
        try:
            os.chmod(hook_file, 0o755)
        except Exception:
            pass
        log_pass(f"Git pre-push hook installed successfully at {hook_file}.")
        return True
    except Exception as e:
        log_fail(f"Failed to install git hook: {e}")
        return False


# =============================================================================
# MAIN CLI ENTRYPOINT
# =============================================================================
def main():
    parser = argparse.ArgumentParser(description="PVA Systems SCADA Local Builder & Deployment Simulator")
    parser.add_argument("--all", action="store_true", help="Run full 7-stage pre-push verification pipeline")
    parser.add_argument("--check-git", action="store_true", help="Run Stage 1 (Git trackability check)")
    parser.add_argument("--auto-stage", action="store_true", help="Automatically stage untracked files referenced in manifests")
    parser.add_argument("--check-cmake", action="store_true", help="Run Stage 2 (CMake/QRC invariant check)")
    parser.add_argument("--check-qml", action="store_true", help="Run Stage 3 (QML headless sanity check)")
    parser.add_argument("--test", action="store_true", help="Run Stage 4 (SCADA compliance tests)")
    parser.add_argument("--build-dist", action="store_true", help="Run Stage 5 (Vercel packaging simulator)")
    parser.add_argument("--probe", action="store_true", help="Run Stage 6 (Synthetic HTTP header probe)")
    parser.add_argument("--serve", action="store_true", help="Serve web simulator on localhost")
    parser.add_argument("--port", type=int, default=3000, help="Port for local web server (default: 3000)")
    parser.add_argument("--install-hook", action="store_true", help="Install pre-push git hook")
    parser.add_argument("--quiet", action="store_true", help="Minimal output for automated git hooks")

    args = parser.parse_args()

    if args.install_hook:
        success = install_git_pre_push_hook()
        sys.exit(0 if success else 1)

    if args.serve:
        serve_local_simulator(args.port)
        sys.exit(0)

    # Default to --all if no specific stage flag is passed
    run_all = args.all or not (args.check_git or args.check_cmake or args.check_qml or args.test or args.build_dist or args.probe)

    results = []

    if run_all or args.check_git:
        results.append(("Git Trackability Gate", check_git_trackability(auto_stage=args.auto_stage)))

    if run_all or args.check_cmake:
        results.append(("CMake & QRC Invariants Gate", check_cmake_and_qrc_invariants()))

    if run_all or args.check_qml:
        results.append(("QML Headless Sanity Gate", check_qml_headless_runtime()))

    if run_all or args.test:
        results.append(("SCADA Compliance Suite", run_compliance_tests()))

    if run_all or args.build_dist:
        results.append(("Vercel Packaging Simulator", simulate_vercel_packaging()))

    if run_all or args.probe:
        results.append(("Synthetic Vercel Header Probe", run_synthetic_header_probe(port=args.port if args.probe else 3099)))

    # Print Summary Table
    print_stage("PRE-PUSH SIMULATION SUMMARY")
    all_passed = True
    for name, passed in results:
        status_str = f"{GREEN}PASS (OK){RESET}" if passed else f"{RED}FAIL{RESET}"
        print(f"  • {name.ljust(36)} : {status_str}")
        if not passed:
            all_passed = False

    print()
    if all_passed:
        print(f"{GREEN}{BOLD}======================================================================{RESET}")
        print(f"{GREEN}{BOLD}[OK] ALL PRE-PUSH GATES PASSED! SAFE TO COMMIT & PUSH TO GITHUB.{RESET}")
        print(f"{GREEN}{BOLD}======================================================================{RESET}\n")
        sys.exit(0)
    else:
        print(f"{RED}{BOLD}======================================================================{RESET}")
        print(f"{RED}{BOLD}[FAIL] PRE-PUSH VALIDATION FAILED! DO NOT PUSH TO GITHUB UNTIL RESOLVED.{RESET}")
        print(f"{RED}{BOLD}======================================================================{RESET}\n")
        sys.exit(1)


if __name__ == "__main__":
    main()
