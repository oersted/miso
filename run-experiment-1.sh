#!/bin/bash

mkdir -p "results/$1"
docker build -t miso:latest .; docker run --rm -it -v "$(pwd)/results/$1:/results" miso:latest
