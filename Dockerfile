FROM nvcr.io/nvidia/l4t-base:r32.5.0
ENV DEBIAN_FRONTEND=noninteractive

# https://qengineering.eu/install-pytorch-on-jetson-nano.html
RUN apt-get update
RUN apt-get install -y python3.8 python3.8-dev
RUN apt-get install -y ninja-build git cmake clang
RUN apt-get install -y libopenmpi-dev libomp-dev ccache
RUN apt-get install -y libopenblas-dev libblas-dev libeigen3-dev
RUN apt-get install -y python3-pip libjpeg-dev
RUN python3.8 -m pip install -U setuptools
RUN python3.8 -m pip install -U wheel mock pillow
RUN python3.8 -m pip install scikit-build
RUN python3.8 -m pip install cython Pillow
# download PyTorch 1.8.1 with all its libraries
RUN git clone -b lts/release/1.8 --depth 1 --recursive --recurse-submodules --shallow-submodules https://github.com/pytorch/pytorch.git
WORKDIR pytorch
RUN python3.8 -m pip install -r requirements.txt
COPY pytorch-1.8-jetson.patch .
RUN patch -p1 < pytorch-1.8-jetson.patch

ENV BUILD_CAFFE2_OPS=OFF
ENV USE_FBGEMM=OFF
ENV USE_FAKELOWP=OFF
ENV BUILD_TEST=OFF
ENV USE_MKLDNN=OFF
ENV USE_NNPACK=OFF
ENV USE_XNNPACK=OFF
ENV USE_QNNPACK=OFF
ENV USE_PYTORCH_QNNPACK=OFF
ENV USE_CUDA=ON
ENV USE_CUDNN=ON
ENV TORCH_CUDA_ARCH_LIST="5.3;6.2;7.2"
ENV USE_NCCL=OFF
ENV USE_SYSTEM_NCCL=OFF
ENV USE_OPENCV=OFF
ENV MAX_JOBS=2
# set path to ccache
ENV PATH=/usr/lib/ccache:$PATH
# set clang compiler
ENV CC=clang
ENV CXX=clang++
# create symlink to cublas
# ln -s /usr/lib/aarch64-linux-gnu/libcublas.so /usr/local/cuda/lib64/libcublas.so
# start the build
RUN python3.8 setup.py bdist_wheel
