hassock
=======

Pure bash script to PUT a single doc to [CouchDB](https://github.com/apache/couchdb "CouchDB")  

Use it in cases that you need a simple script to put or update a doc in CouchDB.   
For more complex tasks (ie webapp) you would need a tool like [erica](https://github.com/benoitc/erica "erica")   
  
Usage: hassock --database=yourdb yourdoc.json  

Commands:  
-h --help       This help.  
-d --database   The database to PUT doc. (optional, if not provided db name from filename,you have to create db first)  
-i --docid      The _id for doc. (optional, if not provided _id from filename)  
-r --removepath Remove path of provided doc (optional, useful if not set -d or/add -i)  
-s --server     The CouchDB server name or IP. (optional, default to 127.0.0.1)  
-p --port       The port of CouchDB server. (optional, default to 5984)  
-v --verbose    Set twice to show the steps or only once for server response. (optional)  



Pure?  
no curl or other external programs used on this script :) 

Why bash script and not (erlang,python,perl...)  
because i can :)  
