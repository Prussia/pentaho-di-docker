FROM prussia2016/playdocker:jdk8
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
RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH


#====================================================================================
# pentaho
#====================================================================================

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

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

