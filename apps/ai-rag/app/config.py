from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "AI Infrastructure RAG"

    # OpenAI-compatible LLM endpoint
    llm_base_url: str = "http://localhost:8000/v1"
    llm_api_key: str = "not-needed"
    llm_model: str = "Qwen/Qwen2.5-0.5B-Instruct"

    # Local embedding model
    embedding_model: str = "sentence-transformers/all-MiniLM-L6-v2"

    # Vector database
    chroma_path: str = "./data/chroma"
    collection_name: str = "infrastructure_docs"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()