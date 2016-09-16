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
  git zip pwgen python-qt4

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

#====================================================================================
# pentaho cpython
#====================================================================================
ADD https://github.com/pentaho-labs/pentaho-cpython-plugin/releases/download/v1.0/pentaho-cpython-plugin-package-1.0-SNAPSHOT.zip /opt/pentaho/data-integration/plugins/pentaho-cpython.zip

RUN unzip -q /opt/pentaho/data-integration/plugins/pentaho-cpython.zip -d /opt/pentaho/data-integration/plugins 

RUN rm /opt/pentaho/data-integration/plugins/pentaho-cpython.zip

#====================================================================================
# tomcat 8
#====================================================================================

ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.0.36
ENV CATALINA_HOME /usr/local/tomcat
#ENV JAVA_OPTS "-Dfile.encoding=UTF-8 -Xms512m -Xmx512m -XX:MaxPermSize=256m"

RUN mkdir -p /usr/local/tomcat/

# INSTALL TOMCAT
RUN  wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat*/* $CATALINA_HOME

RUN $CATALINA_HOME/bin/catalina.sh run

#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

EXPOSE 8080


