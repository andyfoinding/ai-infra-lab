import time
from functools import lru_cache
from prometheus_client import make_asgi_app

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

from app.config import get_settings
from app.llm import LLMClient
from app.retriever import DocumentRetriever
from app.metrics import (
    RAG_REQUESTS,
    RAG_RETRIEVAL_DURATION,
    RAG_INFERENCE_DURATION,
)


# Load application settings
settings = get_settings()


# Cache the retriever so the embedding model is not
# reloaded for every API request
@lru_cache(maxsize=1)
def get_retriever() -> DocumentRetriever:
    return DocumentRetriever()


# Initialize FastAPI application
app = FastAPI(
    title=settings.app_name,
    description="RAG-powered AI Infrastructure Troubleshooting Assistant",
    version="0.1.0",
)
# Expose Prometheus metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Request model
class QuestionRequest(BaseModel):
    question: str = Field(min_length=1)


# Source model
class Source(BaseModel):
    document: str
    chunk: int
    distance: float


# Response model
class QuestionResponse(BaseModel):
    question: str
    answer: str
    sources: list[Source]


# Health check endpoint
@app.get("/health")
def health():
    return {"status": "healthy"}


# RAG question-answering endpoint
@app.post("/ask", response_model=QuestionResponse)
def ask_question(request: QuestionRequest):

    RAG_REQUESTS.inc()
    try:
        # ----------------------------------
        # STEP 1: Initialize cached retriever
        # ----------------------------------

        retriever = get_retriever()

        # ----------------------------------
        # STEP 2: Measure retrieval latency
        # ----------------------------------

        retrieval_start = time.perf_counter()

        results = retriever.search(
            question=request.question,
            top_k=2,
        )

        retrieval_duration = time.perf_counter() - retrieval_start
        RAG_RETRIEVAL_DURATION.observe(retrieval_duration)
        print(
            f"[PERFORMANCE] Retrieval: "
            f"{retrieval_duration:.3f} seconds"
        )

        # ----------------------------------
        # STEP 3: Validate retrieved documents
        # ----------------------------------

        if not results:
            raise HTTPException(
                status_code=404,
                detail="No relevant documentation found.",
            )

        # ----------------------------------
        # STEP 4: Build RAG context
        # ----------------------------------

        context = "\n\n".join(
            f"Source: {result['source']}\n"
            f"Content: {result['content']}"
            for result in results
        )

        # ----------------------------------
        # STEP 5: Initialize LLM client
        # ----------------------------------

        llm = LLMClient()

        # ----------------------------------
        # STEP 6: Measure inference latency
        # ----------------------------------

        inference_start = time.perf_counter()

        answer = llm.generate(
            question=request.question,
            context=context,
        )

        inference_duration = time.perf_counter() - inference_start
        RAG_INFERENCE_DURATION.observe(inference_duration)
        print(
            f"[PERFORMANCE] Inference: "
            f"{inference_duration:.3f} seconds"
        )

        # ----------------------------------
        # STEP 7: Return response
        # ----------------------------------

        return QuestionResponse(
            question=request.question,
            answer=answer,
            sources=[
                Source(
                    document=result["source"],
                    chunk=result["chunk"],
                    distance=result["distance"],
                )
                for result in results
            ],
        )

    # Preserve intentional HTTP errors
    except HTTPException:
        raise

    # Handle unexpected application errors
    except Exception as exc:

        print(
            f"RAG request failed: "
            f"{type(exc).__name__}: {exc}"
        )

        raise HTTPException(
            status_code=503,
            detail="RAG service is temporarily unavailable.",
        ) from exc