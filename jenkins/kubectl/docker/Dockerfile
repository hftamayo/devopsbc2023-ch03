FROM jenkins/jenkins:lts
USER root

# RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
# RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
# RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
# RUN getent group docker || groupadd docker && usermod -aG docker jenkins

# Find out the group ID of the docker group on the host
RUN DOCKER_SOCKET=/var/run/docker.sock && \
    DOCKER_GROUP=docker && \
    DOCKER_GID=$(stat -c '%g' $DOCKER_SOCKET) && \
    groupadd -for -g $DOCKER_GID $DOCKER_GROUP && \
    usermod -aG $DOCKER_GROUP jenkins

# Install Docker CLI
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh

#kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    echo "kubectl installed successfully"

#Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod +x get_helm.sh && \
    ./get_helm.sh && \
    echo "Helm installed successfully"

USER jenkins
