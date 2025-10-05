# Use 3.11 (ou 3.12) para manter numpy<2 sem compilar
FROM python:3.11-slim

# Pacotes do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    nftables \
    python3-nftables \
    libnftables1 \
  && rm -rf /var/lib/apt/lists/*

# Tornar visível o pacote instalado via APT para o Python da imagem oficial
ENV PYTHONPATH=/usr/lib/python3/dist-packages

WORKDIR /opt/app
COPY . /opt/app

# Dependências Python
RUN python -m pip install --upgrade pip && pip install \
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

# A app parece rodar a partir de nftables-frontend
WORKDIR /opt/app/nftables-frontend

# Comando de exemplo; ajuste se você já tem um entrypoint/cmd no compose
# Exponha a porta que o nginx usa como upstream (aqui 8000)
ENV PORT=8000
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "main:app"]
