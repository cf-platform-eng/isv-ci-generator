FROM cfplatformeng/base-image:latest

ENV INPUT_DIR=/input
ENV OUTPUT_DIR=/input

# Copy binaries from dependent images
COPY --from=cfplatformeng/mrlog:latest          /usr/local/bin/mrlog /usr/local/bin/
COPY --from=cfplatformeng/needs:latest          /usr/local/bin/needs /usr/local/bin/

# Log dependency versions
ENV DEPENDENCIES_FILE=/root/dependencies.log

RUN mrlog dependency --type binary --name mrlog --version $(mrlog version | cut -f3 -d" ") >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name needs --version $(needs --version) >> ${DEPENDENCIES_FILE}

# Copy files for this app
COPY [ "needs.json", "run.sh", "steps.sh", "/test/" ]
RUN chmod a+x /test/run.sh
WORKDIR /test

CMD ["/bin/bash", "-c", "/test/run.sh"]
