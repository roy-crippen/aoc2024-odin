#!/bin/bash

if [[ $1 == "release" ]]
then
  shift
  echo "building 'release' executable -> ./bin/main"
  odin build . -show-timings -out=bin/main -o:speed
else
  shift
  echo "building 'debug' executable -> ./bin/main"
  odin build . -show-timings -out=bin/main -o:none -debug
fi
