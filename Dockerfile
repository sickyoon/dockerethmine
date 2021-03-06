FROM ubuntu:18.04

MAINTAINER sickyoon <sick.yoon@gmail.com>
LABEL description="AMD OpenCL ethminer"

ARG amdgpu_ver=20.30-1109583-ubuntu-18.04
ARG ethminer_ver=0.17.1

ENV amdgpu_ver=$amdgpu_ver
ENV ethminer_ver=$ethminer_ver

WORKDIR /tmp

# install amd driver
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get -y --no-install-recommends install \
    curl \
    ca-certificates \
    xz-utils \
    initramfs-tools \
    jq
RUN curl --output /tmp/amdgpu-pro-${amdgpu_ver}.tar.xz --referer https://www.amd.com/en/support/graphics/radeon-500-series/radeon-rx-500-series/radeon-rx-580 https://drivers.amd.com/drivers/linux/amdgpu-pro-${amdgpu_ver}.tar.xz
RUN tar -Jxvf /tmp/amdgpu-pro-${amdgpu_ver}.tar.xz
RUN /tmp/amdgpu-pro-${amdgpu_ver}/amdgpu-pro-install -y --headless --opencl=legacy
RUN apt-get -y autoremove
RUN apt-get -y autoclean
RUN rm -rf /var/lib/{apt,dpkg,cache,log}

# install ethminer
RUN curl -L -O https://github.com/ethereum-mining/ethminer/releases/download/v${ethminer_ver}/ethminer-${ethminer_ver}-linux-x86_64.tar.gz
RUN tar -xvf ethminer-${ethminer_ver}-linux-x86_64.tar.gz
RUN rm ethminer-${ethminer_ver}-linux-x86_64.tar.gz
RUN mv bin/* /usr/local/bin/.
RUN rm -r bin

RUN export GPU_FORCE_64BIT_PTR=1
RUN export GPU_MAX_HEAP_SIZE=100
RUN export GPU_USE_SYNC_OBJECTS=1
RUN export GPU_MAX_ALLOC_PERCENT=100
RUN export GPU_SINGLE_ALLOC_PERCENT=100

ENTRYPOINT ["/usr/local/bin/ethminer"]
