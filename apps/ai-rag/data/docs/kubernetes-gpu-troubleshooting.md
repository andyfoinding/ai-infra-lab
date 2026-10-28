Kubernetes GPU Troubleshooting Guide

GPU Pod Stuck in Pending

A Kubernetes pod requesting an NVIDIA GPU may remain in the Pending state when the scheduler cannot find a node with sufficient GPU resources.

Common causes include:

* No GPU-enabled worker nodes are available.
* The NVIDIA device plugin is not installed or functioning.
* All available GPUs are already allocated.
* Node selectors or node affinity rules do not match available GPU nodes.
* GPU nodes have taints that the pod does not tolerate.
* The pod requests more GPUs than a single eligible node can provide.

Diagnostic Commands

Check the pod status:

kubectl get pods -A

Inspect scheduling events:

kubectl describe pod <pod-name> -n <namespace>

Check GPU capacity:

kubectl describe nodes

Inspect GPU allocatable resources:

kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}'

Recommended Investigation

1. Inspect pod events for FailedScheduling.
2. Verify that GPU nodes are Ready.
3. Confirm that the NVIDIA device plugin is running.
4. Check GPU resource requests and allocatable capacity.
5. Inspect node selectors, affinity, taints, and tolerations.
6. Verify that GPU resources are not already fully allocated.

NVIDIA Device Plugin Issues

Kubernetes relies on the NVIDIA device plugin to advertise GPU resources to the scheduler.

If the plugin is missing or unhealthy, GPU nodes may not expose the nvidia.com/gpu resource.

Check the plugin:

kubectl get daemonsets -A

Inspect plugin logs:

kubectl logs -n <namespace> <device-plugin-pod>

Verify that the GPU driver is installed and functioning on the host:

nvidia-smi

CUDA Driver Compatibility

GPU workloads can fail when the installed NVIDIA driver does not support the CUDA runtime required by the application.

Common symptoms include:

* CUDA initialization errors.
* Container startup failures.
* GPU detection failures.
* Driver/runtime compatibility errors.

Recommended checks:

1. Run nvidia-smi on the GPU node.
2. Identify the installed NVIDIA driver version.
3. Check the CUDA version required by the workload.
4. Verify compatibility between the driver and CUDA runtime.
5. Review container logs for initialization failures.

GPU Utilization Is Low

Low GPU utilization does not necessarily indicate a GPU hardware problem.

Potential causes include:

* Insufficient inference traffic.
* Small inference batch sizes.
* CPU preprocessing bottlenecks.
* Slow storage or data loading.
* Network communication bottlenecks.
* Inefficient application configuration.

Recommended investigation:

1. Check GPU utilization using nvidia-smi.
2. Inspect GPU memory consumption.
3. Measure CPU utilization.
4. Check inference request throughput.
5. Review model batching configuration.
6. Inspect storage and network performance.

GPU Out-of-Memory Errors

GPU memory exhaustion occurs when the workload requires more GPU memory than is available.

Potential causes include:

* Large model weights.
* Excessive batch sizes.
* Long input sequences.
* High concurrency.
* Memory fragmentation.

Possible mitigations include:

* Reduce batch size.
* Reduce maximum sequence length.
* Limit concurrent requests.
* Use model quantization where supported.
* Select a GPU with more available memory.

Kubernetes GPU Node Recovery

GPU nodes may become unavailable because of driver failures, maintenance, or infrastructure problems.

Useful commands:

kubectl get nodes
kubectl describe node <node-name>
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets
kubectl uncordon <node-name>

Before returning a node to service:

1. Confirm that the node is healthy.
2. Verify that the NVIDIA driver is functioning.
3. Confirm that the NVIDIA device plugin advertises GPU capacity.
4. Check Kubernetes node conditions.
5. Return the node to scheduling using kubectl uncordon.