# FileTableDump

This tool is designed to work with Apache Ozone object Store.

This tool expects a RocksDB dump of OM db files and reconstructs the
ozone namespace by walking through these tables.

This can be used to identify nodes in the ozone namespace that are unreachable.
Ideally we don't expect orphan nodes in Ozone namespaces. All unreachable nodes
should be accounted for in the DeletedTables.


## Usage

 * Keep the following files in the INPUT directory
    * ozonefiles : This is "ls -alR" of the ozone file system from root
    * bucketTable.json : This is RocksDB dump of BucketTable in OM
    * directoryTable.json.gz : This is RocksDB dump of directoryTable.json in OM
    * directoryTable.json.gz : This is RocksDB dump of fileTable.json in OM
 * run the parser
    * ./generate_parsed_output_from_Json_tables.sh
 * This tool internally invokes "process_parsed_output_from_json.py" to
   reconstruct the namespace.
 * Optioanlly you can customize few configurations in both the scripts.
 * Output is generated in "./OUTPUT" directory
    * All orphan pathnames and their corresponding objectIDs can be found in ./OUTPUT/all_filename_not_reachable.txt
    * You can also do a vimdiff of reconstructed namespace from the "ls -alR" output with
        * vimdiff ./OUTPUT/all_files_in_filetable_sorted.txt ./OUTPUT/cust_ls_output_with_vol_bucket.txt  

