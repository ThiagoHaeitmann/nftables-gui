# Base sólida com APT estável
FROM python:3.12-bookworm

LABEL org.opencontainers.image.source="https://github.com/DZ-IO/nftables-gui"
LABEL org.opencontainers.image.description="Web UI para configurar nftables (com suporte a Docker)"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

# Copia código
COPY . /opt/app
WORKDIR /opt/app/nftables-frontend

# Dependências Python + sistema (apenas o necessário)
RUN pip install --no-cache-dir \
      gunicorn \
      flask==3.0.1 \
      flask-bootstrap==3.3.7.1 \
      flask_sqlalchemy==3.1.1 \
      flask-migrate==4.0.7 \
      flask-login==0.6.3 \
      flask-wtf==1.2.1 \
      email_validator \
      matplotlib \
      python-Levenshtein \
      requests \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      iproute2 \
 && rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* /tmp/*

# Persistência padrão do app
VOLUME ["/opt/app/nftables-frontend/instance","/opt/app/nftables-frontend/static/img"]

# Entrypoint do servidor
ENTRYPOINT ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py"]
