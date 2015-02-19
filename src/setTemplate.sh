#!/bin/bash
# Set loaded files against the: 
# 001 - JFRC main brain
# 002 - Ito Half Brain
# 003 - Court Adult VNS 
# 004 - Wood Larval Brain 
# template.  
if [ ! -f ./linkData.tsv ]
then
  echo "linkData.tsv file is missing! See linkData.tsv for an example"
else
  export imageDir='/disk/data/VFB/IMAGE_DATA/VFB/i/'
  export templateDir='/disk/data/VFB/IMAGE_DATA/VFB/t/'${template}'/'
  export jsoTemplate='templateForImage.jso'
  cat linkData.tsv | while IFS=$'\t' read -ra VFBI
  do
    label=${VFBI[0]}
    ref=${VFBI[1]}
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | replace 'VFB_' '' | cut -c 5-)
      first=$(echo ${ref} | replace 'VFB_' '' |  cut -c 1-4)
      cat ${templateDir}${jsoTemplate} | replace 'FFFF' ${first} | replace 'LLLL' ${last} > ${imageDir}${first}/${last}/data.jso 
      echo Created json data file for $ref
    else
      echo WARNING: Not processing $ref, $label
    fi
  done
fi
