FROM openfaas/of-watchdog:0.7.2 as watchdog

FROM mcr.microsoft.com/powershell:centos-7 as ship

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

COPY server.ps1 server.ps1

COPY function function

RUN adduser --system --no-create-home --uid 10001 app

USER 10001

ENV fprocess="pwsh ./server.ps1"
ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:8082"

EXPOSE 8080

HEALTHCHECK --interval=3s CMD [ -e /tmp/.lock ] || exit 1

CMD ["fwatchdog"]
