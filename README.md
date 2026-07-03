# Key Features:
Dockerized Flask and Nginx application.
Nginx configured as a reverse proxy for the Flask application.
Automated CI/CD pipeline using Jenkins.
Docker image publishing to Docker Hub.
Automated deployment to an AWS EC2 instance using Ansible.
Docker Compose orchestration for multi-container deployment.
Health checks and functional validation during the CI pipeline.
Infrastructure automation with Ansible playbooks.

# Project Overview

## The Application

This project demonstrates a containerized web application built with **Flask**, **Nginx**, and **Docker Compose**.

The application consists of two containers:

* **Flask container:** Runs a Python Flask application that collects system resource usage (CPU, memory, and other metrics) from the running Flask container and renders the information on a web page.
* **Nginx container:** Acts as a reverse proxy. It receives incoming HTTP requests and forwards them to the Flask application.

The request flow is:

```
Client → Nginx → Flask
```

Both containers are orchestrated using **Docker Compose**, allowing the application to be deployed with a single command.

After cloning this repository, the application can be deployed locally or on an AWS EC2 instance, using Docker Compose.

---

## CI/CD Pipeline

This project also includes a **Jenkins pipeline** that automates the build, testing, and deployment process.

The pipeline performs the following stages:

* Checkout – Retrieves the latest source code from the GitHub repository.
* Build – Builds the Flask and Nginx Docker images.
* Start Containers – Starts the application locally inside the Jenkins environment.
* Health Check – Verifies that the application is reachable through Nginx.
* Functional Test – Confirms that the expected web page is served correctly.
* Docker Login – Authenticates Jenkins with Docker Hub.
* Push Images – Pushes the latest Docker images to Docker Hub.
* Deploy (Ansible) – Jenkins executes an Ansible playbook that connects to the EC2 instance via SSH, pulls the latest Docker images from Docker Hub, and updates the running application using Docker Compose.
* Verify Deployment – Confirms that the application is running successfully after deployment.

The deployment server (EC2) hosts the same Docker Compose application, allowing Jenkins to automatically update the running containers whenever a new version is deployed.

The Jenkins instance itself runs inside a Docker container on a local machine and includes the required Docker tools to execute the pipeline.

The deployment workflow is illustrated below:

```
Developer
    │ 
    ▼ 
 Git Push
    │ 
    ▼ 
GitHub Repository
    │ 
    ▼ 
Jenkins Pipeline 
    │ 
    ├── Checkout 
    ├── Build 
    ├── Health Check 
    ├── Functional Test 
    ├── Docker Login 
    ├── Push Images to Docker Hub 
    └── Deploy with Ansible 
                │ 
                ▼ 
            AWS EC2 Instance 
                │ 
            docker compose pull 
                │ 
            docker compose up -d 
                │ 
                ▼ 
            Updated Running Application
```

This project demonstrates the integration of containerization, reverse proxy configuration, automated testing, and continuous deployment using Docker, Docker Compose, Jenkins, Nginx, Flask, GitHub, DockerHub, Ansible and AWS EC2.

# Project Structure

* **`flask/`** – Contains the Flask application, including the Python source code and HTML templates used to collect and display system resource usage.
* **`nginx/`** – Contains the Nginx configuration files, including the reverse proxy configuration used to forward requests to the Flask application.
* **`Dockerfile`** – Defines the custom Jenkins image used to run the CI/CD pipeline locally with the required Docker tools installed.
* **`Jenkinsfile`** – Defines the Jenkins CI/CD pipeline, including the build, testing, and deployment stages.
* **`docker-compose.yml`** – Defines and orchestrates the Flask and Nginx containers.
* **`ansible/`** - Contains the Ansible configuration, inventory, and deployment playbook used by Jenkins during the CD stage.

# Running the Application

From the project's root directory, build the Docker images:

```bash
docker compose build
```

Start the application:

```bash
docker compose up -d
```

# AWS EC2 Requirements

To deploy the application using the CD stage of the Jenkins pipeline, an AWS EC2 instance must be configured with the following requirements:

## Operating System

* Ubuntu 24.04 LTS (recommended)

## Required Software

The following software must be installed on the EC2 instance:

* Ubuntu
* Git
* Docker Engine
* Docker Compose
* The project repository cloned on the instance.
* The ubuntu user added to the docker group.
* Port 22 open for SSH.
* Port 80 open for HTTP traffic.
* SSH access configured between Jenkins and the EC2 instance.
* The EC2 instance added to the Ansible inventory (ansible/inventory.ini)

Example installation:

```bash
sudo apt update
sudo apt install -y git docker.io docker-compose-v2
sudo usermod -aG docker ubuntu
```

> **Note:** After adding the `ubuntu` user to the `docker` group, log out and log back in (or restart the instance) for the changes to take effect.

## Project Setup

Clone this repository onto the EC2 instance:

```bash
git clone https://github.com/marcosolano21/ci-cd-project-docker-jenkins-ec2.git
```

Build and start the application:

```bash
cd ci-cd-project-docker-jenkins
docker compose up -d --build
docker compose up -d
```

Once the containers are running, the application should be accessible from:
```text
http://<EC2_PUBLIC_IP>
```

## SSH Access for Jenkins
For the deployment stage to work, Jenkins must be able to connect to the EC2 instance via SSH.


# Accessing the Application

### Local Deployment

If you are running the application locally, open your browser and navigate to:

```text
http://localhost
```

### AWS EC2 Deployment

If the application is deployed on an AWS EC2 instance, access it using the instance's public IP address:

```text
http://<EC2_PUBLIC_IP>
```


# Additional Instructions

## Build the Jenkins Docker Image

To build the custom Jenkins image used for the CI/CD pipeline, run on project´s root directory:

```bash
docker build -t my-jenkins .
```

## Run the Jenkins Container

To start the Jenkins container with the required Docker socket and persistent Jenkins data, run:

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v //var/run/docker.sock:/var/run/docker.sock \
  my-jenkins
```

> **Note:** The Docker socket is mounted into the Jenkins container so that Jenkins can execute Docker and Docker Compose commands on the host machine. The `jenkins_home` volume persists Jenkins configuration, installed plugins, credentials, and job data across container restarts.
>
> **Windows (Docker Desktop):** Use the command above, which mounts the Docker socket using `//var/run/docker.sock`.
>
> **Linux:** Replace the Docker socket mount with:
>
> ```bash
> -v /var/run/docker.sock:/var/run/docker.sock
> ```
>
> The remainder of the `docker run` command stays the same.


# GitHub Webhook Configuration

To trigger the Jenkins pipeline automatically whenever code is pushed to the repository, configure a webhook between GitHub and Jenkins.

> **Note:** If Jenkins is running on your local machine (`localhost`), GitHub cannot reach it because the webhook endpoint must be publicly accessible. For automatic pipeline execution, Jenkins must be exposed to the internet (for example, by running it on an AWS EC2 instance or by using a tunneling service such as ngrok or Cloudflare Tunnel).

Once the webhook is configured successfully, every `git push` to the configured branch will automatically trigger the Jenkins CI/CD pipeline without requiring a manual intervention.
