FROM prussia2016/playdocker:tomcat8
MAINTAINER Prussia <prussia.hu@gmail.com>

USER root
#=========================
#ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8
#=========================
ENV PYTHON_VERSION 2.7.12
ENV PYTHON_PIP_VERSION 8.1.2

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu trusty main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main universe\n" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y apt-transport-https

RUN apt-get -qqy install \
  build-essential wget unzip curl 

RUN apt-get -qqy install \
  xz-utils zlib1g-dev libssl-dev 

RUN apt-get -qqy install \
  git zip 
  
RUN apt-get -qqy install \
  pwgen 

#===================================================================================
# anaconda 3
#===================================================================================
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-4.1.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 


