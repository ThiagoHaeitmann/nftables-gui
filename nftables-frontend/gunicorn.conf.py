# nftables-frontend/gunicorn.conf.py
import subprocess, sys, os

res = None

def on_starting(server):
    global res
    try:
        res = subprocess.Popen(
            ["hug", "-f", "main.py"],
            cwd=os.path.abspath("../nftables-parser"),
            stdout=sys.stdout,
            stderr=sys.stderr,
        )
        print(f"[gunicorn] HUG iniciado: pid={res.pid} em {os.path.abspath('../nftables-parser')}")
    except FileNotFoundError as e:
        print(f"[gunicorn] hug não encontrado: {e}", file=sys.stderr)

def on_exit(server):
    if res:
        res.terminate()
