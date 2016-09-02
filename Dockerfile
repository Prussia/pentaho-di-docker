FROM serasoft/docker-pentaho-pdi:latest
MAINTAINER Prussia <prussia.hu@gmail.com>

USER root

ENV PYTHON_VERSION 2.7.12
ENV PYTHON_PIP_VERSION 8.1.2


#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

