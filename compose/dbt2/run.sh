#!/bin/bash

echo "hostname: $HOSTNAME"

echo get DBT2 environment

env | grep DBT2 > environment.dat
cat environment.dat

input_dir=$(pwd)
output_dir=$(pwd)

if [ "$DBT2_S3FS_MOUNT" != "" ] ; then
    input_dir=$DBT2_S3FS_MOUNT
    output_dir=$DBT2_S3FS_MOUNT
	echo mount $input_dir to s3 
	
	echo $DBT2_S3FS_PASSWD  > ~/.passwd-s3fs
	chmod 600  ~/.passwd-s3fs
	mkdir -p $DBT2_S3FS_MOUNT
	s3fs $DBT2_S3FS_BUCKET $DBT2_S3FS_MOUNT -o passwd_file=~/.passwd-s3fs -o url=$DBT2_S3FS_URL -o use_path_request_style
fi

output_dir=$output_dir/$DBT2_OUTPUT/$(date +%Y_%m_%d_%H_%M)/$HOSTNAME

echo begin $DBT2_OP from: $input_dir to $output_dir

mysql_path=$(which mysql)
mysql_dir_path=$(dirname $mysql_path)

if [ "$DBT2_OP" = "load" ]; then

	echo 'Generating the data files...'
	mkdir /tmp/dbt
	src/datagen -w $DBT2_WAREHOUSE -d /tmp/dbt --mysql

	echo 'Loading the data into the database...'
	scripts/mysql/mysql_load_db.sh \
  		--path /tmp/dbt \
  		--local \
  		--mysql-path "$mysql_path" \
  		--database "$DBT2_MYSQL_DATABASE" \
  		--host "$DBT2_MYSQL_HOST" \
  		--port "$DBT2_MYSQL_PORT" \
 		--user "$DBT2_MYSQL_USER" \
  		--password "$DBT2_MYSQL_PASSWORD"
  		
    echo 'Loading the stored procedures...'
	scripts/mysql/mysql_load_sp.sh \
  		--client-path "$mysql_dir_path" \
  		--sp-path storedproc/mysql \
  		--database "$DBT2_MYSQL_DATABASE" \
  		--host "$DBT2_MYSQL_HOST" \
  		--port "$DBT2_MYSQL_PORT" \
 		--user "$DBT2_MYSQL_USER" \
  		--password "$DBT2_MYSQL_PASSWORD"

elif [ "$DBT2_OP" = "run" ]; then

	echo 'Running the benchmark...'
	scripts/run_mysql.sh \
	  --connections $DBT2_CONNECTION \
	  --time $DBT2_TIME \
	  --warehouses $DBT2_WAREHOUSE \
 	  --zero-delay \
  	  --output-base ./ \
 	  --lib-client-path  /usr/lib/x86_64-linux-gnu \
  	  --database "$DBT2_MYSQL_DATABASE" \
      --host "$DBT2_MYSQL_HOST" \
  	  --port "$DBT2_MYSQL_PORT" \
 	  --user "$DBT2_MYSQL_USER" \
  	  --password "$DBT2_MYSQL_PASSWORD" \
  	  --verbose
  	  
  	if [ "$DBT2_S3FS_MOUNT" != "" ] ; then
		echo copy run information to : $output_dir
		
    	mkdir -p $output_dir
    	
		cp *.dat $output_dir
		
		cp ./output/0/driver/statistics.log $output_dir
		
	fi
fi
    
echo "end workload" > end.log
tail -F  end.log