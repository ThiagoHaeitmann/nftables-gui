import os
import sys
import signal
import subprocess

# Logs / timeouts básicos
workers = int(os.getenv("GUNICORN_WORKERS", "2"))
worker_class = "sync"
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))
graceful_timeout = int(os.getenv("GUNICORN_GRACEFUL_TIMEOUT", "30"))
loglevel = os.getenv("GUNICORN_LOGLEVEL", "info")
accesslog = "-"
errorlog = "-"

_parser_proc = None

def on_starting(server):
    """Sobe o backend parser (Hug) antes dos workers do Gunicorn."""
    global _parser_proc
    parser_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "nftables-parser"))
    cmd = [sys.executable, "-m", "hug", "-f", "main.py"]
    _parser_proc = subprocess.Popen(cmd, cwd=parser_dir, shell=False)
    server.log.info(f"Started parser (hug) pid={_parser_proc.pid} cwd={parser_dir}")

def on_exit(server):
    """Finaliza o parser com elegância ao sair."""
    global _parser_proc
    if _parser_proc and _parser_proc.poll() is None:
        try:
            server.log.info(f"Stopping parser (hug) pid={_parser_proc.pid}")
            _parser_proc.send_signal(signal.SIGTERM)
            try:
                _parser_proc.wait(timeout=10)
            except Exception:
                server.log.warning("Parser didn't exit in time; killing...")
                _parser_proc.kill()
        except Exception as e:
            server.log.warning(f"Error stopping parser: {e}")
