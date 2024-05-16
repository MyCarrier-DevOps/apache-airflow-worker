FROM alpine as cuesetup
RUN wget https://github.com/cue-lang/cue/releases/download/v0.7.1/cue_v0.7.1_linux_amd64.tar.gz && tar -zxf cue_v0.7.1_linux_amd64.tar.gz

FROM bitnami/airflow:2.8.1-debian-11-r4

USER root

COPY --from=cuesetup /cue /usr/local/sbin/cue
COPY requirements.txt .

RUN pip install -r requirements.txt
USER 1001