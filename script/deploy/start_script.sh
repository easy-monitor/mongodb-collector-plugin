#!/bin/bash

if ! type getopt >/dev/null 2>&1 ; then
  echo "Error: command \"getopt\" is not found" >&2
  exit 1
fi

getopt_cmd=`getopt -o h -a -l mongodb-host:,mongodb-port:,mongodb-user:,mongodb-password:,exporter-host:,exporter-port:,exporter-uri: -n "start.sh" -- "$@"`
if [ $? -ne 0 ] ; then
    exit 1
fi
eval set -- "$getopt_cmd"

mongodb_host="127.0.0.1"
mongodb_port=27017
mongodb_user=""
mongodb_password=""
exporter_host="127.0.0.1"
exporter_port=9216
exporter_uri="/metrics"

print_help() {
    echo "Usage:"
    echo "    start_script.sh [options]"
    echo "    start_script.sh --mongodb-host 127.0.0.1 --mongodb-port 3306 --mongodb-user root [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help                 show help"
    echo "      --mongodb-host         the address of MongoDB server (\"127.0.0.1\" by default)"
    echo "      --mongodb-port         the port of MongoDB server (27017 by default)"
    echo "      --mongodb-user         the user to log in to MongoDB server"
    echo "      --mongodb-password     the password to log in to MongoDB server"
    echo "      --exporter-host        the listen address of exporter (\"127.0.0.1\" by default)"
    echo "      --exporter-port        the listen port of exporter (9216 by default)"
    echo "      --exporter-uri         the uri to expose metrics (\"/metrics\" by defualt)"
}

while true
do
    case "$1" in
        -h | --help)
            print_help
            shift 1
            exit 0
            ;;
        --mongodb-host)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    mongodb_host="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --mongodb-port)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    mongodb_port="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --mongodb-user)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    mongodb_user="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --mongodb-password)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    mongodb_password="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-host)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_host="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-port)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_port="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --exporter-uri)
            case "$2" in
                "")
                    shift 2  
                    ;;
                *)
                    exporter_uri="$2"
                    shift 2;
                    ;;
            esac
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error: argument \"$1\" is invalid" >&2
            echo ""
            print_help
            exit 1
            ;;
    esac
done

chmod +x ./src/mongodb_exporter

MONGODB_URI="mongodb://$mongodb_user:$mongodb_password@$mongodb_host:$mongodb_port" ./src/mongodb_exporter --web.listen-address=$exporter_host:$exporter_port --web.telemetry-path=$exporter_uri
