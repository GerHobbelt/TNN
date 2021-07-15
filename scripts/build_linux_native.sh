#!/bin/bash

SHARED_LIB="ON"
OPENMP="ON"
OPENCL="OFF"
QUANTIZATION="OFF"
DEBUG_MODE="OFF"
CC=gcc
CXX=g++

if [ -z $TNN_ROOT_PATH ]
then
    TNN_ROOT_PATH=$(cd `dirname $0`; pwd)/..
fi

set -euo pipefail

BUILD_DIR=${TNN_ROOT_PATH}/scripts/build_linux_x86_cpu_native
TNN_INSTALL_DIR=${TNN_ROOT_PATH}/scripts/release_linux_x86_cpu_native

if [ -d ${BUILD_DIR} ]
then
    rm -rf ${BUILD_DIR}
fi 

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

cmake ${TNN_ROOT_PATH} \
    -DCMAKE_SYSTEM_NAME=Linux  \
    -DTNN_TEST_ENABLE=ON \
    -DTNN_CPU_ENABLE=ON \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DTNN_X86_ENABLE:BOOL=ON \
    -DTNN_OPENMP_ENABLE:BOOL=$OPENMP \
    -DTNN_OPENCL_ENABLE:BOOL=$OPENCL \
    -DTNN_QUANTIZATION_ENABLE:BOOL=$QUANTIZATION \
    -DTNN_BENCHMARK_MODE=ON \
    -DTNN_BUILD_SHARED:BOOL=$SHARED_LIB \
    -DDEBUG=${DEBUG_MODE}

make -j8

cd ${BUILD_DIR}
mkdir -p ${TNN_INSTALL_DIR}/lib
mkdir -p ${TNN_INSTALL_DIR}/bin
if [ -d ${TNN_INSTALL_DIR}/include ]
then
    rm -rf ${TNN_INSTALL_DIR}/include
fi 

cp -RP ${TNN_ROOT_PATH}/include ${TNN_INSTALL_DIR}/
cp -P libTNN.so* ${TNN_INSTALL_DIR}/lib
cp test/TNNTest ${TNN_INSTALL_DIR}/bin

# check compile error, or ci will not stop
if [ 0 -ne $? ]
then
    exit -1
fi
