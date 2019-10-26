FROM cfplatformeng/base-image:latest

# Copy binaries from dependent images
COPY --from=cfplatformeng/mrlog:latest          /usr/local/bin/mrlog /usr/local/bin/
COPY --from=cfplatformeng/needs:latest          /usr/local/bin/needs /usr/local/bin/

RUN apt-get update && apt-get install -y apt-transport-https && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

RUN curl -LO https://git.io/get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Log dependency versions
ARG DEPENDENCIES_FILE=/root/dependencies.log
RUN mrlog dependency --type binary --name mrlog --version $(mrlog version | cut -f3 -d" ") >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name needs --version $(needs --version) >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name kubectl --version $(kubectl version | sed -e 's/.*\(GitVersion:".*"\), GitCommit:.*/\1/') >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name helm --version $(helm version | sed -e 's/.*\(SemVer:".*"\), GitCommit:.*/\1/') >> ${DEPENDENCIES_FILE} 

# Copy files for this test
COPY [ "needs.json", "run.sh", "steps.sh", "/test/" ]
RUN chmod a+x /test/run.sh
WORKDIR /test

CMD ["/bin/bash", "-c", "/test/run.sh"]
