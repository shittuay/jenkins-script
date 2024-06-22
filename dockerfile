# Stage 1: Build stagpython3 python3-pipe
FROM jenkins/jenkins:lts AS build

# Switch to the root user to install additional packages
USER root

# Install necessary packages: Docker CLI, git, curl (for Trivy installation), and Python
RUN apt-get update \
    && apt-get install -y curl git python3 python3-pip unzip gnupg2 \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod 755 kubectl \
    && mv kubectl /bin \
    && apt-get install -y docker.io \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

# Install Terraform
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://apt.releases.hashicorp.com focal main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform

# Install Kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash \
    && mv kustomize /usr/local/bin/kustomize

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

# Install AWS CLI
#RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
#    && unzip awscli-bundle.zip \
#    && ./awscli-bundle/install -b ~/bin/aws

# Verify the installation and path of Trivy, Terraform, Kustomize, Helm, Python, Docker, and pip
RUN which trivy && which terraform && which kustomize && which helm && which python3 && which docker && which pip3

# Stage 2: Final stage
FROM jenkins/jenkins:lts

# Switch to the root user
USER root

# Copy the necessary components from the build stage
COPY --from=build /bin/kubectl /bin/kubectl
COPY --from=build /usr/bin/docker /usr/bin/docker
COPY --from=build /usr/bin/trivy /usr/local/bin/trivy
COPY --from=build /usr/bin/python3 /usr/bin/python3
COPY --from=build /usr/bin/pip3 /usr/bin/pip3
COPY --from=build /usr/local/bin/kustomize /usr/local/bin/kustomize
COPY --from=build /usr/local/bin/helm /usr/local/bin/helm
COPY --from=build /usr/bin/terraform /usr/bin/terraform
#COPY --from=build /usr/local/bin/aws /usr/local/bin/aws
#COPY --from=build /usr/local/aws-cli /usr/local/aws-cli

# Ensure the Jenkins home directory exists and has the correct permissions
RUN mkdir -p /var/jenkins_home && chown -R root:root /var/jenkins_home

# Switch to the root user
USER root

RUN apt-get clean \
    && apt-get update \
    && apt-get install -y python3 python3-pip libpython3.11-dev

# Create a symbolic link for python
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN apt install python3.11-venv -y


# Install AWS CLI
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -b usr/local/bin/aws \
    && chown jenkins:jenkins /usr/local/bin/aws



# Switch to the Jenkins user
# USER jenkins

# Expose the default Jenkins port
EXPOSE 8080

# Expose the JNLP port
EXPOSE 50000

# Define the default command to run Jenkins
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD curl -f http://localhost:8080/login || exit 1 