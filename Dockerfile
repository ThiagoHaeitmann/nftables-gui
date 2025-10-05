# Dockerfile (raiz do repo)
FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Sistema / nftables + bindings python
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      python3-nftables \
      libnftables1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY . /opt/app

# Dependências Python (pinos para compatibilidade com Hug/Falcon)
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

# App roda a UI a partir deste diretório
WORKDIR /opt/app/nftables-frontend

# Porta do Gunicorn exposta internamente
EXPOSE 10001

# Sobe o Gunicorn com a conf do projeto
ENTRYPOINT ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py"]
