from pathlib import Path

import skops.io as sio
from fastapi import FastAPI
from pydantic import BaseModel

MODEL_PATH = Path(__file__).resolve().parent / "model.skops"

model = sio.load(MODEL_PATH)

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
        "prediction": float(prediction[0]),
    }