import mlflow
import mlflow.sklearn

from fastapi import FastAPI
from pydantic import BaseModel

from pathlib import Path

MODEL_PATH = Path(__file__).resolve().parent

model = mlflow.sklearn.load_model(str(MODEL_PATH))
# Create FastAPI application
app = FastAPI(title="AI Infrastructure Inference API")


class PredictionRequest(BaseModel):
    value: float


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/predict")
def predict(request: PredictionRequest):
    prediction = model.predict([[request.value]])

    return {
        "input": request.value,
        "prediction": float(prediction[0])
    }