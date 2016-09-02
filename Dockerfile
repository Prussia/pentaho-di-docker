FROM ubuntu:14.04
MAINTAINER Prussia <prussia.hu@gmail.com>

USER root

ENV PYTHON_VERSION 2.7.12

RUN apt-get update


#==================
# JDK
#==================
RUN add-apt-repository ppa:webupd8team/java
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer oracle-java8-set-default #ant

#==================
# Python
#==================
RUN apt-get purge -y python.*
RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF
RUN set -x \
  && mkdir -p /usr/src/python \
  && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
  && curl -SL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
  && gpg --verify python.tar.xz.asc \
  && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
  && rm python.tar.xz* \
  && cd /usr/src/python \
  && ./configure --enable-shared --enable-unicode=ucs4 \
  && make -j$(nproc) \
  && make install \
  && ldconfig \
  && curl -SL 'https://bootstrap.pypa.io/get-pip.py' | python2 \
  && pip install --upgrade pip==$PYTHON_PIP_VERSION \
  && find /usr/local \
    \( -type d -a -name test -o -name tests \) \
    -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
    -exec rm -rf '{}' + \
  && rm -rf /usr/src/python

#==================
# Pentaho Data Integration
#==================
RUN mkdir /usr/local/data_access
WORKDIR /usr/local/data_access
RUN curl -L https://sourceforge.net/projects/pentaho/files/Data%20Integration/6.1/pdi-ce-6.1.0.1-196.zip | tar xz --strip-components=1




#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

ENV PATH=/usr/local/data_access:$PATH
