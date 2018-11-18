FROM microsoft/powershell:ubuntu16.04

RUN curl -sSLf https://github.com/openfaas-incubator/of-watchdog/releases/download/0.4.2/of-watchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog
WORKDIR /root/

COPY server.ps1 server.ps1

COPY function function

HEALTHCHECK --interval=1s CMD [ -e /tmp/.lock ] || exit 1

ENV fprocess="pwsh ./server.ps1"
ENV cgi_headers="true"
ENV mode="http"
ENV upstream_url="http://127.0.0.1:8081"

EXPOSE 8080
CMD ["fwatchdog"]
