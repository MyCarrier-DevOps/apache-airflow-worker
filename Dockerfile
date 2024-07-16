FROM alpine as cuesetup
RUN wget https://github.com/cue-lang/cue/releases/download/v0.7.1/cue_v0.7.1_linux_amd64.tar.gz && tar -zxf cue_v0.7.1_linux_amd64.tar.gz

FROM bitnami/airflow-scheduler:2.9.1-debian-12-r5 as py312

USER root
RUN apt-get update && apt-get install curl -y
RUN curl -SsLf "https://downloads.bitnami.com/files/stacksmith/python-3.12.3-8-linux-amd64-debian-12.tar.gz" -O; \
    mkdir /python3.12; \
    tar -zxf "python-3.12.3-8-linux-amd64-debian-12.tar.gz" -C /python3.12 --strip-components=2 --no-same-owner --wildcards '*/files' ;

FROM bitnami/airflow-worker:2.9.1-debian-12-r1

USER root

COPY --from=py312 /python3.12/python/bin/python3.12 /opt/bitnami/airflow/venv/bin
COPY --from=py312 /python3.12/python/bin/pip3.12    /opt/bitnami/airflow/venv/bin
COPY --from=py312 /python3.12/python/bin/python3.12 /opt/bitnami/python/bin/
COPY --from=py312 /python3.12/python/bin/pip3.12    /opt/bitnami/python/bin/
COPY --from=py312 /python3.12/python/lib/           /opt/bitnami/python/lib/

COPY --from=cuesetup /cue /usr/local/sbin/cue
COPY requirements.txt .

RUN apt-get update && apt-get install unixodbc unixodbc-dev -y

RUN apt-get update && apt-get install curl gpg -y
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg
RUN curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update; ACCEPT_EULA=Y apt-get install -y msodbcsql18; 

USER 1001
RUN . /opt/bitnami/airflow/venv/bin/activate && pip install -r requirements.txt; deactivate
ENTRYPOINT [ "/opt/bitnami/scripts/airflow-worker/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/airflow-worker/run.sh" ]