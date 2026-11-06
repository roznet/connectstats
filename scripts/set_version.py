#!/usr/bin/env python3
"""Show or set MARKETING_VERSION / CURRENT_PROJECT_VERSION for one app target.

Edits only the XCBuildConfiguration blocks whose PRODUCT_BUNDLE_IDENTIFIER is
exactly the app's bundle id, so test targets and the other apps keep their own
numbers (ConnectStats and ConnectStatsTestApp both sit at build 1, so a plain
find-and-replace would bump both). Standard library only — no venv needed.

    python3 scripts/set_version.py --app connectstats                 # show
    python3 scripts/set_version.py --app connectstats --build 56
    python3 scripts/set_version.py --app fitfileexplorer --marketing 3.6 --build 6
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

PBXPROJ = Path(__file__).resolve().parent.parent / "ConnectStats.xcodeproj" / "project.pbxproj"

APPS = {
    "connectstats": "net.ro-z.connectstats",
    "fitfileexplorer": "net.ro-z.FitFileExplorer",
}

# One XCBuildConfiguration object: from its `isa` line to the closing `};`.
BLOCK = re.compile(
    r"isa = XCBuildConfiguration;\n.*?\n\t\t\};\n",
    re.DOTALL,
)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--app", required=True, choices=sorted(APPS))
    parser.add_argument("--marketing", help="new MARKETING_VERSION, e.g. 9.1")
    parser.add_argument("--build", help="new CURRENT_PROJECT_VERSION, e.g. 56")
    args = parser.parse_args()

    text = PBXPROJ.read_text()
    bundle_id = APPS[args.app]
    # Xcode writes the id quoted when it contains '-', bare otherwise.
    bundle_lines = (
        f'PRODUCT_BUNDLE_IDENTIFIER = "{bundle_id}";',
        f"PRODUCT_BUNDLE_IDENTIFIER = {bundle_id};",
    )
    bundle_line = bundle_lines[0]
    found: list[tuple[str, str, str]] = []

    def rewrite(match: re.Match[str]) -> str:
        block = match.group(0)
        if not any(line in block for line in bundle_lines):
            return block
        name = re.search(r"name = (\w+);", block)
        mkt = re.search(r"MARKETING_VERSION = ([^;]+);", block)
        bld = re.search(r"CURRENT_PROJECT_VERSION = ([^;]+);", block)
        if not (mkt and bld):
            sys.exit(f"error: {args.app} {name.group(1) if name else '?'} config lacks a version setting")
        found.append((name.group(1) if name else "?", mkt.group(1), bld.group(1)))
        if args.marketing:
            block = block.replace(mkt.group(0), f"MARKETING_VERSION = {args.marketing};")
        if args.build:
            block = block.replace(bld.group(0), f"CURRENT_PROJECT_VERSION = {args.build};")
        return block

    new_text = BLOCK.sub(rewrite, text)
    if not found:
        sys.exit(f"error: no build configuration with {bundle_line}")
    versions = {(m, b) for _, m, b in found}
    if len(versions) != 1:
        sys.exit(f"error: {args.app} configurations disagree: {found}")
    marketing, build = versions.pop()

    if args.marketing or args.build:
        PBXPROJ.write_text(new_text)
        print(f"{args.app}: {marketing} ({build}) -> {args.marketing or marketing} ({args.build or build})"
              f"  [{', '.join(n for n, _, _ in found)}]")
    else:
        # Machine-read by the /archive skill: "<marketing> <build>"
        print(f"{marketing} {build}")


if __name__ == "__main__":
    main()
