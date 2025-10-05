import os
import sys
import subprocess
import multiprocessing
import shutil

# Gunicorn básico
bind = "0.0.0.0:10001"
workers = max(2, multiprocessing.cpu_count() // 2) or 2
accesslog = "-"   # stdout
errorlog  = "-"   # stderr
loglevel  = "info"

# DIZ ao Gunicorn qual app carregar (ESSENCIAL)
# Se teu módulo WSGI for outro, troca "app:app" conforme o arquivo (ex.: wsgi:app).
wsgi_app = "app:app"

# Resolve caminho do executável 'hug'
HUG_BIN = shutil.which("hug") or "/usr/local/bin/hug"

# Processo do parser (HUG)
_hug_proc = None

def on_starting(server):
    """Sobe o microserviço do parser (HUG) antes dos workers."""
    global _hug_proc
    parser_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "../nftables-parser"))
    try:
        _hug_proc = subprocess.Popen(
            [HUG_BIN, "-f", "main.py"],
            cwd=parser_dir,
            stdout=sys.stdout,
            stderr=sys.stderr,
        )
        server.log.info(f"[gunicorn] HUG iniciado: pid={_hug_proc.pid} em {parser_dir}")
    except FileNotFoundError as e:
        server.log.error(f"[gunicorn] HUG não encontrado ({HUG_BIN}): {e}")
    except Exception as e:
        server.log.error(f"[gunicorn] Falha ao iniciar HUG: {e}")

def on_exit(server):
    """Encerra o HUG junto com o master do Gunicorn."""
    global _hug_proc
    if _hug_proc and _hug_proc.poll() is None:
        server.log.info("[gunicorn] Encerrando HUG...")
        _hug_proc.terminate()
