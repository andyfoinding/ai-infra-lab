from pathlib import Path

import chromadb
from sentence_transformers import SentenceTransformer

from app.config import get_settings


def chunk_text(text: str, chunk_size: int = 1200, overlap: int = 200):
    """Split documentation into chunks without breaking lines."""

    if chunk_size <= 0 or not 0 <= overlap < chunk_size:
        raise ValueError("Invalid chunk size or overlap")

    lines = text.splitlines(keepends=True)
    chunks = []
    current_chunk = ""

    for line in lines:
        if current_chunk and len(current_chunk) + len(line) > chunk_size:
            chunks.append(current_chunk.strip())

            # Preserve complete trailing lines as overlap
            trailing_lines = current_chunk.splitlines(keepends=True)
            overlap_lines = []
            overlap_length = 0

            for previous_line in reversed(trailing_lines):
                if overlap_length + len(previous_line) > overlap:
                    break

                overlap_lines.insert(0, previous_line)
                overlap_length += len(previous_line)

            current_chunk = "".join(overlap_lines)

        current_chunk += line

    if current_chunk.strip():
        chunks.append(current_chunk.strip())

    return chunks


def ingest_documents():
    """Load infrastructure documentation into ChromaDB."""

    settings = get_settings()

    docs_path = Path("data/docs")
    docs_path.mkdir(parents=True, exist_ok=True)

    client = chromadb.PersistentClient(path=settings.chroma_path)

    collection = client.get_or_create_collection(
        name=settings.collection_name
    )

    model = SentenceTransformer(settings.embedding_model)

    documents = []
    embeddings = []
    ids = []
    metadatas = []

    for file_path in sorted(docs_path.glob("*.md")):
        print(f"Processing: {file_path.name}")

        text = file_path.read_text(encoding="utf-8")

        chunks = chunk_text(text)

        if not chunks:
            continue

        chunk_embeddings = model.encode(chunks).tolist()

        for index, (chunk, embedding) in enumerate(
            zip(chunks, chunk_embeddings)
        ):
            documents.append(chunk)
            embeddings.append(embedding)
            ids.append(f"{file_path.stem}-{index}")
            metadatas.append({
                "source": file_path.name,
                "chunk": index,
            })

    if not documents:
        print("No documents found in data/docs/")
        return

    collection.upsert(
        documents=documents,
        embeddings=embeddings,
        ids=ids,
        metadatas=metadatas,
    )

    print(f"Successfully ingested {len(documents)} chunks.")


if __name__ == "__main__":
    ingest_documents()