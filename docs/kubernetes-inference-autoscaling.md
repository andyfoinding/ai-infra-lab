# Kubernetes AI Inference Serving and Autoscaling

## 1. Project Overview

This project demonstrates deploying, scaling, and load-testing
a machine learning inference service on Kubernetes.

The objective was to validate CPU-based Horizontal Pod Autoscaling
(HPA) and measure inference performance under concurrent traffic.

## 2. Technology Stack

- Kubernetes (kind)
- Docker
- Python / FastAPI
- Scikit-learn
- Kubernetes Metrics Server
- Horizontal Pod Autoscaler (HPA)
- Locust
- macOS (Apple Silicon)

## 3. Architecture

```text
               Locust Load Generator
                         |
                         v
               Kubernetes Service
                    ClusterIP
                         |
                         v
                FastAPI Inference
                    Deployment
                         |
                         v
                AI Inference Pods
                         |
                         v
                  Metrics Server
                         |
                         v
                 Kubernetes HPA
                         |
                         v
                Replica Adjustment
```

The Metrics Server collects CPU utilization metrics from Kubernetes
nodes and pods. HPA uses those metrics to adjust the Deployment's
desired replica count.

## 4. Kubernetes Deployment

The inference application was deployed with:

- CPU request: 100m
- CPU limit: 500m
- Memory request: 256Mi
- Memory limit: 512Mi
- Readiness probe: /health
- Liveness probe: /health
- Service type: ClusterIP

The application exposes:

- GET /health
- POST /predict

Example request:

```json
{
  "value": 10
}
```

Expected response:

```json
{
  "input": 10.0,
  "prediction": 20.0
}
```

## 5. Horizontal Pod Autoscaling

HPA configuration:

| Parameter | Value |
|---|---|
| Minimum replicas | 1 |
| Maximum replicas | 5 |
| CPU utilization target | 60% |
| Scale-down stabilization | 60 seconds |

The autoscaler adjusts the number of inference pods based on
average CPU utilization relative to the configured CPU requests.

## 6. Load Testing

Locust was used to generate concurrent inference requests.

Test configuration:

| Parameter | Value |
|---|---|
| Concurrent users | 20 |
| Spawn rate | 2 users/second |
| Duration | 120 seconds |
| Endpoint | POST /predict |

### Performance Results

| Metric | Result |
|---|---|
| Total requests | 7,478 |
| Failed requests | 0 |
| Success rate | 100% |
| Average throughput | 62.54 requests/second |
| Average response time | 6 ms |
| Median latency (P50) | 4 ms |
| P95 latency | 9 ms |
| P99 latency | 18 ms |
| Maximum latency | 433 ms |

These results were obtained in a local Kubernetes environment
using port forwarding. They should not be interpreted as
production performance benchmarks.

## 7. Autoscaling Validation

The following scaling behavior was observed:

### Initial Scale-Down

Kubernetes reduced the Deployment from three replicas to one
because CPU utilization was below the configured target.

### Scale-Up Under Load

During the Locust experiment, Kubernetes generated this event:

```text
SuccessfulRescale
New size: 2; reason: cpu resource utilization
(percentage of request) above target
```

This confirmed that HPA automatically increased inference capacity
from one replica to two.

### Scale-Down After Load

After the load test completed, Kubernetes returned to one replica.

Final HPA status:

```text
TARGETS       MINPODS   MAXPODS   REPLICAS
cpu: 7%/60%   1         5         1
```

### Observed Scaling Sequence

```text
3 pods
   |
   | Low CPU utilization
   v
1 pod
   |
   | Locust inference traffic
   v
2 pods
   |
   | Traffic stops
   v
1 pod
```

## 8. Key Engineering Lessons

1. Kubernetes HPA requires a functioning resource metrics pipeline.
2. CPU requests provide the baseline for CPU utilization calculations.
3. Load testing validates application performance but does not
   automatically guarantee that autoscaling will occur.
4. Autoscaling behavior should be verified through Kubernetes
   metrics and scaling events.
5. Scale-down stabilization helps reduce unnecessary replica changes.
6. Lightweight inference models may require substantial request
   volume to generate enough CPU utilization for autoscaling.

## 9. Outcome

Successfully deployed a containerized machine learning inference
application on local Kubernetes and validated automatic scaling
under load.

The application handled 7,478 inference requests with zero failures.

Kubernetes automatically scaled from one to two replicas during
increased CPU demand and returned to one replica after the load
test completed.

This experiment demonstrates practical experience with
Kubernetes-based ML model serving, resource management,
performance testing, and horizontal autoscaling.