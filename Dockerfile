FROM ubuntu:latest
RUN apt update && apt install -y curl zip
RUN curl https://redbean.dev/redbean-3.0.0.com >redbean.com
RUN chmod +x redbean.com
ADD .lua .lua
COPY .init.lua .
RUN zip -r redbean.com .init.lua .lua
EXPOSE 8080
CMD ["/bin/bash", "-c", "./redbean.com"]
