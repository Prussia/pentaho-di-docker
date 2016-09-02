FROM serasoft/docker-jdk:jdk8
MAINTAINER Prussia <prussia.hu@gmail.com>

ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8
ENV PYTHON_VERSION 2.7.12
ENV PYTHON_PIP_VERSION 8.1.2

ENV HOME /root
ENV PENTAHO_HOME /opt/pentaho
ENV PDI_HOME ${PENTAHO_HOME}/data-integration
ENV BASE_REL 6.1
ENV REV 0.1-196

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

#================================================
# Customize sources for apt-get
#================================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu trusty main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu trusty-updates main universe\n" >> /etc/apt/sources.list

RUN apt-get update -qqy \
  && apt-get -qqy install build-essential wget unzip curl xvfb xz-utils zlib1g-dev libssl-dev git zip pwgen


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


#====================================================================================
# pentaho
#====================================================================================
RUN useradd -m -d ${PENTAHO_HOME} pentaho

# ADD pdi-ce-${BASE_REL}.${REV}.zip ${PENTAHO_HOME}/pdi-ce.zip

RUN  su -c "curl -L http://sourceforge.net/projects/pentaho/files/Data%20Integration/${BASE_REL}/pdi-ce-${BASE_REL}.${REV}.zip/download -o /opt/pentaho/pdi-ce.zip" pentaho && \
     su -c "unzip -q /opt/pentaho/pdi-ce.zip -d /opt/pentaho/" pentaho && \
          rm /opt/pentaho/pdi-ce.zip

# Add all files needed t properly initialize the container
COPY utils ${PDI_HOME}/utils
COPY templates ${PDI_HOME}/templates

# Set password to generated value
RUN chown -Rf pentaho:pentaho ${PDI_HOME}

ADD 01_init_container.sh /etc/my_init.d/01_init_container.sh

ADD run /etc/service/pentaho/run

RUN chmod +x /etc/my_init.d/*.sh && \
    chmod +x /etc/service/pentaho/run

EXPOSE 8080

#============================
# Clean up
#============================
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

