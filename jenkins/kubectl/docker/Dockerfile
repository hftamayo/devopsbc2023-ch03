FROM jenkins/jenkins:lts
USER root

# RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
# RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
# RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
# RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io
# RUN getent group docker || groupadd docker && usermod -aG docker jenkins

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

# Add Jenkins user to Docker group at startup
RUN echo 'DOCKER_GID=$(stat -c "%g" /var/run/docker.sock)' >> /etc/profile && \
    echo 'groupadd -for -g $DOCKER_GID docker' >> /etc/profile && \
    echo 'usermod -aG docker jenkins' >> /etc/profile

# Copy entrypoint script into the image
COPY entrypoint.sh /entrypoint.sh

USER jenkins

ENTRYPOINT ["/entrypoint.sh"]