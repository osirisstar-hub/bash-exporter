FROM golang:1.11
RUN go get -d -v github.com/gree-gorey/bash-exporter/cmd/bash-exporter
WORKDIR /go/src/github.com/gree-gorey/bash-exporter/cmd/bash-exporter
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bash-exporter .

FROM alpine:3.7
WORKDIR /root/
RUN apk update && apk add bash coreutils openssh
RUN apk add --no-cache --virtual .build-deps \
        curl \
        tar \
    && curl --retry 7 -Lo /tmp/client-tools.tar.gz "https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.3.23-202005230952.git.1.b596217.el7/linux/oc.tar.gz"

RUN tar zxf /tmp/client-tools.tar.gz -C /usr/local/bin oc \
    && rm /tmp/client-tools.tar.gz \
    && apk del .build-deps

# ADDED: Resolve issue x509 oc login issue
RUN apk add --update ca-certificates
COPY --from=0 /go/src/github.com/gree-gorey/bash-exporter/cmd/bash-exporter/bash-exporter .
COPY ./examples/* /scripts/
CMD ["./bash-exporter"]
