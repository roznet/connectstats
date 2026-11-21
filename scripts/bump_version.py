#!/usr/bin/env python3
"""Read or set the ConnectStats app target's version in project.pbxproj.

Only the build configurations of the ConnectStats app target are touched —
identified by INFOPLIST_FILE = "ConnectStats/ConnectStats-Info.plist". The
other targets (TestApp, FitFileExplorer, HealthStats, test bundles) carry
their own, unrelated MARKETING_VERSION / CURRENT_PROJECT_VERSION values, and
some of them share the literal `CURRENT_PROJECT_VERSION = 1;`, so a plain
find/replace (or `agvtool`, which bumps every target) gets it wrong.

    python3 scripts/bump_version.py                      # print current
    python3 scripts/bump_version.py --build 1234         # set build number
    python3 scripts/bump_version.py --build 1234 --marketing 9.1
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

PBXPROJ = Path(__file__).resolve().parent.parent / "ConnectStats.xcodeproj" / "project.pbxproj"
APP_PLIST = 'INFOPLIST_FILE = "ConnectStats/ConnectStats-Info.plist";'
BLOCK_RE = re.compile(r"isa = XCBuildConfiguration;.*?\n\t\t\tname = [^;]+;\n\t\t\};", re.S)
EXPECTED_BLOCKS = 2  # Debug + Release


def app_blocks(text: str) -> list[re.Match[str]]:
    return [m for m in BLOCK_RE.finditer(text) if APP_PLIST in m.group(0)]


def setting(block: str, key: str) -> str:
    m = re.search(rf"\b{key} = ([^;]+);", block)
    if not m:
        sys.exit(f"{key} not found in an app build configuration")
    return m.group(1).strip('"')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--build", help="new CURRENT_PROJECT_VERSION (integer)")
    parser.add_argument("--marketing", help="new MARKETING_VERSION, e.g. 9.1")
    parser.add_argument("--pbxproj", type=Path, default=PBXPROJ)
    args = parser.parse_args()

    text = args.pbxproj.read_text()
    blocks = app_blocks(text)
    if len(blocks) != EXPECTED_BLOCKS:
        sys.exit(f"expected {EXPECTED_BLOCKS} ConnectStats app build configurations, found {len(blocks)} — "
                 "the project layout changed; update scripts/bump_version.py")

    current = {(setting(b.group(0), "MARKETING_VERSION"), setting(b.group(0), "CURRENT_PROJECT_VERSION"))
               for b in blocks}
    if len(current) != 1:
        sys.exit(f"Debug and Release disagree on the version: {sorted(current)} — fix by hand first")
    marketing, build = current.pop()

    if not args.build and not args.marketing:
        print(f"MARKETING_VERSION={marketing}")
        print(f"CURRENT_PROJECT_VERSION={build}")
        return 0

    if args.build and not args.build.isdigit():
        sys.exit("--build must be a plain integer")

    # Edit from the end so earlier match offsets stay valid.
    for m in reversed(blocks):
        block = m.group(0)
        if args.build:
            block = re.sub(r"\bCURRENT_PROJECT_VERSION = [^;]+;", f"CURRENT_PROJECT_VERSION = {args.build};", block)
        if args.marketing:
            block = re.sub(r"\bMARKETING_VERSION = [^;]+;", f"MARKETING_VERSION = {args.marketing};", block)
        text = text[: m.start()] + block + text[m.end():]
    args.pbxproj.write_text(text)

    print(f"{marketing} ({build}) -> {args.marketing or marketing} ({args.build or build})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
