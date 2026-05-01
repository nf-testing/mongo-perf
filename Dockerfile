# syntax=docker/dockerfile:1
FROM mongo:8.0

RUN groupadd -r mongo-shell && useradd -r -g mongo-shell mongo-shell

RUN apt-get -y update \
    && apt-get -y install python3 python3-pip \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workdir

COPY requirements.txt .

# Newer versions of Ubuntu (correctly) complain about global pip installations
# Since this is a container, we treat the whole thing as a virtual env...
ENV PIP_ROOT_USER_ACTION=ignore

# Also add the explicit option to "break" system packages, because container
RUN pip3 install --break-system-packages -r requirements.txt

COPY . .

# Setting the ownership of the /data dir, because this is not intended for use
# as a real MongoDB server container, and the defaults should Just Work
RUN chown -R mongo-shell:mongo-shell . && \
  chown -R mongo-shell:mongo-shell /data/

USER mongo-shell:mongo-shell

ENTRYPOINT ["python3", "benchrun.py"]
CMD []