#!/bin/sh

#TODO check DART_SDK is define ?

if [ ! -d packages ]
then
    pub get
fi

#PROJECT_DIR=`pwd`
SERIAL_LIB_PATH=`stat -f %Y packages/serial_port`/..
cd $SERIAL_LIB_PATH

if [ ! -d packages ]
then
    pub get
fi

dart build.dart

#cd PROJECT_DIR
