# Use Python 3.11
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Python settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y setuptools wheel

# Copy FastAPI application
COPY app.py .

# Copy the registered MLflow model artifacts
COPY MLmodel .
COPY model.skops .
COPY conda.yaml .
COPY python_env.yaml .
COPY registered_model_meta .

# Run as a non-root user
RUN useradd --create-home appuser
USER appuser

# Expose API port
EXPOSE 8000

# Start inference server
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]