FROM ubuntu:noble

RUN apt update \
    && apt install -y texlive-full texlive-extra-utils make git wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/tex-fmt
RUN wget https://github.com/WGUNDERWOOD/tex-fmt/releases/download/v0.5.2/tex-fmt-x86_64-linux.tar.gz \
    && tar -xzvf tex-fmt-x86_64-linux.tar.gz \
    && rm *.tar.gz

WORKDIR /data
