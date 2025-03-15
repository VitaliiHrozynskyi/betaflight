FROM ubuntu:22.04
MAINTAINER betaflight

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/betaflight/docker-betaflight-build.git
# - vim docker-betaflight-build/Dockerfile
# - docker build -t betaflight-build docker-betaflight-build
# - cd <your betaflight source dir>
# - docker run --rm -ti -v `pwd`:/opt/betaflight betaflight-build

RUN DEBIAN_FRONTEND=noninteractive apt update
RUN apt -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt install -y build-essential libblocksruntime-dev libtool git curl clang-12 gcc-arm-none-eabi

RUN mkdir -p /opt

RUN mkdir -p /opt/betaflight
WORKDIR /opt/betaflight

ENV ARM_SDK_DIR="/usr/"

# Config options you may pass via Docker like so 'docker run -e "<option>=<value>"':
# - TARGET=<name>, specify target platform to build for
#   Specify 'all' to build for all supported platforms. (default: BETAFLIGHTF3)
#   Specify 'test' to build and run the unit tests.
# - OPTIONS=<options> specify build options to be used as defines during the build
#
# What the commands do:

CMD EXTRA_OPTIONS=""; \
    if [ -n ${OPTIONS} ]; then \
        EXTRA_OPTIONS="OPTIONS=${OPTIONS}"; \
        unset OPTIONS; \
    fi; \
    CLEAN_TARGET=clean; \
    BUILD_TARGET=; \
    if [ ${TARGET} = 'test' ]; then \
        CLEAN_TARGET=test_clean; \
        BUILD_TARGET=test; \
    elif [ ${TARGET} = 'all' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=all; \
    elif [ ${TARGET} = 'unified' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=unified; \
    elif [ ${TARGET} = 'unified_zip' ]; then \
        CLEAN_TARGET=clean_all; \
        BUILD_TARGET=unified_zip; \
    elif [ ${TARGET} = 'pre-push' ]; then \
        CLEAN_TARGET=clean; \
        BUIILD_TARGET=pre-push; \
    else \
        CLEAN_TARGET="clean TARGET=${TARGET}"; \
        BUILD_TARGET="TARGET=${TARGET}"; \
    fi; \
    unset TARGET; \
    make ARM_SDK_DIR=${ARM_SDK_DIR} ${CLEAN_TARGET}; \
    make ARM_SDK_DIR=${ARM_SDK_DIR} ${BUILD_TARGET} ${EXTRA_OPTIONS}
