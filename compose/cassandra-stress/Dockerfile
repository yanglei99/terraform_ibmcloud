# reference https://docs.datastax.com/en/cassandra/3.0/cassandra/tools/toolsCStress.html

FROM cassandra:3

MAINTAINER Yang Lei <yanglei@us.ibm.com>

# Folder structure: 
#        Dockerfile
#        run.sh 
#
# To build image once:
#
#        docker build -t cs_s3fs .
#
#
# To run container:
#
#		check ENV for other possible changes

WORKDIR /CS

# Prep Installation

RUN  set -ex; \
     apt-get update && apt-get install -y git curl wget

# Install JQ for processing JSON

RUN wget http://stedolan.github.io/jq/download/linux64/jq 
RUN chmod +x jq && cp jq /usr/bin

# Install S3FS 

RUN apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

RUN \
     git clone https://github.com/s3fs-fuse/s3fs-fuse.git ;\
     cd s3fs-fuse ;\
     ./autogen.sh ;\
     ./configure ;\
     make ;\
     make install


# COPY run.sh

ADD *.sh /CS
RUN chmod +x *.sh

ENV CS_OP write
ENV CS_OP_NUMBER 10000
ENV CS_THREAD_COUNT 10
#ENV CS_ADD_PROPERTIES
#ENV CS_NODES

#ENV CS_S3FS_PASSWD key:secret
#ENV CS_S3FS_URL http://s3-api.us-geo.objectstorage.softlayer.net
#ENV CS_S3FS_MOUNT /tmp/s3fs
#ENV CS_S3FS_BUCKET mybucket
#ENV CS_OUTPUT cs/output

VOLUME /CS

CMD ["./run.sh"]
