#!/bin/bash

echo "hostname: $HOSTNAME"

echo get YCSB environment

env | grep YCSB > environment.dat
cat environment.dat

echo "YCSB_RUN_DATE=$(date +%Y-%m-%d_%H:%M:%S)" >> environment.dat

date_in_dir=$(date +%Y_%m_%d_%H_%M)

input_dir=$(pwd)
output_dir=$(pwd)

if [ "$YCSB_S3FS_MOUNT" != "" ] ; then
    input_dir=$YCSB_S3FS_MOUNT
    output_dir=$YCSB_S3FS_MOUNT
    
	echo mount $input_dir to s3 
	
	echo $YCSB_S3FS_PASSWD  > ~/.passwd-s3fs
	chmod 600  ~/.passwd-s3fs
	mkdir -p $YCSB_S3FS_MOUNT
	s3fs $YCSB_S3FS_BUCKET $YCSB_S3FS_MOUNT -o passwd_file=~/.passwd-s3fs -o url=$YCSB_S3FS_URL -o use_path_request_style
fi

output_dir=$output_dir/$YCSB_OUTPUT/$date_in_dir/$HOSTNAME

echo begin $YCSB_OP $YCSB_DB for workload: $YCSB_WORKLOAD from: $input_dir to: $output_dir

bin/ycsb $YCSB_OP $YCSB_DB -P workloads/$YCSB_WORKLOAD -P $input_dir/$YCSB_WORKLOAD_DATA -cp $input_dir/$YCSB_WORKLOAD_JAR $YCSB_ADD_PROPERTIES -p exportfile=transactions.dat -s -threads $YCSB_THREAD_COUNT

cat  transactions.dat

if [ "$YCSB_S3FS_MOUNT" != "" ] ; then

	echo copy run information to : $output_dir

	mkdir -p $output_dir

	cp *.dat $output_dir

	cp $YCSB_S3FS_MOUNT/$YCSB_WORKLOAD_DATA $output_dir/workload.dat

fi

echo "end workload" > end.log
tail -F  end.log