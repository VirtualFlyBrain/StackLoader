#!/bin/bash
# Checks all image folders and logs where a file type is missing or broken into missingFiles.tsv
echo 'Checking files for...'
echo reference$'\t'data.jso$'\t'thumbnail.png$'\t'index.html$'\t'volume.nrrd > history/missingFiles.tsv
echo reference$'\t'data.jso$'\t'thumbnail.png$'\t'index.html$'\t'volume.nrrd > history/fullFilesList.tsv
for folder in /partition/karenin/VFB/IMAGE_DATA/VFB/i/*/*/
do 
ref=$(echo ${folder} | replace '/' '' | replace 'partitionkareninVFBIMAGE_DATAVFBi' 'VFB_')$'\t'
result=${ref}
echo $ref
if [ ! -f ${folder}data.jso ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
if [ ! -f ${folder}thumbnail.png ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi
if [ ! -f ${folder}index.html ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
if [ ! -f ${folder}volume.nrrd ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
echo ${result} | replace ',' $'\t' >> history/fullFilesList.tsv
done
cat history/fullFilesList.tsv | grep $'\t''1' >> history/missingFiles.tsv
