# Base estável p/ HUG/Falcon (tem cgi e distutils)
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore

# deps de sistema p/ nftables
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      python3-nftables \
      libnftables1 \
 && rm -rf /var/lib/apt/lists/*

# cópia do código
WORKDIR /opt/app
COPY . /opt/app

# deps python
# - numpy<2 porque hug usa numpy.unicode_
# - falcon<3 porque hug depende da 2.x
RUN python -m pip install --upgrade pip \
 && pip install \
      gunicorn==23.0.0 \
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
      "numpy<2" \
      "falcon<3" \
      "hug==2.6.1" \
 && ln -s /usr/local/bin/hug /usr/bin/hug

# roda a app no diretório do frontend
WORKDIR /opt/app/nftables-frontend

# porta da app (Dokploy/Traefik vão apontar pra ela)
EXPOSE 10001

# CHAVE: dizer ao gunicorn qual app carregar
ENTRYPOINT ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py","app:app"]
