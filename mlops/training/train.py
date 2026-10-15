import pickle
from pathlib import Path

import mlflow
import mlflow.sklearn
import numpy as np

from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

# Connect to our local MLflow server
mlflow.set_tracking_uri("http://127.0.0.1:5000")

# Create or select our experiment
mlflow.set_experiment("ai-inference-training")

# Prepare training data
X = np.array([[1], [2], [3], [4], [5]])
y = np.array([2, 4, 6, 8, 10])

# Start an MLflow experiment run
with mlflow.start_run():

    # Train the model
    model = LinearRegression()
    model.fit(X, y)

    # Evaluate the model
    predictions = model.predict(X)
    mse = mean_squared_error(y, predictions)

    # Log training information
    mlflow.log_param("model_type", "LinearRegression")
    mlflow.log_param("training_samples", len(X))
    mlflow.log_metric("mse", mse)

    # Save the model locally
    model_path = Path("model.pkl")

    with open(model_path, "wb") as file:
        pickle.dump(model, file)

    # Save the trained model to MLflow
    mlflow.sklearn.log_model(
        sk_model=model,
        name="linear-regression-model"
    )

    print(f"Model trained successfully. MSE: {mse}")
    print(f"Model saved to {model_path}")