#!/bin/bash
docker build --platform linux/arm64 -t redbean .
docker volume create db
docker run --rm -p 8080:8080 -v db:/gdc redbean
