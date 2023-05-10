FROM --platform=amd64 nvidia/cuda:11.8.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 COMMANDLINE_ARGS="--skip-torch-cuda-test"

WORKDIR /root
RUN apt update; apt upgrade --yes
RUN apt install --yes python3 python3-pip python3-venv git wget google-perftools libgoogle-perftools-dev libgl1
ENV LD_PRELOAD=libtcmalloc.so

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /root/stable-diffusion-webui

RUN cat webui.sh | sed "s/^can_run_as_root=0$/can_run_as_root=1/g" > tmp.sh && \ 
    mv tmp.sh webui.sh && chmod +x webui.sh

RUN python3 -m venv /root/stable-diffusion-webui/venv
RUN /bin/bash -c "source /root/stable-diffusion-webui/venv/bin/activate && \
    python3 -c 'from launch import prepare_environment; prepare_environment()' --exit && \
    pip3 install xformers && \
    pip3 cache purge"

RUN ln -s $(ls /usr/local/cuda-11/targets/x86_64-linux/lib/libnvrtc.so.11.8*) /usr/local/cuda-11/targets/x86_64-linux/lib/libnvrtc.so

ENTRYPOINT [ "/bin/bash", "./webui.sh" ]