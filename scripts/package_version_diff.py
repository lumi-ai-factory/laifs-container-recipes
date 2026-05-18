#!/usr/bin/env python3

import json
import sys
from pathlib import Path


def load_json(path):
    with open(path, "r") as f:
        return json.load(f)


def to_package_map(manager_data):
    return {pkg["name"]: pkg["version"] for pkg in manager_data}


def diff_managers(old_data, new_data):
    changes_found = False
    output = []

    all_managers = sorted(set(old_data.keys()) | set(new_data.keys()))

    for manager in all_managers:
        old_pkgs = to_package_map(old_data.get(manager, []))
        new_pkgs = to_package_map(new_data.get(manager, []))

        old_names = set(old_pkgs.keys())
        new_names = set(new_pkgs.keys())

        changed = []
        added = []
        removed = []

        for name in sorted(old_names & new_names):
            if old_pkgs[name] != new_pkgs[name]:
                changed.append(
                    f"- `{name}` {old_pkgs[name]} -> {new_pkgs[name]}"
                )

        for name in sorted(new_names - old_names):
            added.append(f"- `{name}` {new_pkgs[name]}")

        for name in sorted(old_names - new_names):
            removed.append(f"- `{name}` {old_pkgs[name]}")

        if not (changed or added or removed):
            continue

        changes_found = True
        output.append(f"### {manager.capitalize()} Package Changes\n")

        if changed:
            output.append("**Changed:**\n")
            output.extend(changed)
            output.append("")

        if added:
            output.append("**Added:**\n")
            output.extend(added)
            output.append("")

        if removed:
            output.append("**Removed:**\n")
            output.extend(removed)
            output.append("")

    return changes_found, "\n".join(output)


def main(old_path, new_path):
    old_data = load_json(old_path)
    new_data = load_json(new_path)

    changes_found, diff_output = diff_managers(old_data, new_data)

    print(f"## Package changes\n")
    print("Comprehensive list of package changes comparing the following releases:\n")
    print(f"- `{Path(old_path).name}`")
    print(f"- `{Path(new_path).name}`\n")

    if diff_output.strip():
        print(diff_output)
    else:
        print("_No changes detected._")

    sys.exit(0)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python package_version_diff.py old.json new.json")
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
