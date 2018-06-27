#!/bin/bash
# Find SWC files that match the label, move the original their VFB ref folder.
echo Converting...
source /partition/bocian/VFBTools/python-modules-2.6/bin/activate
if [ ! -f ./linkSWCData.tsv ]
then
  echo "linkSWCData.tsv file is missing! See linkDataExample.tsv for an example"
  echo "No images set to load!"
else
  export dirName='./PutAlignedFilesInHere/'
  export imageDir='/disk/data/VFB/IMAGE_DATA/VFB/i/'

  cat linkSWCData.tsv | while IFS=$'\t' read -ra VFBI
  do
    label=${VFBI[0]}
    ref=${VFBI[1]}
    echo $ref
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | sed 's|VFB_||g' | cut -c 5-)
      first=$(echo ${ref} | sed 's|VFB_||g' |  cut -c 1-4)
      nf=$(ls ${dirName}*${label}*.swc 2>/dev/null | wc -l)
      if [ $nf -gt 0 ]
      then
        if [ $nf -gt 1 ]
        then
          echo ERROR: Multiple files found for $label when processing $ref
        else
          echo Processing ${ref}...
          file=$(ls ${dirName}*${label}*.swc 2>/dev/null)
          echo Found file $file for $label
          if [ -f $file ]
          then
            echo "Moving files:"
            if [ ! -d ${imageDir}${first} ]
            then
              mkdir ${imageDir}${first}
            fi
            if [ ! -d ${imageDir}${first}/${last} ]
            then
              mkdir ${imageDir}${first}/${last}
            fi
            mv -v ${file} ${imageDir}${first}/${last}/volume.swc
          fi
        fi
      else
        echo No file found for $label
      fi
    fi
  done
fi
