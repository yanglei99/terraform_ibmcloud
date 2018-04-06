# reference https://gist.github.com/BenMorel/6131673

FROM ubuntu:16.04

MAINTAINER Yang Lei <yanglei@us.ibm.com>

# Folder structure: 
#        Dockerfile
#        run.sh 
#
# To build image once:
#
#        docker build -t dbt2_s3fs .
#
#
# To run container:
#
#		check ENV for other possible changes

WORKDIR /dbt2

# Prep Installation

RUN apt-get update &&  apt-get install -y --no-install-recommends apt-utils && apt-get install -y git curl wget

# Install MySQL Client

RUN apt-get -y -f install mysql-client-5.7 libmysqlclient20 libmysqlclient-dev

# Download and Build DBT2

RUN \
    wget -q -O - https://downloads.mysql.com/source/dbt2-0.37.50.15.tar.gz | tar xvz ;\
    mv dbt2-0.37.50.15 DBT2 ;\
    cd DBT2 ;\
    search='out_w_city VARCHAR(10);' ;\
    replace='out_w_city VARCHAR(20);' ;\
    sed -i "s/$search/$replace/g" storedproc/mysql/payment.sql ;\
    sed -i 's/"-p $DB_PASSWORD"/"-p$DB_PASSWORD"/g' scripts/mysql/mysql_load_db.sh ;\
    sed -i 's/"-p $DB_PASSWORD"/"-p$DB_PASSWORD"/g' scripts/mysql/mysql_load_sp.sh ;\
    search='mysql_host\[32\]' ;\
    replace='mysql_host\[64\]' ;\
    sed -i "s/$search/$replace/g" src/mysql/dbc_common.c ;\
    sed -i "s/$search/$replace/g" src/include/mysql_common.h
    
 
RUN apt-get install -y make automake autoconf autotools-dev g++
   
RUN \
     cd DBT2 ;\
    ./configure --with-mysql ;\
    make ;\
    make install

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


WORKDIR /dbt2/DBT2

# COPY run.sh

ADD *.sh /dbt2/DBT2/
RUN chmod +x *.sh

ENV DBT2_OP load
ENV DBT2_WAREHOUSE 10
ENV DBT2_CONNECTION 10
ENV DBT2_TIME 60
ENV DBT2_MYSQL_DATABASE dbt2
ENV DBT2_MYSQL_HOST localhost
ENV DBT2_MYSQL_PORT 3306
ENV DBT2_MYSQL_USER root
#ENV DBT2_MYSQL_PASSWORD 

#ENV DBT2_S3FS_PASSWD key:secret
#ENV DBT2_S3FS_URL http://s3-api.us-geo.objectstorage.softlayer.net
#ENV DBT2_S3FS_MOUNT /tmp/s3fs
#ENV DBT2_S3FS_BUCKET mybucket
#ENV DBT2_OUTPUT mysql/output

VOLUME /dbt2/DBT2

CMD ["./run.sh"]
