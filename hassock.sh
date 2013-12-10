#!/bin/bash

######################################################################## 
#                                                                      #
#       Pure bash script to PUT a single doc to CouchDB                #
#                                                                      # 
#       2013 (c) Panagiotis Skarvelis <sl45sms@yahoo.gr>               #
#                                                                      # 
# Licensed under the Apache License, Version 2.0 (the "License");      #
# you may not use this file except in compliance with the License.     #
# You may obtain a copy of the License at                              #                     
#                                                                      #
#   http://www.apache.org/licenses/LICENSE-2.0                         #
#                                                                      #
# Unless required by applicable law or agreed to in writing, software  #
# distributed under the License is distributed on an "AS IS" BASIS,    # 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,                        #
# either express or implied. See the License for the specific language #
# governing permissions and limitations under the License.             #
#                                                                      #
#            (See LISENSE,NOTICE for more information.)                #
########################################################################

#Globals

#default's
SERVER="127.0.0.1"
PORT="5984"
VERBOSE=0
#required val's
FILENAME=""

#functions
function help {
               echo "Usage: hassock --database=yourdb yourdoc.json"
               echo "Commands: 
                    -h --help      This help.
                    -d --database  The database to PUT doc. (optional, if not provided db name from filename,you have to create db first)
                    -i --docid     The _id for doc. (optional, if not provided _id from filename)
                    -s --server    The CouchDB server name or IP. (optional, default to 127.0.0.1)
                    -p --port      The port of CouchDB server. (optional, default to 5984)
                    -v --verbose   Set twice to show the steps or only once for server response. (optional)                 
                    "
           }

#handle command line options
while :
do
    case $1 in
        -h | --help | -\?)
            help
            exit 0
            ;;
        -d | --database)
            DATABASE=$2
            shift 2
            ;;    
        --database=*)
            DATABASE=${1#*=}
            shift
            ;;
        -i | --docid)
            DOCID=$2
            shift 2
            ;;    
        --dockid=*)
            DOCKID=${1#*=}
            shift
            ;;
        -s | --server)
            SERVER=$2
            shift 2
            ;;    
        --server=*)
            SERVER=${1#*=}
            shift
            ;;
        -p | --port)
            PORT=$2
            shift 2
            ;;    
        --port=*)
            PORT=${1#*=}
            shift
            ;;
        -v | --verbose)
            VERBOSE=$((VERBOSE+1))
            shift
            ;;
        --) 
            shift
            break
            ;;
        -*)
            echo "WARN: Unknown option (ignored): $1" >&2
            shift
            ;;
        *)  # no more options. Stop while loop
            break
            ;;
    esac
done

FILENAME=$@  #file name with extension
#validate
if [[ "$FILENAME" == *.json* ]]
then
FILENAME=${FILENAME%.*} #remove extension
else
 echo "You have to provide json doc see --help"
exit 
fi

#set defaults
if [ ! "$DATABASE" ]; then
DATABASE=$FILENAME 
fi
if [ ! "$DOCKID" ]; then
DOCID=$FILENAME
fi

#clean up json
JSON=$(<$FILENAME.json) 
#TODO clean up JSON in one line...?
JSON=${JSON//$'\r'/$''}
JSON=${JSON//$'\n'/$''}
JSON=${JSON//$'\t'/$''}
JSON=${JSON//$'  '/$''}

#get doc rev if exists
[ $VERBOSE -ge 2 ] && echo "Check if $DOCID exists"
HEAD='HEAD /'"${DATABASE}"'/'"${DOCID}"' HTTP/1.0\r\n\r\n'
exec {FD}<>/dev/tcp/$SERVER/$PORT #on first available file descriptor
echo -en $HEAD 1>&$FD
while read LINE <&$FD
do
RESPONSE+=${LINE//$'\r'/$''}
done

#prepare json with _id if needed
if [[ "$RESPONSE" =~ [0-9]*-[A-Za-z0-9]{32} ]]; then
ETAG=${BASH_REMATCH[0]} 
[ $VERBOSE -ge 2 ] && echo "Exists! latest rev is ${ETAG}"
[ $VERBOSE -ge 2 ] && echo "Prepare JSON"
TMP=${JSON#"{"}           #}#comment just for geany syntax highlight!
JSON="{\"_id\": \""$DOCID"\",\"_rev\":\""$ETAG"\","$TMP
fi

#PUT doc
[ $VERBOSE -ge 2 ] && echo "Put $DOCID in $DATABASE"
PUT='PUT /'"${DATABASE}"'/'"${DOCID}"' HTTP/1.0\r\nContent-Length: '"${#JSON}"'\r\nContent-Type: application/json\r\n\r\n'"${JSON}"
exec {FD}<>/dev/tcp/$SERVER/$PORT 2>/dev/null
echo -en $PUT 1>&$FD
while read 0<&$FD; do 
RESPONSE=$REPLY
done
[ $VERBOSE -ge 1 ] && echo $RESPONSE;
