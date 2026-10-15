# AI Inference Performance Optimization

## 1. Objective

Optimize a machine learning inference service deployed on Google Cloud Run while maintaining scale-to-zero behavior and minimizing infrastructure costs.

## 2. Architecture

- Model: scikit-learn LinearRegression
- Model registry: MLflow
- Model serving: FastAPI
- Containerization: Docker
- Container registry: Google Artifact Registry
- Deployment: Google Cloud Run
- CI/CD: GitHub Actions
- Security scanning: Trivy
- Load testing: Locust
- Observability: Google Cloud Logging and Monitoring

## 3. Initial Problem

A 60-second Locust test with two virtual users revealed:

- 42 requests
- 1 HTTP 500 error
- P95 latency of approximately 4,200 ms
- Maximum latency of 17,477 ms

Cloud Run logs identified the failure:

"The request was aborted because there was no available instance."

The failure occurred while Cloud Run was starting an instance.

## 4. Root Cause

The service was configured with:

- Minimum instances: 0
- Maximum instances: 1
- Container concurrency: 1

During scale-from-zero, an instance was not available to handle one incoming request.

The original container also imported MLflow to load the inference model, increasing the dependencies required at startup.

## 5. Optimization

Changes implemented:

1. Replaced MLflow model loading with direct skops loading.
2. Removed MLflow, pandas, and PyArrow from direct inference dependencies.
3. Rebuilt and tested the optimized Docker image.
4. Validated health and prediction endpoints.
5. Deployed through GitHub Actions.

MLflow remains part of the model training and registration workflow.

## 6. Performance Results

| Metric | Before | After |
|---|---:|---:|
| Docker image disk usage | 1.29 GB | 136 MB |
| Autoscaling startup duration | ~17.1 sec | 4.61 sec |
| Total requests | 42 | 51 |
| Failed requests | 1 | 0 |
| Median latency | 43 ms | 44 ms |
| Average latency | 796 ms | 212 ms |
| P95 latency | 4,200 ms | 72 ms |
| Maximum latency | 17,477 ms | 4,829 ms |

Observed startup duration decreased by approximately 73%.

These results come from two small load tests. They do not establish production availability or statistically reliable performance guarantees.

## 7. Key Engineering Lessons

- Successful deployment does not guarantee reliable inference.
- Scale-to-zero introduces cold-start considerations.
- Training and inference environments should have separate dependencies.
- Container optimization can reduce startup overhead.
- Load testing helps expose infrastructure availability problems.
- Cloud Logging can distinguish application failures from infrastructure-level errors.
- Performance improvements should be validated through measurement.

## 8. Future Improvements

- Repeat cold-start measurements across multiple instances.
- Add structured application logging.
- Implement model version reporting.
- Evaluate dedicated least-privilege Cloud Run service accounts.
- Expand load testing with controlled concurrency.
- Add performance regression testing to CI/CD.