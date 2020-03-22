FROM golang:1.11
RUN go get -d -v github.com/gree-gorey/bash-exporter/cmd/bash-exporter
WORKDIR /go/src/github.com/gree-gorey/bash-exporter/cmd/bash-exporter
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o bash-exporter .

FROM alpine:3.7
WORKDIR /root/
RUN apk update && apk add bash
COPY --from=0 /go/src/github.com/gree-gorey/bash-exporter/cmd/bash-exporter/bash-exporter .
COPY ./examples/* /scripts/
CMD ["./bash-exporter"]
