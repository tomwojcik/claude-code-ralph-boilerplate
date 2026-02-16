#!/usr/bin/env python3
"""Merge template settings.json into an existing one without losing user config."""
import json
import sys


def merge(existing_path: str, template_path: str) -> str:
    existing = json.load(open(existing_path))
    template = json.load(open(template_path))

    # Merge permissions.allow and permissions.deny as sets (no duplicates)
    for key in ("allow", "deny"):
        existing_list = existing.get("permissions", {}).get(key, [])
        template_list = template.get("permissions", {}).get(key, [])
        merged = list(dict.fromkeys(existing_list + template_list))
        existing.setdefault("permissions", {})[key] = merged

    # Merge remaining keys: template values fill in, existing wins on conflicts
    for key in template:
        if key == "permissions":
            continue
        if isinstance(template[key], dict):
            existing.setdefault(key, {})
            for k, v in template[key].items():
                existing[key].setdefault(k, v)
        elif isinstance(template[key], list):
            existing_list = existing.get(key, [])
            existing[key] = list(dict.fromkeys(existing_list + template[key]))
        else:
            existing.setdefault(key, template[key])

    return json.dumps(existing, indent=2) + "\n"


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <existing_settings.json> <template_settings.json>", file=sys.stderr)
        sys.exit(1)
    print(merge(sys.argv[1], sys.argv[2]), end="")