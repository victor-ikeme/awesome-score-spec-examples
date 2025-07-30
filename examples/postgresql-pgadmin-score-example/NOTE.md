# PostgreSQL and pgAdmin Demo

This project demonstrates a common database setup using Score. It defines a primary PostgreSQL database and a pgAdmin web interface for management as two distinct, interconnected workloads.

## Architecture

This project is defined as two separate Score workloads, which promotes a clean separation of concerns.

*   **`postgres-db-service` Workload**: A stateful service that runs the PostgreSQL database. It exposes its database port internally for other services to connect. Its configuration and credentials are provided by the environment.
*   **`pgadmin-ui-service` Workload**: A stateless service that runs the pgAdmin web interface. It declares a `service` dependency on `postgres-db-service`, which allows it to discover and connect to the database. This is the only service that exposes a public-facing port.

## Key Score Concepts

*   **Multi-Workload Project**: This example shows how to separate a primary service (the database) from a supporting tool (the UI) into independent `score.yaml` files.
*   **Service Dependencies (`type: service`)**: The `pgadmin-ui-service` explicitly declares its dependency on the `postgres-db-service`. The platform (e.g., `score-compose`) uses this to set up networking so pgAdmin can find the database.
*   **Secret Management**: All credentials for both PostgreSQL and pgAdmin are sourced from an `environment` resource, which is fulfilled by a local `.env` file. This is a security best practice that avoids hardcoding secrets.
*   **Stateful Services (`type: volume`)**: The `postgres-db-service` requires persistent storage, which is declared using a `volume` resource to ensure data survives restarts.
*   **Health Probes (`readinessProbe`)**: The `postgres-db-service` has a `readinessProbe` to ensure it is fully initialized and ready to accept connections before other services might try to connect.

## How to Run

1.  **Create a `.env` file:**
    Copy the `env.example` file and provide your desired credentials.
    ```bash
    cp .env.example .env
    # Edit .env and set your credentials
    ```

2.  **Generate the Compose File:**
    Use `score-compose` to generate a single `docker-compose.yml` from both Score files.
    ```bash
    score-compose generate *.yaml
    ```

3.  **Launch the Application:**
    ```bash
    docker compose up -d
    ```

4.  **Access the Application:**
    *   Open your web browser and navigate to **`http://localhost:5050`**.
    *   Log in to pgAdmin using the email and password you set in the `.env` file.
    *   Once logged in, you will need to manually add a new server connection. Use the hostname `postgres-db-service` and the PostgreSQL credentials from your `.env` file to connect.