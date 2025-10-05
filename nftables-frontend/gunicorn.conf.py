# nftables-frontend/gunicorn.conf.py
import os, sys, subprocess

HUG_CWD = os.path.abspath("../nftables-parser")
HUG_CMD = ["python3", "-m", "hug", "-f", "main.py"]
res = None

def on_starting(server):
    global res
    try:
        print("[gunicorn] iniciando HUG com python3 -m hug em", HUG_CWD, file=sys.stderr)
        res = subprocess.Popen(HUG_CMD, cwd=HUG_CWD, stdout=sys.stdout, stderr=sys.stderr)
    except Exception as e:
        print(f"[gunicorn] falha ao iniciar HUG: {e}", file=sys.stderr)

def on_exit(server):
    try:
        if res and res.poll() is None:
            res.terminate()
    except Exception:
        pass
