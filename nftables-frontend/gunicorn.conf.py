import subprocess
import sys
import os
import multiprocessing

try:
    res = subprocess.Popen(
        ["hug", "-f", "main.py"],
        cwd=os.path.abspath("../nftables-parser"),
        stdout=sys.stdout,
        stderr=sys.stderr,
    )
except FileNotFoundError as e:
    print(f"[gunicorn] hug não encontrado: {e}", file=sys.stderr)


def on_starting(server):
    global res
    res = subprocess.Popen(["/usr/bin/hug", "-f", "main.py"], cwd=os.path.abspath("../nftables-parser"), shell=False,
                           stdout=sys.stdout, stderr=sys.stderr)


def on_exit(server):
    res.terminate()
