"""apache/superset:3.1.0rc3"""

import os
import sys
import argparse
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("direction", help="copy from or to remote", choices=["from", "to"])
parser.add_argument("local-dir", default=".")
parser.add_argument(
    "superset-subdir", required=True, help="e.g. superset3, superset3.1"
)
args = parser.parse_args()

local_dir = args.local_dir
superset_subdir = args.superset_subdir

MACHINE_IP = os.getenv("MACHINE_IP")
if not MACHINE_IP:
    print("Environment variable MACHINE_IP not set")
    sys.exit(1)

if not os.path.exists(f"{local_dir}/{superset_subdir}"):
    print(f"Directory {local_dir}/{superset_subdir} does not exist")
    sys.exit(1)

remote_dir = f"ubuntu@{MACHINE_IP}:/home/ubuntu/docker-superset"

copy_cmd = [
    "scp",
    "-i",
    "../../secrets/superset.pem",
]

files = [
    "baselayout.py",
    "basic.html",
    "jinja_context.py",
]


def copy_from_remote():
    """copy from the remote machine to the local machine"""
    for file in files:
        copy_cmd.append(f"{remote_dir}/{superset_subdir}/{file}")
        copy_cmd.append(f"{local_dir}/{superset_subdir}/{file}")
        subprocess.check_call(copy_cmd)
        copy_cmd.pop()
        copy_cmd.pop()


def copy_to_remote():
    """copy from the local machine to the remote machine"""
    for file in files:
        copy_cmd.append(f"{local_dir}/{superset_subdir}/{file}")
        copy_cmd.append(f"{remote_dir}/{superset_subdir}/{file}")
        subprocess.check_call(copy_cmd)
        copy_cmd.pop()
        copy_cmd.pop()


if args.direction == "from":
    copy_from_remote()
else:
    copy_to_remote()
