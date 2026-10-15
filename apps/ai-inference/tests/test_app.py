from fastapi.testclient import TestClient
from app import app

client = TestClient(app)


def test_health():
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}


def test_prediction():
    response = client.post(
        "/predict",
        json={"value": 10}
    )

    assert response.status_code == 200

    data = response.json()

    assert data["input"] == 10.0
    assert abs(data["prediction"] - 20.0) < 0.001