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
  source /partition/bocian/VFBTools/python-modules-2.6/bin/activate
  cat linkData.tsv | while IFS=$'\t' read -ra VFBI
  do
    label=${VFBI[0]}
    ref=${VFBI[1]}
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | replace 'VFB_' '' | cut -c 5-)
      first=$(echo ${ref} | replace 'VFB_' '' |  cut -c 1-4)
      if [ -f ${imageDir}${first}/${last}/volume.nrrd ]
      then
        sliceNum=$(python /partition/bocian/VFBTools/NRRDtools/sliceNumber.py ${imageDir}${first}/${last}/volume.nrrd)
        offset=$(echo ${sliceNum}*${zSlice}/2 | bc)
        sliceMax=$(python /partition/bocian/VFBTools/NRRDtools/brightestSlice.py ${imageDir}${first}/${last}/volume.nrrd)
        dist=$(echo ${sliceMax}*${zSlice}-${offset} | bc | awk '{printf("%d\n",$1 + 0.5)}')
      else
        dist=0
      fi
      cat ${templateDir}${jsoTemplate} | replace 'FFFF' ${first} | replace 'LLLL' ${last} | replace '"distance":"0"' '"distance":"'${dist}'"' > ${imageDir}${first}/${last}/data.jso
      echo Created json data file for $ref
      echo '<html><head><meta HTTP-EQUIV="REFRESH" content="0; url=/site/tools/view_stack/3rdPartyStack.htm?tpbid='${ref}'"></head></html>' > ${imageDir}${first}/${last}/index.html
      echo Created html link file for $ref
    else
      echo WARNING: Not processing $ref, $label
    fi
  done
  chmod -R 777 ${imageDir}${first} 2>/dev/null
  echo ------------------------------------------------------
  echo Now run the following comand inside the owl directory of the repository you want to add the files new files to
  echo .
  printf '%s\n' "cat /partition/karenin/VFB/IMAGE_DATA/StackLoader/linkData.tsv | while IFS=$'\t' read -ra VFBI; do last=$(echo ${VFBI[1]} | replace 'VFB_' '' | cut -c 5-) ; first=$(echo ${VFBI[1]} | replace 'VFB_' '' |  cut -c 1-4) ; ref=$(echo ${VFBI[1]} | replace 'VFB_' 'VFBi_' ) ; ln -sf ../data/VFB/i/$first/$last/ ./$ref ; ln -sf ./${ref}/index.html ./${VFBI[1]} ; echo $ref ;done"
  echo .
  echo ------------------------------------------------------
fi
