FROM registry.redhat.io/rhscl/python-38-rhel7

LABEL maintainer="OmniDB team"

ARG OMNIDB_VERSION=3.0.3b

SHELL ["/bin/bash", "-c"]

USER root
#RUN groupadd --system omnidb \
#    && adduser --system omnidb --gid omnidb \
#    && yum update \
#   && yum install python-devel openldap-devel vim -y

RUN groupadd --system omnidb
RUN adduser --system omnidb --gid omnidb
RUN mkdir /omni
#RUN yum -y update
#RUN yum -y install python-devel openldap-devel vim
COPY . /omni/
RUN chmod -R 777 /omni && chown -R omnidb:omnidb /omni

USER omnidb:omnidb
ENV HOME /omni
WORKDIR ${HOME}

#RUN wget https://github.com/OmniDB/OmniDB/archive/${OMNIDB_VERSION}.tar.gz \
#    && tar -xvzf ${OMNIDB_VERSION}.tar.gz \
#    && mv OmniDB-${OMNIDB_VERSION} OmniDB

RUN mv OmniDB-3.0.3b /omni/OmniDB

WORKDIR ${HOME}/OmniDB

USER root
RUN pip install -r requirements.txt

WORKDIR ${HOME}/OmniDB/OmniDB

RUN sed -i "s/LISTENING_ADDRESS    = '127.0.0.1'/LISTENING_ADDRESS    = '0.0.0.0'/g" config.py
RUN python omnidb-server.py --init
RUN python omnidb-server.py --dropuser=admin

EXPOSE 8000

CMD python omnidb-server.py
