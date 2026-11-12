"""Record an installed Arma/Workshop baseline without copying dependency assets."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
from datetime import datetime, timezone


MODS = {
    "450814997": "CBA_A3",
    "2291129343": "Improved Melee System",
    "2789152015": "WebKnight's Zombies and Creatures",
    "3020755032": "Antistasi Ultimate",
    "583496184": "CUP Terrains - Core (Chernarus Redux dependency)",
    "1128256978": "Chernarus Redux (acceptance terrain)",
}


def parse_vdf(text):
    tokens = iter(re.findall(r'"(?:\\.|[^"\\])*"|[{}]', text))

    def read_object(nested=False):
        result = {}
        for token in tokens:
            if token == "}":
                if not nested:
                    raise ValueError("Unexpected closing brace in Steam manifest")
                return result
            if not token.startswith('"'):
                raise ValueError("Expected a quoted Steam manifest key")
            key = json.loads(token)
            value = next(tokens)
            result[key] = read_object(True) if value == "{" else json.loads(value)
        if nested:
            raise ValueError("Unclosed object in Steam manifest")
        return result

    return read_object()


def digest(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steam-library", type=Path, required=True)
    parser.add_argument("--ultimate-source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    steamapps = args.steam_library / "steamapps"
    workshop = steamapps / "workshop"
    manifest = parse_vdf((workshop / "appworkshop_107410.acf").read_text())[
        "AppWorkshop"
    ]
    game = parse_vdf((steamapps / "appmanifest_107410.acf").read_text())["AppState"]
    source_commit = subprocess.check_output(
        ["git", "-C", str(args.ultimate_source), "rev-parse", "HEAD"], text=True
    ).strip()
    report = {
        "schema": 1,
        "captured_utc": datetime.now(timezone.utc).isoformat(),
        "arma_build_id": game["buildid"],
        "arma_updated_unix": game["LastUpdated"],
        "ultimate_source_repository": "Antistasi-Ultimate-Community/A3-Antistasi-Ultimate",
        "ultimate_source_commit": source_commit,
        "mod_files": [],
        "limitations": [
            "File identity and Steam's local manifest are evidence of installed content, not runtime compatibility.",
            "Source equivalence is checked separately against the extracted installed addon.",
        ],
    }
    for workshop_id, name in MODS.items():
        directory = workshop / "content" / "107410" / workshop_id
        installed = manifest.get("WorkshopItemsInstalled", {}).get(workshop_id)
        if not installed or not directory.is_dir():
            raise SystemExit(f"Required baseline item is not installed: {workshop_id} ({name})")
        archives = sorted(directory.rglob("*.pbo"))
        if not archives:
            raise SystemExit(f"No addon archives found for {workshop_id} ({name})")
        details = manifest.get("WorkshopItemDetails", {}).get(workshop_id, {})
        item = {
            "workshop_id": workshop_id,
            "name": name,
            "manifest": installed.get("manifest"),
            "installed_updated_unix": installed.get("timeupdated"),
            "steam_latest_updated_unix": details.get("latest_timeupdated"),
            "archives": [
                {
                    "path": path.relative_to(directory).as_posix(),
                    "bytes": path.stat().st_size,
                    "sha256": digest(path),
                }
                for path in archives
            ],
        }
        report["mod_files"].append(item)
        print(f"Inventoried {name}: {len(archives)} archives", flush=True)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Baseline written to {args.output}")


if __name__ == "__main__":
    main()
