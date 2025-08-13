FROM python:3.11-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
 && pip install --no-cache-dir --no-compile --prefix=/install -r requirements.txt

COPY app.py .

FROM python:3.11-slim
WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app/app.py .

# Remove tests, docs, caches to shrink size
RUN find /usr/local -name '__pycache__' -exec rm -rf {} + \
 && find /usr/local -name '*.pyc' -exec rm -f {} + \
 && find /usr/local -name '*.pyo' -exec rm -f {} + \
 && rm -rf /usr/local/lib/python*/site-packages/tests

ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1
EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]

