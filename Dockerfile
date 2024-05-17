FROM alpine as cuesetup
RUN wget https://github.com/cue-lang/cue/releases/download/v0.7.1/cue_v0.7.1_linux_amd64.tar.gz && tar -zxf cue_v0.7.1_linux_amd64.tar.gz

FROM bitnami/airflow-worker:2.9.1-debian-12-r1

USER root

COPY --from=cuesetup /cue /usr/local/sbin/cue
COPY requirements.txt .

RUN pip install -r requirements.txt
USER 1001