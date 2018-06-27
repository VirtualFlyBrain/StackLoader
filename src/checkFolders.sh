#!/bin/bash
# Checks all image folders and logs where a file type is missing or broken into missingFiles.tsv
echo 'Checking files for...' 1>&3
echo 'Checking files for...'
echo reference$'\t'data.jso$'\t'thumbnail.png$'\t'index.html$'\t'volume.nrrd > history/missingFiles.tsv
echo reference$'\t'data.jso$'\t'thumbnail.png$'\t'index.html$'\t'volume.nrrd > history/fullFilesList.tsv
head -n 1 history/completeDataSet.tsv > history/missingData.tsv
for folder in /partition/karenin/VFB/IMAGE_DATA/VFB/i/*/*/
do 
ref=$(echo ${folder} | sed 's|/||g' | replace 'partitionkareninVFBIMAGE_DATAVFBi' 'VFB_')$'\t'
result=${ref}
echo $ref
echo $ref 1>&3
if [ ! -f ${folder}data.jso ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
if [ ! -f ${folder}thumbnail.png ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi
if [ ! -f ${folder}index.html ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
if [ ! -f ${folder}volume.nrrd ]; then result=$(echo ${result},1); else result=$(echo ${result},0); fi 
echo ${result} | sed 's|,|\t|g' >> history/fullFilesList.tsv
done
cat history/fullFilesList.tsv | grep $'\t''1' >> history/missingFiles.tsv
cat history/missingFiles.tsv | grep '1'$'\t' | while IFS=$'\t' read -ra VFBI
do 
cat history/completeDataSet.tsv | grep ${VFBI[0]} >> history/missingData.tsv
done
