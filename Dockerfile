FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore

# Binários p/ chamar 'nft' (a UI invoca via shell)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      nftables \
      python3-nftables \
      libnftables1 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app
COPY . /opt/app

# Dependências Python
# - numpy<2 para evitar np.unicode_
# - falcon<3 p/ compat com hug 2.x
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

# Porta interna do Gunicorn
WORKDIR /opt/app/nftables-frontend
EXPOSE 10001

# Sobe o Gunicorn usando a config (que já define wsgi_app)
ENTRYPOINT ["/usr/local/bin/gunicorn","-c","gunicorn.conf.py"]
