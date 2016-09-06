FROM serasoft/docker-pentaho-pdi
MAINTAINER Prussia <prussia.hu@gmail.com>

USER root
#=========================
ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8
#=========================

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu trusty main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy && apt-get -qqy install \
  build-essential wget unzip curl \
  xz-utils zlib1g-dev libssl-dev \
  git zip pwgen

#===================================================================================
# anaconda 2
#===================================================================================
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-4.1.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

#====================================================================================
# pentaho cpython
#====================================================================================
RUN  su -c "curl -L https://github.com/pentaho-labs/pentaho-cpython-plugin/releases/download/v1.0/pentaho-cpython-plugin-package-1.0-SNAPSHOT.zip -o /opt/pentaho/pentaho-cpython.zip" pentaho-cpython && \
     su -c "unzip -q /opt/pentaho/pentaho-cpython.zip -d /opt/pentaho/plugins" pentaho-cpython && \
          rm /opt/pentaho/pentaho-cpython.zip

#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 


