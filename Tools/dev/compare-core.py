"""Compare a pinned Ultimate core checkout with an extracted installed core PBO."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--installed", required=True, type=Path)
    parser.add_argument("--archive", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    source = args.source / "A3A/addons/core"
    suffixes = {".sqf", ".hpp", ".cpp"}

    def files(root):
        return {p.relative_to(root).as_posix().lower(): p for p in root.rglob("*")
                if p.is_file() and p.suffix.lower() in suffixes}

    expected, actual = files(source), files(args.installed)
    # Git checkout CRLF conversion is irrelevant to SQF source equivalence.
    def normalized(path):
        return path.read_bytes().replace(b"\r\n", b"\n")

    differences = [name for name in sorted(expected.keys() & actual.keys())
                   if normalized(expected[name]) != normalized(actual[name])]
    with args.archive.open("rb") as stream:
        archive_hash = hashlib.file_digest(stream, "sha256").hexdigest()
    report = {
        "schema_version": 1,
        "captured_at_utc": datetime.now(timezone.utc).isoformat(),
        "source_commit": subprocess.check_output(["git", "-C", str(args.source), "rev-parse", "HEAD"], text=True).strip(),
        "package": args.archive.name,
        "package_sha256": archive_hash,
        "compared_extensions": sorted(suffixes),
        "normalization": "CRLF to LF only",
        "identical_count": len(expected.keys() & actual.keys()) - len(differences),
        "different_files": differences,
        "source_only_files": sorted(expected.keys() - actual.keys()),
        "installed_only_files": sorted(actual.keys() - expected.keys()),
        "limitation": "Core script/config inputs only; config.cpp is packaging-dependent and binary/runtime compatibility is separate.",
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report))
    return 0 if not (set(differences) - {"config.cpp"}) and not report["source_only_files"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
