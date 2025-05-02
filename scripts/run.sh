#!/bin/bash
docker build --platform linux/arm64 -t redbean .
docker run --rm -p 8080:8080 redbean
