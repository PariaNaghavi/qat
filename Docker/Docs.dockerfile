##########################
# Generator
##########################
FROM ubuntu:20.04 as generator

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
  apt-get install -y 

RUN apt-get install -y curl \
  pkg-config \
  findutils \
  wget \
  unzip doxygen

RUN wget https://github.com/matusnovak/doxybook2/releases/download/v1.3.6/doxybook2-linux-amd64-v1.3.6.zip && \
    unzip doxybook2-linux-amd64-v1.3.6.zip

ADD qir/qat/ /build/qir/qat/
ADD doxygen.cfg /build/

ADD docs/ /build/docs/

WORKDIR /build/
RUN doxygen doxygen.cfg && \
   doxybook2 --input Doxygen/xml --config docs/.doxybook/config.json --output docs/src/ && \
   rm -rf docs/src/Namespaces/namespace_0d* 


##########################
# Builder
##########################
FROM python:2.7 as builder

RUN mkdir /src/
COPY --from=generator /build/docs/ /src/

WORKDIR /src/

RUN pip install mkdocs
RUN pip install mkdocs-gitbook
RUN mkdocs build


##########################
# Documentation
##########################
FROM nginx:latest as documentation
ADD nginx/default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /src/site /usr/share/nginx/html