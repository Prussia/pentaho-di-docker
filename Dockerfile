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
  git zip pwgen python-qt4

#============================
# Python
#============================
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
  && rm -rf /usr/src/python ~/.cache

#====================================================================================
# install "virtualenv", since the vast majority of users of this image will want it
#====================================================================================
RUN pip install --no-cache-dir virtualenv
RUN pip install sklearn
RUN pip install matplotlib
RUN pip install numpy
RUN pip install pandas
 
ENV PATH $PATH:$PYTHONPATH

#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 


