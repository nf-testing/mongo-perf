# syntax=docker/dockerfile:1
FROM --platform=${TARGETPLATFORM} mongo:7
ARG TARGETPLATFORM

RUN groupadd -r mongo-shell && useradd -r -g mongo-shell mongo-shell

RUN apt-get -y update \
    && apt-get -y install python3 python3-pip \
    && apt-get clean \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/*

# Based on the target arch, copy the relevant `mongo` 5.0.32 binary to /usr/bin
COPY --chmod=0755 mongo-bin/${TARGETPLATFORM}/mongo /usr/bin

# Please don't judge me for this one: install libssl-1.1 packages from Bionic
# The `mongo` binary is dynamically linked!
COPY libssl-pkgs/${TARGETPLATFORM}/libssl*.deb /tmp
RUN dpkg -i /tmp/libssl*.deb && rm -f /tmp/libssl*.deb

WORKDIR /workdir

COPY requirements.txt .

RUN pip3 install -r requirements.txt

# Copy all files in this directory, _except_ the `mongo` binaries dir
COPY --exclude=mongo-bin --exclude=libssl-pkgs . .

# Setting the ownership of the /data dir, because this is not intended for use
# as a real MongoDB server container, and the defaults should Just Work
RUN chown -R mongo-shell:mongo-shell . && \
  chown -R mongo-shell:mongo-shell /data/

USER mongo-shell:mongo-shell

ENTRYPOINT ["python3", "benchrun.py"]
CMD []