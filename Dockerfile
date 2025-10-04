FROM python:3.13-bookworm

LABEL org.opencontainers.image.source="https://github.com/DZ-IO/nftables-gui"
LABEL org.opencontainers.image.description="Web UI para configurar nftables (com suporte a Docker)"
LABEL org.opencontainers.image.licenses="GPL-3.0-or-later"

COPY . /opt/app
WORKDIR /opt/app/nftables-frontend

# ▼▼ AQUI: adiciona 'hug' e faz o symlink /usr/bin/hug -> /usr/local/bin/hug
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
      hug \
 && apt-get update \
 && apt-get install -y --no-install-recommends nftables iproute2 \
 && ln -s /usr/local/bin/hug /usr/bin/hug \
 && rm -rf /var/lib/apt/lists/* /var/cache/* /var/log/* /tmp/*

VOLUME ["/opt/app/nftables-frontend/instance","/opt/app/nftables-frontend/static/img"]
ENTRYPOINT  ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py"]
