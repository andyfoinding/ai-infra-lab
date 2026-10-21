AI Infrastructure Lab

Cloud-Native AI/ML Infrastructure | GPU Computing | LLM Inference | MLOps | Observability

An end-to-end AI infrastructure engineering project focused on provisioning, deploying, securing, and monitoring machine learning and large language model inference workloads on Google Cloud Platform.

The project demonstrates infrastructure automation, GPU workload orchestration, containerized inference, CI/CD, observability, and cloud platform engineering.

1. Architecture Overview

The lab supports two inference architectures:

* Traditional ML inference: Containerized FastAPI application with an automated CI/CD pipeline targeting Google Cloud Run.
* GPU-accelerated LLM inference: NVIDIA L4 infrastructure running vLLM and the Qwen2.5-0.5B-Instruct model, with Prometheus, Grafana, and NVIDIA DCGM Exporter for observability.

Infrastructure Architecture

flowchart TD
    A[GitHub Repository] --> B[GitHub Actions]
    B --> C[Infrastructure Validation]
    B --> D[ML Inference CI/CD]
    D --> E[Google Artifact Registry]
    E --> F[Google Cloud Run]
    F --> G[FastAPI ML Inference]
    H[Terraform] --> I[Google Cloud Platform]
    I --> J[VPC and Subnet]
    J --> K[GPU Compute VM]
    K --> L[NVIDIA L4 GPU]
    L --> M[Docker + NVIDIA Container Toolkit]
    M --> N[vLLM Inference Server]
    N --> O[Qwen2.5-0.5B-Instruct]
    N --> P[Prometheus]
    L --> Q[NVIDIA DCGM Exporter]
    Q --> P
    P --> R[Grafana Dashboards]

Deployment status: The GPU VM architecture is implemented in Terraform but has not yet been successfully provisioned because of regional resource availability.

2. Technology Stack

Category	Technologies
Cloud Infrastructure	Google Cloud Platform
Infrastructure as Code	Terraform
Containers	Docker, Docker Compose
Container Orchestration	Kubernetes, GKE manifests
GPU Computing	NVIDIA L4, NVIDIA Container Toolkit
LLM Serving	vLLM, Hugging Face, Qwen2.5
ML Serving	Python, FastAPI, Uvicorn
CI/CD	GitHub Actions
Container Registry	Google Artifact Registry
Serverless Deployment	Google Cloud Run
Monitoring	Prometheus, Grafana
GPU Monitoring	NVIDIA DCGM Exporter
Security	IAM, OS Login, IAP-restricted SSH, container scanning
Load Testing	Locust

3. Repository Structure

ai-infra-lab/
├── .github/
│   └── workflows/
│       ├── ai-inference-ci.yml
│       └── gpu-infrastructure.yml
│
├── apps/
│   └── ai-inference/
│       ├── Dockerfile
│       ├── app.py
│       └── requirements.txt
│
├── kubernetes/
│   ├── vllm/
│   └── observability/
│
├── monitoring/
│   └── gpu-vm/
│       ├── docker-compose.yml
│       ├── prometheus.yml
│       └── grafana/
│           └── provisioning/
│               └── datasources/
│                   └── prometheus.yaml
│
├── scripts/
│   └── gpu/
│       ├── install-gpu-runtime.sh
│       ├── verify-gpu.sh
│       ├── deploy-vllm.sh
│       ├── deploy-monitoring.sh
│       └── test-vllm.sh
│
├── terraform/
│   ├── gpu-vm/
│   ├── network.tf
│   └── gke.tf
│
└── README.md

4. Infrastructure as Code

Terraform manages the cloud infrastructure required to support AI inference workloads.

Implemented infrastructure

* Custom Google Cloud VPC and subnet.
* Google Artifact Registry repository.
* GPU VM Terraform configuration.
* NVIDIA L4 GPU attachment.
* Ubuntu 22.04 boot disk.
* IAP-restricted SSH firewall access.
* Google Cloud OS Login.
* Automatic shutdown configuration to reduce unnecessary compute costs.

GPU VM Configuration

Resource	Configuration
Instance	vllm-gpu-lab
Machine Type	g2-standard-4
GPU	1 × NVIDIA L4
Operating System	Ubuntu 22.04
Boot Disk	100 GB pd-balanced
Networking	Custom VPC
SSH Access	Google Cloud IAP
Shutdown	Three-hour shutdown timer

Note: Automatic shutdown is configured but has not yet been verified on a running VM. Persistent disks may continue to incur charges after shutdown.

The GPU VM Terraform configuration uses a separate state from the main infrastructure configuration.

5. GPU-Accelerated LLM Inference

The GPU inference environment uses vLLM to serve an open-source language model through an OpenAI-compatible API.

Model

Qwen/Qwen2.5-0.5B-Instruct

Inference Components

* NVIDIA L4 GPU.
* NVIDIA GPU drivers.
* NVIDIA Container Toolkit.
* Docker.
* vLLM inference server.
* Persistent model cache.
* OpenAI-compatible REST API.

Inference Endpoints

Endpoint	Purpose
/health	Service health
/v1/models	Available models
/v1/chat/completions	LLM inference
/metrics	Prometheus-compatible metrics

GPU Deployment Scripts

scripts/gpu/install-gpu-runtime.sh
scripts/gpu/verify-gpu.sh
scripts/gpu/deploy-vllm.sh
scripts/gpu/test-vllm.sh

These scripts automate GPU runtime installation, hardware verification, container deployment, and inference testing.

Status: Scripts have passed Bash syntax validation. End-to-end GPU execution remains pending.

6. Monitoring and Observability

The project includes an observability stack designed to monitor both GPU infrastructure and LLM inference workloads.

Monitoring Components

Prometheus

* Collects application and infrastructure metrics.
* Scrapes vLLM inference metrics.
* Scrapes NVIDIA GPU metrics through DCGM Exporter.

NVIDIA DCGM Exporter

* GPU utilization.
* GPU memory consumption.
* GPU temperature.
* GPU power consumption.

Grafana

* Visualizes GPU and inference metrics.
* Uses an automatically provisioned Prometheus data source.
* Runs behind a localhost-bound interface.

Monitoring Architecture

flowchart LR
    A[NVIDIA L4 GPU] --> B[DCGM Exporter]
    C[vLLM Inference Server] --> D[vLLM Metrics]
    B --> E[Prometheus]
    D --> E
    E --> F[Grafana]

Deployment

The standalone GPU VM monitoring configuration is located in:

monitoring/gpu-vm/

The monitoring deployment script is:

scripts/gpu/deploy-monitoring.sh

Status: Docker Compose configuration has passed local validation. Runtime verification is pending GPU VM availability.

7. CI/CD Automation

GitHub Actions provides automated validation and deployment workflows.

AI Inference CI/CD

The traditional ML inference workflow includes:

1. Python application tests.
2. Docker image build.
3. Trivy container security scanning.
4. Google Cloud authentication using Workload Identity Federation.
5. Container image publishing to Artifact Registry.
6. Cloud Run deployment.

GPU Infrastructure Validation

The GPU infrastructure workflow validates:

* Terraform formatting.
* Terraform configuration.
* Bash deployment script syntax.

The workflow does not automatically provision GPU instances.

This separation helps prevent unintended GPU infrastructure costs.

8. Security and Cost Management

The infrastructure design incorporates several security and operational controls.

Security

* IAP-restricted SSH access.
* OS Login.
* Private application interfaces bound to localhost.
* Internal Docker networking.
* Non-root application execution where supported.
* GitHub Actions Workload Identity Federation.
* Container vulnerability scanning.
* Grafana administrator password supplied through an environment variable.

Cost Management

* GPU infrastructure provisioned only when required.
* Separate Terraform state for GPU resources.
* Automatic shutdown timer configuration.
* Limited persistent disk allocation.
* Cloud Run configured for scale-to-zero behavior.

The GPU shutdown timer is not a substitute for monitoring billing and deleting unused resources.

9. Project Status

Component	Status
GCP VPC and Subnet	Provisioned
Artifact Registry	Provisioned
FastAPI ML Inference	Application and CI/CD implemented
Cloud Run Deployment	Workflow configured
GPU Terraform Infrastructure	Validated
NVIDIA L4 VM	Pending cloud capacity
GPU Runtime Installation	Script prepared
vLLM Deployment	Script prepared
Prometheus	Configured
Grafana	Configured
NVIDIA DCGM Exporter	Configured
GPU Infrastructure CI	Passing
GPU Inference Testing	Pending
Kubernetes vLLM Manifests	Prepared
GPU Performance Benchmarking	Planned

10. Roadmap

Phase 1 — Infrastructure Foundation

* Provision GCP networking.
* Configure Artifact Registry.
* Implement Terraform GPU infrastructure.
* Configure GPU infrastructure validation.

Phase 2 — AI Inference

* Build containerized traditional ML inference application.
* Implement CI/CD workflow.
* Prepare vLLM GPU inference deployment.
* Provision NVIDIA L4 GPU VM.
* Verify NVIDIA drivers and container runtime.
* Execute LLM inference requests.

Phase 3 — Observability

* Configure Prometheus.
* Configure Grafana.
* Configure NVIDIA DCGM Exporter.
* Verify GPU metrics.
* Verify vLLM inference metrics.
* Build GPU utilization and inference dashboards.

Phase 4 — Performance and Reliability

* Execute inference load tests.
* Measure request latency and throughput.
* Analyze GPU utilization and memory consumption.
* Document performance bottlenecks.
* Evaluate scaling strategies.

Phase 5 — Kubernetes

* Deploy vLLM to a GPU-enabled Kubernetes cluster.
* Integrate Kubernetes GPU monitoring.
* Evaluate resource scheduling and GPU workload orchestration.

11. Engineering Objectives

This project explores the operational challenges involved in running production-oriented AI infrastructure:

* Provisioning GPU compute using Infrastructure as Code.
* Deploying containerized AI inference services.
* Operating NVIDIA GPU environments.
* Monitoring GPU resource utilization.
* Observing LLM inference performance.
* Automating infrastructure validation and application delivery.
* Implementing cloud security controls.
* Managing infrastructure cost and reliability.

The goal is to develop a reproducible platform engineering reference implementation for GPU-accelerated AI workloads.

⸻

Project status: Active development. GPU provisioning and end-to-end performance testing are pending cloud capacity.