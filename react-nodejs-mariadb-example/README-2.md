# Node.js, React, and MariaDB (Microservices) Demo

This project demonstrates a full-stack, three-tier microservices architecture using Score. It defines a React frontend, a Node.js backend, and a MariaDB database as three distinct and interconnected workloads.

## Architecture

This project models the security segmentation of the original `docker-compose.yml` by using explicit service dependencies.

*   **`mariadb-db-service`**: A standalone, stateful workload for the database. It does not expose any public ports and is considered to be on a "private" network.
*   **`nodejs-backend-service`**: The API layer. It is the only service that can access the database, as it declares a `service` dependency on `mariadb-db-service`. It exposes its own API ports.
*   **`react-frontend-service`**: The public-facing UI. It can only access the backend, as it declares a `service` dependency on `nodejs-backend-service`. It has no knowledge of or access to the database.

## Key Score Concepts

*   **Network Segmentation**: The separation into three workloads with specific `service` dependencies models the original `public` and `private` networks. `frontend` can only see `backend`, and `backend` can only see `db`.
*   **Multiple Ports**: The `nodejs-backend-service` demonstrates how to define multiple named ports in the `service.ports` block, one for the application and two for Node.js debugging.
*   **File and Directory Mounts**: The `backend` workload shows how to mount individual files (`package.json`) and directories (`src`) for a fine-grained live-reloading development setup.
*   **Secure Secret Management**: The password for the database is managed by Score and mounted as a file into the `backend` and `db` containers, a secure practice.

## How to Run

1.  **Create `.env` file:**
    ```bash
    cp .env.example .env
    # Edit .env and set a secure password
    ```

2.  **Build the Docker Images:**
    ```bash

    docker build -t nodejs-react-demo-frontend:latest ./frontend
    docker build -t nodejs-react-demo-backend:latest ./backend
    ```

3.  **Generate the Compose File:**
    ```bash
    score-compose generate *.yaml
    ```

4.  **Launch the Application:**
    ```bash
    docker compose up
    ```

5.  **Access the Application:**
    Open your web browser and navigate to **`http://localhost:3000`**.```

#### 5. `.env.example`