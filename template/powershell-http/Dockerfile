FROM openfaas/classic-watchdog:0.18.0 as watchdog

FROM microsoft/powershell:ubuntu-xenial as ship

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

COPY server.ps1 server.ps1

COPY function function

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

ENV fprocess="pwsh ./server.ps1"
ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:8081"

EXPOSE 8080
CMD ["fwatchdog"]
