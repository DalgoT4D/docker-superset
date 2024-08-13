"""copy assets from running container to local host"""

import os
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("container", help="container name")
parser.add_argument("--source-dir", default="assets")
parser.add_argument("--target-dir", required="True")
args = parser.parse_args()

if args.source_dir == args.target_dir:
    raise ValueError("target-dir cannot be source-dir")

source_files = list(Path(f"{args.source_dir}/").rglob("*"))
for source_file in source_files:
    if source_file.is_dir():
        target_dir = str(source_file).replace(args.source_dir, args.target_dir)
        # print(f"ensuring {target_dir} exists")
        os.makedirs(target_dir, exist_ok=True)

for source_file in source_files:
    if source_file.is_file():
        target_file = str(source_file).replace(args.source_dir, args.target_dir)
        # print(f"{source_file} => {target_file}")
        container_file = str(source_file).replace(args.source_dir, "/app")
        cmd = f"docker cp {args.container}:{container_file} {target_file}"
        print(cmd)
        os.system(cmd)