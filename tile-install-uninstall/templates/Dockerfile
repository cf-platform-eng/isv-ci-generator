ARG MARMAN_VERSION=0.4.2
ARG OM_VERSION=4.4.2
ARG PIVNET_VERSION=0.0.79
ARG TILEINSPECT_VERSION=0.5.7
ARG CF_VERSION=6.49.0
ARG ISV_CI_TOOLKIT_VERSION=0.0.22
ARG BASE_IMAGE_VERSION=0.0.23

FROM cfplatformeng/marman:${MARMAN_VERSION} as marman
FROM cfplatformeng/om:${OM_VERSION} as om
FROM cfplatformeng/pivnet:${PIVNET_VERSION} as pivnet
FROM cfplatformeng/tileinspect:${TILEINSPECT_VERSION} as tileinspect
FROM cfplatformeng/cf:${CF_VERSION} as cf
FROM cfplatformeng/isv-ci-toolkit:${ISV_CI_TOOLKIT_VERSION} as toolkit

FROM cfplatformeng/base-image:${BASE_IMAGE_VERSION}

# Copy binaries from dependent images
COPY --from=marman         /usr/local/bin/marman        /usr/local/bin/
COPY --from=om             /usr/local/bin/om            /usr/local/bin/
COPY --from=pivnet         /usr/local/bin/pivnet        /usr/local/bin/
COPY --from=tileinspect    /usr/local/bin/tileinspect   /usr/local/bin/
COPY --from=cf             /usr/local/bin/cf            /usr/local/bin/
COPY --from=toolkit        /usr/local/bin/*.sh          /usr/local/bin/

# Log dependency versions
ARG DEPENDENCIES_FILE=/root/dependencies.log
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
