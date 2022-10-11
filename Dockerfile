ARG         base=python:3.9-alpine

###

FROM        ${base} as build

ARG         version=
ARG         components="gcloud-crc32c"

RUN         wget -O - https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${version}-linux-x86_64.tar.gz | tar xz && \
            ./google-cloud-sdk/install.sh \
                --quiet \
                --override-components ${components} && \
            rm -rf \
                google-cloud-sdk/bin/anthoscli \
                google-cloud-sdk/bin/bootstrapping \
                google-cloud-sdk/platform/bundledpythonunix \
                google-cloud-sdk/platform/gsutil_py2

###

FROM        ${base}

ENV         PATH="/google-cloud-sdk/bin:$PATH"

ENTRYPOINT  ["gcloud"]
WORKDIR     /google-cloud-sdk

COPY        --from=build /google-cloud-sdk/bin /google-cloud-sdk/bin
COPY        --from=build /google-cloud-sdk/lib /google-cloud-sdk/lib
COPY        --from=build /google-cloud-sdk/platform /google-cloud-sdk/platform

RUN         apk add --virtual .run-deps \
                ca-certificates
