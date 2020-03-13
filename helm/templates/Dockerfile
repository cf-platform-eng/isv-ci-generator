FROM cfplatformeng/base-image:0.0.29

RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

RUN curl -LO https://git.io/get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Log dependency versions
RUN mrlog dependency --type binary --name kubectl --version $(kubectl version | sed -e 's/.*\(GitVersion:".*"\), GitCommit:.*/\1/') >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name helm --version $(helm version | sed -e 's/.*\(SemVer:".*"\), GitCommit:.*/\1/') >> ${DEPENDENCIES_FILE} 

# Copy files for this test
COPY [ "needs.json", "run.sh", "steps.sh", "${JOB_DIR}/" ]

# source the steps.sh commands, to simplify interactive development.
RUN ["/bin/bash", "-c", "echo \"\nsource ${JOB_DIR}/steps.sh\n\" >> ~/.bashrc"]
