FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/marman:0.4.4 as marman
FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/om:7.1.2 as om
FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/pivnet:2.0.2 as pivnet
FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/tileinspect:0.5.10 as tileinspect
FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/cf:7.2.0 as cf
FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/isv-ci-toolkit:0.0.24 as toolkit

FROM us-west1-docker.pkg.dev/isv-tile-partners/partner-engineering/base-image:0.0.45
ARG DEPENDENCIES_FILE=/root/dependencies.log

# Copy binaries from dependent images
COPY --from=marman         /usr/local/bin/marman        /usr/local/bin/
COPY --from=om             /usr/local/bin/om            /usr/local/bin/
COPY --from=pivnet         /usr/local/bin/pivnet        /usr/local/bin/
COPY --from=tileinspect    /usr/local/bin/tileinspect   /usr/local/bin/
COPY --from=cf             /usr/local/bin/cf            /usr/local/bin/
COPY --from=toolkit        /usr/local/bin/*.sh          /usr/local/bin/

# Log dependency versions
RUN mrlog dependency --type binary --name marman --version $(marman version | cut -f3 -d" ") >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name om-cli --version $(om version) >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name pivnet-cli --version $(pivnet version) >> ${DEPENDENCIES_FILE} && \
    mrlog dependency --type binary --name tileinspect --version $(tileinspect version | cut -d" " -f3) >> ${DEPENDENCIES_FILE}  && \
    mrlog dependency --type binary --name cf-cli --version $(cf version | cut -d" " -f3) >> ${DEPENDENCIES_FILE}

ENV TILE_PATH=/input/tile.pivotal
ENV TILE_CONFIG_PATH=/input/config.json

# Copy files for this test
COPY [ "needs.json", "run.sh", "steps.sh", "${JOB_DIR}/" ]

# source the steps.sh commands, to simplify interactive development.
RUN ["/bin/bash", "-c", "echo \"\nsource ${JOB_DIR}/steps.sh\n\" >> ~/.bashrc"]
