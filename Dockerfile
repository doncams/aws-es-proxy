FROM golang:1.8-alpine

RUN echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && apk update

RUN apk add --no-cache glide@edge git g++ make

RUN export GO15VENDOREXPERIMENT=1 \
	&& mkdir -p $GOPATH/src/github.com/abutaha \
	&& cd $GOPATH/src/github.com/abutaha \
	&& git clone https://github.com/abutaha/aws-es-proxy \
	&& cd aws-es-proxy \
	&& glide install \
	&& go build github.com/abutaha/aws-es-proxy

RUN addgroup awsesproxy \
	&& adduser -D -H -G awsesproxy awsesproxy

RUN cp -a $GOPATH/src/github.com/abutaha/aws-es-proxy/aws-es-proxy /bin/aws-es-proxy
RUN chmod +x /bin/aws-es-proxy

RUN chown awsesproxy:awsesproxy /bin/aws-es-proxy

ADD ./resources/entrypoint.sh /bin/entrypoint.sh

RUN chmod +x /bin/entrypoint.sh \
	&& chown awsesproxy:awsesproxy /bin/aws-es-proxy

USER "awsesproxy"

ENTRYPOINT ["entrypoint.sh"]