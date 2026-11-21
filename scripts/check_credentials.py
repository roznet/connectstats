#!/usr/bin/env python3
"""Release pre-flight: is ConnectStats/credentials.json real and complete?

The Xcode build phase "Check Credentials" silently copies
credentials.sample.json to credentials.json when the latter is missing, so a
build from a fresh checkout or worktree succeeds — with placeholder Garmin /
Strava / ConnectStats keys baked into the binary. This catches that.

Prints key names only, never values.

    python3 scripts/check_credentials.py [repo_root]

Exit 0 = OK, 1 = blocking problem.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

PLACEHOLDER = "***"

def leaf_keys(d: object, prefix: str = "") -> dict[str, object]:
    out: dict[str, object] = {}
    if isinstance(d, dict):
        for k, v in d.items():
            if isinstance(v, dict):
                out.update(leaf_keys(v, f"{prefix}{k}."))
            else:
                out[f"{prefix}{k}"] = v
    return out


def main() -> int:
    root = Path(sys.argv[1] if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent)
    real_path = root / "ConnectStats" / "credentials.json"
    sample_path = root / "ConnectStats" / "credentials.sample.json"

    if not real_path.exists():
        print(f"FAIL: {real_path} is missing — the build would copy the sample "
              "credentials in. Copy the real file from the main checkout.")
        return 1

    real = leaf_keys(json.loads(real_path.read_text()))
    sample = leaf_keys(json.loads(sample_path.read_text())) if sample_path.exists() else {}

    problems: list[str] = []
    if real_path.read_bytes() == (sample_path.read_bytes() if sample_path.exists() else b""):
        problems.append("credentials.json is byte-identical to credentials.sample.json")

    # The sample marks every secret as "***"; anything still "***" ships a dead key.
    placeholders = sorted(k for k, v in real.items() if v == PLACEHOLDER)
    if placeholders:
        problems.append(f"keys still holding the sample placeholder {PLACEHOLDER!r}: {placeholders}")

    empty = sorted(k for k, v in real.items() if v in ("", None))
    if empty:
        problems.append(f"empty values: {empty}")

    # A key added to the sample after the real file was made. Not blocking on its
    # own: the app may have a fallback (e.g. garmin.oauth2_client_id comes from
    # the server's status check first). The skill decides per key.
    missing = sorted(set(sample) - set(real))
    for key in missing:
        print(f"WARN: {key} is in the sample but not in credentials.json")

    if problems:
        for p in problems:
            print(f"FAIL: {p}")
        return 1
    print(f"OK: credentials.json has {len(real)} keys, none empty or left as {PLACEHOLDER!r}"
          + (f" ({len(missing)} sample key(s) missing, see WARN)" if missing else "") + ".")
    return 0


if __name__ == "__main__":
    sys.exit(main())
