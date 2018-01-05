#FROM alexpilotti/rpi-bazel:0.9.0
FROM resin/rpi-raspbian:stretch
WORKDIR /
RUN apt-get update
RUN apt-get install -y git python3-numpy python3-dev python3-pip \
    python3-wheel python3-setuptools \
    python-numpy python-dev python-pip python-wheel python-setuptools
RUN git clone https://github.com/tensorflow/tensorflow
COPY resources/bazel /usr/local/bin
RUN apt-get install -y default-jre default-jdk
RUN apt-get install -y build-essential
WORKDIR tensorflow
ENV TF_VERSION=1.4.1
RUN git checkout v${TF_VERSION}
ENV PYTHON=python3
ENV TF_NEED_GCP=0
ENV TF_NEED_CUDA=0
ENV TF_NEED_HDFS=0
ENV TF_NEED_OPENCL=0
ENV TF_NEED_JEMALLOC=1
ENV TF_NEED_S3=1
ENV TF_ENABLE_XLA=0
ENV TF_NEED_GDR=0
ENV TF_NEED_VERBS=0
ENV TF_NEED_MPI=0
ENV CC_OPT_FLAGS="-march=native"
RUN export PYTHON_BIN_PATH=$(which ${PYTHON}); \
    export PYTHON_LIB_PATH="$($PYTHON_BIN_PATH -c 'import site; print(site.getsitepackages()[0])')"; \
    ./configure
RUN bazel build --config=opt --incompatible_load_argument_is_label=false \
    //tensorflow/tools/pip_package:build_pip_package
RUN mkdir wheels
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package wheels

