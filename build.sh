#!/bin/bash

if [[ $1 == "release" ]]
then
  shift
  echo "building 'release' executable -> ./main"
  odin build . -show-timings -out=main -o:aggressive -vet -vet-cast -vet-style
else
  shift
  echo "building 'debug' executable -> ./main"
  odin build . -show-timings -out=main -o:none -debug  -vet-cast -vet-style
fi
