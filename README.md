hassock
=======

Pure bash script to PUT a single file to CouchDB  

Usage: hassock --database=yourdb yourdoc.json  

Commands:  
-h --help      This help.  
-d --database  The database to PUT doc. (optional, if not provided db name from filename,you have to create db first)  
-i --docid     The _id for doc. (optional, if not provided _id from filename)  
-s --server    The CouchDB server name or IP. (optional, default to 127.0.0.1)  
-p --port      The port of CouchDB server. (optional, default to 5984)  
-v --verbose   Set twice to show the steps or only once for server response. (optional)  
