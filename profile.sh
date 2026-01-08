#!/bin/bash

odin build . -show-timings -out=main -o:none -debug  -vet-cast -vet-style -no-bounds-check
perf record -g --all-cpus  -- ./main