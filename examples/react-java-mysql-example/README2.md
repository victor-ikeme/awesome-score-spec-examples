# React, Spring Boot, and MariaDB (Microservices) Demo

This project demonstrates a modern, full-stack microservices architecture using Score. It defines the application as three distinct workloads: a React frontend, a Spring Boot backend API, and a MariaDB database.

## Architecture

*   **`mariadb-db-service`**: A standalone, stateful workload that runs the MariaDB database. It uses a `readinessProbe` to ensure it's fully healthy before other services can connect.
*   **`spring-backend-service`**: The stateless API layer. It declares a `service` dependency on the `mariadb-db-service` and consumes the database password via a mounted file.
*   **`react-frontend-service`**: The user-facing web application. It declares a `service` dependency on the `spring-backend-service` to make API calls. This is the only service that exposes a port to the public.

## Key Score Concepts

*   **Multi-Workload Architecture**: Separates the database, backend, and frontend into three independent `score.yaml` files, promoting a clean microservices design.
*   **Health Probes (`readinessProbe`)**: The `mariadb-db-service` translates the `healthcheck` from the original `docker-compose.yml` into a `readinessProbe`. This is a critical feature that prevents the `backend` from starting its connection attempts until the database is fully initialized and healthy.
*   **Secure Secret Mounting (`containers.files`)**: Both the `db` and `backend` containers securely mount the database password as a file, avoiding exposure in environment variables.
*   **Volume Mounts for Development**: The `frontend` workload defines volumes for mounting source code and caching `node_modules`, enabling a live-reloading development workflow.

## How to Run

1.  **Create `.env` file:**
    ```bash
    cp .env.example .env
    # Edit .env and set a secure password
    ```

2.  **Build the Docker Images:**
    ```bash
    docker build -t react-spring-demo-frontend:latest ./frontend
    docker build -t react-spring-demo-backend:latest ./backend
    ```

3.  **Generate the Compose File:**
    Generate a single `docker-compose.yml` from all three Score files.
    ```bash
    score-compose generate *.yaml
    ```

4.  **Launch the Application:**
    ```bash
    docker compose up
    ```

5.  **Access the Application:**
    Open your web browser and navigate to **`http://localhost:3000`**. The React application will load and make API calls to the Spring Boot backend, which will query the MariaDB database.# React, Spring Boot, and MariaDB (Microservices) Demo

This project demonstrates a modern, full-stack microservices architecture using Score. It defines the application as three distinct workloads: a React frontend, a Spring Boot backend API, and a MariaDB database.

## Architecture

*   **`mariadb-db-service`**: A standalone, stateful workload that runs the MariaDB database. It uses a `readinessProbe` to ensure it's fully healthy before other services can connect.
*   **`spring-backend-service`**: The stateless API layer. It declares a `service` dependency on the `mariadb-db-service` and consumes the database password via a mounted file.
*   **`react-frontend-service`**: The user-facing web application. It declares a `service` dependency on the `spring-backend-service` to make API calls. This is the only service that exposes a port to the public.

## Key Score Concepts

*   **Multi-Workload Architecture**: Separates the database, backend, and frontend into three independent `score.yaml` files, promoting a clean microservices design.
*   **Health Probes (`readinessProbe`)**: The `mariadb-db-service` translates the `healthcheck` from the original `docker-compose.yml` into a `readinessProbe`. This is a critical feature that prevents the `backend` from starting its connection attempts until the database is fully initialized and healthy.
*   **Secure Secret Mounting (`containers.files`)**: Both the `db` and `backend` containers securely mount the database password as a file, avoiding exposure in environment variables.
*   **Volume Mounts for Development**: The `frontend` workload defines volumes for mounting source code and caching `node_modules`, enabling a live-reloading development workflow.

## How to Run

1.  **Create `.env` file:**
    ```bash
    cp .env.example .env
    # Edit .env and set a secure password
    ```

2.  **Build the Docker Images:**
    ```bash
    docker build -t react-spring-demo-frontend:latest ./frontend
    docker build -t react-spring-demo-backend:latest ./backend
    ```

3.  **Generate the Compose File:**
    Generate a single `docker-compose.yml` from all three Score files.
    ```bash
    score-compose generate *.yaml
    ```

4.  **Launch the Application:**
    ```bash
    docker compose up
    ```

5.  **Access the Application:**
    Open your web browser and navigate to **`http://localhost:3000`**. The React application will load and make API calls to the Spring Boot backend, which will query the MariaDB database.