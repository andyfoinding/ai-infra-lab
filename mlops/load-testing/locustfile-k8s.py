from locust import HttpUser, task, between


class AIInferenceUser(HttpUser):
    wait_time = between(0.1, 0.5)

    @task
    def predict(self):
        with self.client.post(
            "/predict",
            json={"value": 10},
            catch_response=True
        ) as response:

            if response.status_code != 200:
                response.failure(
                    f"HTTP {response.status_code}"
                )

            elif response.json().get("prediction") != 20.0:
                response.failure("Incorrect prediction")

            else:
                response.success()