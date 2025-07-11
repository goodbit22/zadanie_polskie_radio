#!/bin/bash
directory_images="images"
bucket_name="pictures"
login="$(kubectl get secret minio  -n minio  -o jsonpath="{.data.root-user}"  | base64 -d )"
password="$( kubectl get secret minio  -n minio  -o jsonpath="{.data.root-password}"  | base64 -d   )" 
mc alias set local http://127.0.0.1:9000 "$login" "$password"
mc mb "local/${bucket_name}"
mc ls local 

mc cp -r "${directory_images}/*" "local/${bucket_name}"  