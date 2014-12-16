#!/bin/sh

#TODO transform as a dart script
#TODO check DART_SDK is define ?

if [ ! -d packages ]
then
    pub get
fi

#PROJECT_DIR=`pwd`
SERIAL_LIB_PATH=`readlink packages/serial_port`/..
cd $SERIAL_LIB_PATH

if [ ! -d packages ]
then
    pub get
fi

dart bin/serial_port.dart compile

#cd PROJECT_DIR
