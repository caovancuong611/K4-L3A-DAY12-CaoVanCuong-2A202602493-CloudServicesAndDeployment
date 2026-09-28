# ═══════════════════════════════════════════════════════════════════
# CP2 — Containerization (production-ready, multi-stage)
# ═══════════════════════════════════════════════════════════════════

# ---- Stage 1: builder — cài dependency ----
FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Stage 2: runtime — chỉ mang theo dependency đã build + source code ----
FROM python:3.11-slim AS runtime

# Tạo user thường, không chạy bằng root
RUN useradd --uid 10001 --no-create-home appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY . .

RUN chown -R appuser:appuser /app

USER appuser

ENV PORT=8000
EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import os,urllib.request; urllib.request.urlopen(f'http://127.0.0.1:{os.getenv(\"PORT\",\"8000\")}/health')" || exit 1

CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
