FROM golang:1.15.3-alpine as ssm-builder

ARG VERSION=1.2.279.0

RUN set -ex && apk add --no-cache make git gcc libc-dev curl bash zip && \
    curl -sLO https://github.com/aws/session-manager-plugin/archive/${VERSION}.tar.gz && \
    mkdir -p /go/src/github.com && \
    tar xzf ${VERSION}.tar.gz && \
    mv session-manager-plugin-${VERSION} /go/src/github.com/session-manager-plugin && \
    cd /go/src/github.com/session-manager-plugin && \
    make release

# see https://hub.docker.com/r/hashicorp/packer/tags for all available tags
FROM hashicorp/packer:light@sha256:f795aace438ef92e738228c21d5ceb7d5dd73ceb7e0b1efab5b0e90cbc4d4dcd

COPY --from=ssm-builder /go/src/github.com/session-manager-plugin/bin/linux_amd64_plugin/session-manager-plugin /usr/local/bin/

RUN apk add ansible=2.10.7-r0

COPY "entrypoint.sh" "/entrypoint.sh"

ENTRYPOINT ["/entrypoint.sh"]
