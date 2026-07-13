FROM alpine:3.24

WORKDIR /app

RUN apk add --no-cache lighttpd

COPY index.html.template entrypoint.sh lighttpd.conf ./

RUN chmod +x entrypoint.sh

RUN addgroup --system --gid 1001 static
RUN adduser --system --uid 1001 static
RUN chown -R static:static /app

USER static

ENTRYPOINT ["./entrypoint.sh"]
