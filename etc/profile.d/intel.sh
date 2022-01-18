#!/bin/sh
export VENDOR_PATH=/opt/intel
export PATH=$PATH:${VENDOR_PATH}/sbin:${VENDOR_PATH}/usr/sbin:${VENDOR_PATH}/bin
export LD_LIBRARY_PATH=${VENDOR_PATH}/lib:${VENDOR_PATH}/usr/lib:${LD_LIBRARY_PATH}

