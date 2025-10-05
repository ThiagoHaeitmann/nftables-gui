# Dockerfile (projeto raiz)
FROM python:3.13-slim

# Sistema / nftables e bindings Python
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      python3-nftables \
      libnftables1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY . /opt/app

# Bibliotecas Python (sem numpy/matplotlib)
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
      "python-Levenshtein" \
      "requests" \
      "falcon<3" \
      "hug==2.6.1"

# A app roda daqui
WORKDIR /opt/app/nftables-frontend

# Volumes como no seu setup
VOLUME ["/opt/app/nftables-frontend/instance","/opt/app/nftables-frontend/static/img"]

# Gunicorn (módulo/arquivo definido no gunicorn.conf.py)
ENTRYPOINT ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py"]
