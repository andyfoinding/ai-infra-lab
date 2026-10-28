from prometheus_client import Counter, Histogram


# Total number of RAG requests
RAG_REQUESTS = Counter(
    "rag_requests_total",
    "Total number of RAG API requests",
)


# Time spent generating embeddings and searching ChromaDB
RAG_RETRIEVAL_DURATION = Histogram(
    "rag_retrieval_duration_seconds",
    "Time spent retrieving documents from ChromaDB",
)


# Time spent waiting for Ollama inference
RAG_INFERENCE_DURATION = Histogram(
    "rag_inference_duration_seconds",
    "Time spent generating LLM responses",
)