#!/usr/bin/env python3

import os, yaml

REQUIRED_FIELDS = {
    'workload_name': str,
    'description': str,
    'port': int,
    'dns_enabled': bool,
    'microservices': bool,
    'image': str,
    'build_context': str
}

def validate_meta(meta_path):
    with open(meta_path) as f:
        data = yaml.safe_load(f)

    errors = []
    for field, field_type in REQUIRED_FIELDS.items():
        if field not in data:
            errors.append(f"Missing required field: {field}")
        elif not isinstance(data[field], field_type):
            errors.append(f"Field {field} should be of type {field_type.__name__}")

    return errors

def main():
    root = os.getcwd()
    all_dirs = [d for d in os.listdir(root) if os.path.isdir(d)]
    failed = 0

    for d in all_dirs:
        meta_path = os.path.join(d, "project.meta.yaml")
        if os.path.exists(meta_path):
            errors = validate_meta(meta_path)
            if errors:
                print(f"❌ {d}/project.meta.yaml:")
                for err in errors:
                    print(f"   - {err}")
                failed += 1
            else:
                print(f"✅ {d}/project.meta.yaml is valid.")

    if failed:
        print(f"\n{failed} file(s) have validation errors.")
        exit(1)

if __name__ == "__main__":
    main()
