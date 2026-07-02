FROM jenkins/jenkins:lts-jdk21

USER root

# Installing basic tools
RUN apt-get update && \
    apt-get install -y \
        git \
        curl \
        ansible \
        ca-certificates \
        lsb-release \
        gnupg && \
    rm -rf /var/lib/apt/lists/*

# Add the official Docker repo
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

RUN echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
    > /etc/apt/sources.list.d/docker.list

# Installing Docker CLI and Docker Compose
RUN apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# In order to make the project easy to run, we use the root user instead of the default user (jenkins)
# This allow us to ignore providing the right privileges to jenkins user to access Docker socket
# Kindly note that in a prodcution environment this is not the best practice
USER root

# To build the Jenkins container image:
# docker build -t my-jenkins .

# The recommended instruction to deploy the Jenkins container is this:
# docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v //var/run/docker.sock:/var/run/docker.sock my-jenkins