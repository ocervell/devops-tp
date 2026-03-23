# ---- Build stage ----
FROM python:3.12-slim AS base

# Bonne pratique : ne pas tourner en root
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

WORKDIR /app

# Copier uniquement les dépendances d'abord (optimisation cache Docker)
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copier le code source
COPY app/ .

# Changer le propriétaire des fichiers
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--timeout", "60", "main:app"]
