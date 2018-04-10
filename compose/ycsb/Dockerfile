# reference https://github.com/brianfrankcooper/YCSB/tree/master/jdbc

FROM ubuntu:14.04

MAINTAINER Yang Lei <yanglei@us.ibm.com>

# Folder structure: 
#        Dockerfile
#        run.sh 
#
# To build image once:
#
#        docker build -t ycsb_s3fs .
#
#
# To run container:
#
#		check ENV for other possible changes

WORKDIR /ycsb

# Prep Installation

RUN apt-get update && apt-get install -y git curl

# Install JDK

RUN apt-get install -y software-properties-common
RUN sudo add-apt-repository ppa:openjdk-r/ppa
RUN sudo apt-get update
RUN apt-get install -y openjdk-8-jdk && java -version

# Install Maven

RUN apt-get install -y wget && wget http://mirror.cogentco.com/pub/apache/maven/maven-3/3.1.1/binaries/apache-maven-3.1.1-bin.tar.gz
RUN mkdir -p /usr/local/apache-maven && mv apache-maven-3.1.1-bin.tar.gz /usr/local/apache-maven && cd /usr/local/apache-maven && tar -xzvf apache-maven-3.1.1-bin.tar.gz

RUN ln -s /usr/local/apache-maven/apache-maven-3.1.1/bin/mvn /usr/bin/mvn && mvn --version

# Build YCSB

RUN \
	git clone https://github.com/brianfrankcooper/YCSB.git ;\
	cd YCSB ;\
	mvn clean package -DskipTests

# Install JQ for processing JSON

RUN wget http://stedolan.github.io/jq/download/linux64/jq 
RUN chmod +x jq && cp jq /usr/bin

# Install S3FS 

RUN sudo apt-get install -y automake autotools-dev fuse g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config

RUN \
     git clone https://github.com/s3fs-fuse/s3fs-fuse.git ;\
     cd s3fs-fuse ;\
     ./autogen.sh ;\
     ./configure ;\
     make ;\
     sudo make install

# Install Python 2.7

RUN \
    sudo add-apt-repository ppa:deadsnakes/ppa ;\
    sudo apt-get update ;\
    sudo apt-get install -y python ;\
    python --version
    
WORKDIR /ycsb/YCSB

# COPY run.sh

ADD *.sh /ycsb/YCSB/
RUN chmod +x *.sh

ENV YCSB_OP load
ENV YCSB_DB jdbc
ENV YCSB_WORKLOAD workloada
ENV YCSB_THREAD_COUNT 1
#ENV YCSB_S3FS_PASSWD key:secret
#ENV YCSB_S3FS_URL http://s3-api.us-geo.objectstorage.softlayer.net
#ENV YCSB_S3FS_MOUNT /tmp/s3fs
#ENV YCSB_S3FS_BUCKET mybucket
#ENV YCSB_WORKLOAD_DATA mysql/workload/workload-2-5k-5k.dat
#ENV YCSB_WORKLOAD_JAR mysql/jars/mysql-connector-java.jar
#ENV YCSB_OUTPUT mysql/output
#ENV YCSB_ADD_PROPERTIES -p db.url=jdbc:mysql://YOUR_HOST:3306/ycsb

#ENV YCSB_NOTES

VOLUME /ycsb/YCSB

CMD ["./run.sh"]
