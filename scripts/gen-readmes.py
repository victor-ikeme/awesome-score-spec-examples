#!/usr/bin/env python3

"""
Generate README.md files for each workload in the awesome-score-spec-examples project,
using a Jinja2 template and per-project meta.yaml configuration files.
"""

import os
import yaml
from jinja2 import Environment, FileSystemLoader

TEMPLATE_DIR = ".templates"
TEMPLATE_FILE = "README.template.md"
META_FILENAMES = ["project.meta.yaml", "project.meta.yml"]
OUTPUT_FILE = "README.md"


def find_meta_file(project_dir):
    for filename in META_FILENAMES:
        candidate = os.path.join(project_dir, filename)
        if os.path.isfile(candidate):
            print(f"🔍 Found meta file: {candidate}")
            return candidate
    return None


def generate_readme(project_dir):
    print(f"\n📦 Processing project: {project_dir}")
    
    meta_path = find_meta_file(project_dir)
    if not meta_path:
        print(f"⏭️  No project.meta.yaml or .yml found in {project_dir}, skipping.")
        return

    try:
        with open(meta_path) as f:
            meta = yaml.safe_load(f)
    except Exception as e:
        print(f"❌ Error loading YAML from {meta_path}: {e}")
        return

    try:
        template_env = Environment(loader=FileSystemLoader(TEMPLATE_DIR))
        template = template_env.get_template(TEMPLATE_FILE)
    except Exception as e:
        print(f"❌ Error loading template '{TEMPLATE_FILE}' from {TEMPLATE_DIR}: {e}")
        return

    try:
        readme_content = template.render(meta)
        output_path = os.path.join(project_dir, OUTPUT_FILE)
        with open(output_path, "w") as f:
            f.write(readme_content)
        print(f"✅ Generated README.md at {output_path}")
    except Exception as e:
        print(f"❌ Error rendering or writing README for {project_dir}: {e}")


def main():
    root_dir = os.getcwd()
    print(f"\n🚀 Starting README generation from root: {root_dir}")

    entries = sorted(os.listdir(root_dir))
    for entry in entries:
        full_path = os.path.join(root_dir, entry)
        if os.path.isdir(full_path) and not entry.startswith("."):
            print(f"📁 Found subdirectory: {entry}")
            generate_readme(full_path)


if __name__ == "__main__":
    main()
