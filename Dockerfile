FROM jupyter/base-notebook

ARG SCALA_VERSION=2.12.8
ARG ALMOND_VERSION=0.3.1
ARG GRANT_SUDO=yes
ARG JUPYTER_KERNEL_PATH=/home/jovyan/.local/share/jupyter/kernels

USER root

RUN apt-get update && apt-get install --yes --no-install-recommends curl default-jdk build-essential golang-go coq coqide python3-dev libcairo2-dev libpango1.0-dev ffmpeg

# Manim
RUN apt install build-essential python3-dev libcairo2-dev libpango1.0-dev ffmpeg

# ----------------------------------------------
# Install Almond kernel (Scala)
# ----------------------------------------------
RUN curl -Lo coursier https://git.io/coursier-cli \
    && chmod +x coursier \
    && ./coursier bootstrap \
        -r jitpack \
        -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
        sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
        -o almond \
    && ./almond --install --jupyter-path ${JUPYTER_KERNEL_PATH} && rm -f almond
# RUN cp -r /root/.local/share/jupyter/kernels ~/.local/share/jupyter/

# ----------------------------------------------
# Install Rust kernel
# ----------------------------------------------
ENV PATH="~/.cargo/bin:${PATH}"
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && rustup update \
    && cargo install evcxr_jupyter --no-default-features \
    && evcxr_jupyter --install

# ----------------------------------------------
# Install Go kernel
# ----------------------------------------------
RUN go install github.com/gopherdata/gophernotes@v0.7.5

# RUN mkdir -p ~/.local/share/jupyter/kernels/gophernotes
# RUN cp -r $(go env GOPATH)/pkg/mod/github.com/gopherdata/gophernotes@v0.7.1/kernel/* ~/.local/share/jupyter/kernels/gophernotes
# RUN cd ~/.local/share/jupyter/kernels/gophernotes
RUN mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    && cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v0.7.5/kernel/*  ~/.local/share/jupyter/kernels/gophernotes/ \
    && chmod +w ~/.local/share/jupyter/kernels/gophernotes/kernel.json # in case copied kernel.json has no write permission \
    && sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < ~/.local/share/jupyter/kernels/gophernotes/kernel.json.in > ~/.local/share/jupyter/kernels/gophernotes/kernel.json

# ----------------------------------------------
# Install Kotlin Kernel
# ----------------------------------------------
RUN conda install -y -c jetbrains kotlin-jupyter-kernel

# ---------------------------------------------
# Install Polyglot
# ---------------------------------------------
RUN pip install jupyterlab_sos manim ollama langchain langchain-ollama pandas langchain-community

# ----------------------------------------------
# Install Haskell
# ----------------------------------------------
# RUN apt-get install -y git libtinfo-dev libzmq3-dev libcairo2-dev libpango1.0-dev libmagic-dev libblas-dev liblapack-dev

# RUN curl -sSL https://get.haskellstack.org/ | sh \
#     && git clone https://github.com/gibiansky/IHaskell \
#     && cd IHaskell \
#     && pip3 install -r requirements.txt \
#     && stack install --fast \
#     && ihaskell install --stack


EXPOSE 8888

ENTRYPOINT ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''", "--NotebookApp.allow_origin='*'", "--NotebookApp.allow_remote_access=True"]

#--NotebookApp.allow_origin_pat=https://.*vscode-cdn\.net
