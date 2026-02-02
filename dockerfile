FROM debian:latest
RUN apt-get update && apt-get install -y \
    gcc \
    valgrind \
    scons \
    clang-format \
    procps \
    curl
    
RUN useradd --create-home --shell /bin/bash alice

USER alice
WORKDIR /home/alice
