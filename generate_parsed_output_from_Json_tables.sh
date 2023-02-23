# All debug output is in OutDir
OUT_DIR=./OUTPUT

# We need a "ls -al" output on the customer system
CUSTOMER_LS_OUTPUT=./INPUT/ozonefiles

# We also need a dump of OM rocksDB fileTable in filetable.json
FILE_TABLE=./INPUT/filetable.json

# We also need a dump of OM rocksDB directoryTable in directoryTable.json
DIRECTORY_TABLE=./INPUT/directoryTable.json

# We also need a dump of OM rocksDB bucketTable in bucketTable.json
BUCKET_TABLE=./INPUT/bucketTable.json

#First unzip everything inside INPUT
gunzip ./INPUT/*


# Some internally generated fileNames. This need not be modified.
FILE_ALL_VOL_BUCKET_OBJECT_IDS="all_vol_bucket_object_ids.txt"
FILE_FILES_IN_A_LINE_NAME_PARENTID_OBJECTID="files_in_a_line_name_parentID_objectId.txt"
DIRS_IN_A_LINE_NAME_PARENTID_OBJECTID="dirs_in_a_line_name_parentID_objectId.txt"

# Some Shell Script to get all the paths in the form parent_objectid/child_objectid form.

grep volumeName $FILE_TABLE | sort -u | cut -d":" -f2 | tr -d " ," | tr -d " \""| grep  ","| > all_volumes.txt ; 

grep bucketName $FILE_TABLE | sort -u | cut -d":" -f2 | tr -d " ," | tr -d " \"" > all_buckets.txt;

cat $DIRECTORY_TABLE | grep -v "Added definition for table" | tr -d "\n" | sed 's/\"metadata\":/\n/g' | tr -d " " | sed 's/\"aclBitSet\"[^]]*]//g' | sed 's/\"acls\"[^]]*]//g' | sed 's/{}}//g'  > dirs_in_a_line.txt
cat dirs_in_a_line.txt | sed 's/.*\"name\"://g' | sed 's/,.*parentObjectID\"//g' | sed 's/,.*objectID\"//g' | sed 's/,.*$//g' | tr -d "\" ," | sed 's/*}//g' > $DIRS_IN_A_LINE_NAME_PARENTID_OBJECTID 

cat $FILE_TABLE | grep -v "Added definition for table"      | tr -d "\n" | sed 's/\"metadata\":/\n/g' | tr -d " " | sed 's/\"aclBitSet\"[^]]*]//g'| sed 's/\"acls\"[^]]*]//g' | sed 's/{}}//g'  >files_in_a_line.txt
cat files_in_a_line.txt  | sed 's/.*\"fileName\"://g' | sed 's/,.*parentObjectID\"//g' | sed 's/,.*objectID\"//g' | sed 's/,.*$//g' | tr -d "\" ," | sed 's/.*}//g'> $FILE_FILES_IN_A_LINE_NAME_PARENTID_OBJECTID


cat $BUCKET_TABLE | grep -v "Added definition for table" | tr -d "\n" |  sed 's/\"metadata\":/\n/g'  | tr -d " " | sed 's/\"aclBitSet\"[^]]*]//g'| sed 's/\"acls\"[^]]*]//g' | sed 's/{}}//g' | sed 's/,\"isVersionEnabled\":.*\"objectID\"//g' | sed 's/{\"volumeName\":[ ]*\"//g'| sed 's/\",\"bucketName\":\"/:/g' | sed 's/\",:/:/g' | sed 's/,\"updateID\":[a-zA-Z0-9]*,//g' > $FILE_ALL_VOL_BUCKET_OBJECT_IDS

python3 process_parsed_output_from_json.py -b $FILE_ALL_VOL_BUCKET_OBJECT_IDS -f $FILE_FILES_IN_A_LINE_NAME_PARENTID_OBJECTID -d $DIRS_IN_A_LINE_NAME_PARENTID_OBJECTID >  py_output.txt
cat py_output.txt | grep "rebuild_all_files_from_json_tables:"| cut -d":" -f3 | grep -v "Not Found" | sed 's/\/\//\//g'> rebuild_all_files_from_json_tables.txt
sort rebuild_all_files_from_json_tables.txt | sed 's/\/$//g' | sort -u | sort -u | sort -u > all_files_in_filetable_sorted.txt

grep "Not Found during rebuild_all_files_from_json_tables: Full Path:" py_output.txt| cut -d":" -f3- > all_filename_not_reachable.txt

cat $CUSTOMER_LS_OUTPUT | tr -d " " | tr -s "/" | cut -d":" -f3 | cut -d"/" -f3- | sort | sed 's/^/\//g' > cust_ls_output_with_vol_bucket.txt

echo "Files/Dirs that are unreachable from top level buckets: FilePath Names : FilePath Object Ids"
echo "============================================================================================="
cat all_filename_not_reachable.txt


vimdiff all_files_in_filetable_sorted.txt cust_ls_output_with_vol_bucket.txt

#cleanup
# Comment for debugging

mkdir -p $OUT_DIR
mv $DIRS_IN_A_LINE_NAME_PARENTID_OBJECTID $OUT_DIR  
mv $FILE_FILES_IN_A_LINE_NAME_PARENTID_OBJECTID $OUT_DIR  
mv $FILE_ALL_VOL_BUCKET_OBJECT_IDS $OUT_DIR  
mv dirs_in_a_line.txt $OUT_DIR  

mv files_in_a_line.txt $OUT_DIR  
mv rebuild_all_files_from_json_tables.txt $OUT_DIR  
mv py_output.txt $OUT_DIR  
mv all_volumes.txt $OUT_DIR  
mv all_buckets.txt $OUT_DIR  

mv all_filename_not_reachable.txt $OUT_DIR
mv cust_ls_output_with_vol_bucket.txt $OUT_DIR
mv all_files_in_filetable_sorted.txt $OUT_DIR



