from openai import OpenAI

from app.config import get_settings


class LLMClient:
    def __init__(self):
        settings = get_settings()

        self.model = settings.llm_model

        self.client = OpenAI(
            base_url=settings.llm_base_url,
            api_key=settings.llm_api_key,
            timeout=60.0,
        )

    def generate(self, question: str, context: str) -> str:
        """Generate an answer using retrieved documentation."""

        system_prompt = """
        You are an AI Infrastructure Troubleshooting Assistant.
        
        Answer the user's question using only the provided documentation.
        
        Rules:
        1. Give a concise, technically accurate answer.
        2. Start with the most likely causes.
        3. Provide no more than 5 troubleshooting steps.
        4. Do not repeat commands or explanations.
        5. Include Kubernetes commands only when relevant.
        6. Do not invent information or claim to have inspected a live system.
        7. If the documentation does not contain the answer, say so.
        8. Finish with a brief summary.
        
        Use this format:
        
        Likely Causes:
        - List the most relevant causes.
        
        Troubleshooting Steps:
        1. Provide a diagnostic action.
        2. Continue with additional actions if needed.
        
        Summary:
        Provide one sentence explaining what to check first.
        """

        response = self.client.chat.completions.create(
            model=self.model,
            messages=[
                {
                    "role": "system",
                    "content": system_prompt,
                },
                {
                    "role": "user",
                    "content": (
                        f"Documentation:\n{context}\n\n"
                        f"Question: {question}"
                    ),
                },
            ],
            temperature=0.0,
            max_tokens=350,
        )

        return response.choices[0].message.content or ""
