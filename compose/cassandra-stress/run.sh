#!/bin/bash

echo "hostname: $HOSTNAME"

echo get Cassandra-Stress environment

env | grep CS > environment.dat
cat environment.dat

input_dir=$(pwd)
output_dir=$(pwd)

if [ "$CS_S3FS_MOUNT" != "" ] ; then
    input_dir=$CS_S3FS_MOUNT
    output_dir=$CS_S3FS_MOUNT
	echo mount $input_dir to s3 
	
	echo $CS_S3FS_PASSWD  > ~/.passwd-s3fs
	chmod 600  ~/.passwd-s3fs
	mkdir -p $CS_S3FS_MOUNT
	s3fs $CS_S3FS_BUCKET $CS_S3FS_MOUNT -o passwd_file=~/.passwd-s3fs -o url=$CS_S3FS_URL -o use_path_request_style
fi

output_dir=$output_dir/$CS_OUTPUT/$(date +%Y_%m_%d_%H_%M)/$HOSTNAME

echo begin $CS_OP workload from: $input_dir to $output_dir

echo 'Running the benchmark...'

cassandra-stress $CS_OP n=$CS_OP_NUMBER -rate threads=$CS_THREAD_COUNT $CS_ADD_PROPERTIES -node $CS_NODES -log file=./statistics.log

if [ "$CS_S3FS_MOUNT" != "" ] ; then
		echo copy run information to : $output_dir
		
    	mkdir -p $output_dir
    	
		cp *.dat $output_dir
		
		cp *.log $output_dir
fi
    
echo "end workload" > end.log
tail -F  end.log