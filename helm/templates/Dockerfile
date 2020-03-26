FROM cfplatformeng/base-image:0.0.30

# Install kubectl
RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Install helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# Log dependency versions
ARG DEPENDENCIES_FILE=/root/dependencies.log
RUN mrlog dependency --type binary --name kubectl --version $(kubectl version --client --short | sed -e 's/Client Version: //') >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name helm --version $(helm version --short) >> ${DEPENDENCIES_FILE}

# Copy files for this test
COPY [ "needs.json", "run.sh", "steps.sh", "${JOB_DIR}/" ]

# source the steps.sh commands, to simplify interactive development.
RUN ["/bin/bash", "-c", "echo \"\nsource ${JOB_DIR}/steps.sh\n\" >> ~/.bashrc"]
