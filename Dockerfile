# ---- Base Python 3.11, roda wheels de NumPy 1.26.x sem toolchain ----
FROM python:3.11-slim

# Evita prompts do apt
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Dependências do sistema para nftables e bindings
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      python3-nftables \
      libnftables1 \
 && rm -rf /var/lib/apt/lists/*

# Diretório de trabalho "raiz" do código
WORKDIR /opt/app

# Copia todo o repositório
COPY . /opt/app

# Dependências Python (pinos que funcionam bem juntos)
RUN python -m pip install --upgrade pip \
 && pip install \
      "gunicorn==23.0.0" \
      "flask==3.0.1" \
      "flask-bootstrap==3.3.7.1" \
      "flask_sqlalchemy==3.1.1" \
      "flask-migrate==4.0.7" \
      "flask-login==0.6.3" \
      "flask-wtf==1.2.1" \
      "email_validator" \
      "matplotlib" \
      "python-Levenshtein" \
      "requests" \
      "numpy<2" \
      "falcon<3" \
      "hug==2.6.1"

# A aplicação Flask está em nftables-frontend
WORKDIR /opt/app/nftables-frontend

# Porta interna usada pelo Gunicorn
EXPOSE 8000

# IMPORTANTE: ajuste "app:app" se o módulo/variável WSGI da sua app for diferente
# Exemplos comuns: "wsgi:app" ou "app:create_app()" com --factory
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
