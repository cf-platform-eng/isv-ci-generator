ARG BASE_IMAGE_VERSION=0.0.19
FROM cfplatformeng/base-image:${BASE_IMAGE_VERSION}

# Copy files for this app
COPY [ "needs.json", "run.sh", "steps.sh", "${JOB_DIR}/" ]
RUN chmod a+x ${JOB_DIR}/run.sh
