import chromadb
from sentence_transformers import SentenceTransformer

from app.config import get_settings


class DocumentRetriever:
    def __init__(self):
        settings = get_settings()

        self.client = chromadb.PersistentClient(
            path=settings.chroma_path
        )

        self.collection = self.client.get_collection(
            name=settings.collection_name
        )

        self.model = SentenceTransformer(
            settings.embedding_model
        )

    def search(self, question: str, top_k: int = 3):
        """Retrieve the most relevant documentation chunks."""

        question_embedding = self.model.encode(
            [question]
        ).tolist()

        results = self.collection.query(
            query_embeddings=question_embedding,
            n_results=top_k,
            include=["documents", "metadatas", "distances"],
        )

        matches = []

        for document, metadata, distance in zip(
            results["documents"][0],
            results["metadatas"][0],
            results["distances"][0],
        ):
            matches.append({
                "content": document,
                "source": metadata["source"],
                "chunk": metadata["chunk"],
                "distance": distance,
            })

        return matches


if __name__ == "__main__":
    retriever = DocumentRetriever()

    question = "Why is my Kubernetes GPU pod stuck in Pending?"

    print(f"\nQuestion: {question}\n")

    results = retriever.search(question)

    for index, result in enumerate(results, start=1):
        print(f"--- Result {index} ---")
        print(f"Source: {result['source']}")
        print(f"Distance: {result['distance']:.4f}")
        print(f"Content:\n{result['content']}\n")