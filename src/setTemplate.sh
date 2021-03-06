#!/bin/bash
# Set loaded files against the:
# 001 - JFRC main brain
# 002 - Ito Half Brain
# 003 - Wood Larval Brain
# 004 - Court Adult VNS

# template.
echo Setting Meta Data... 1>&3
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
    echo $ref 1>&3
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | sed 's|VFB_||g' | cut -c 5-)
      first=$(echo ${ref} | sed 's|VFB_||g' |  cut -c 1-4)
      if [ -f ${imageDir}${first}/${last}/volume.nrrd ]
      then
        sliceNum=$(python /partition/bocian/VFBTools/NRRDtools/sliceNumber.py ${imageDir}${first}/${last}/volume.nrrd)
        offset=$(echo ${sliceNum}*${zSlice}/2 | bc)
        sliceMax=$(python /partition/bocian/VFBTools/NRRDtools/brightestSlice.py ${imageDir}${first}/${last}/volume.nrrd)
        dist=$(echo ${sliceMax}*${zSlice}-${offset} | bc | awk '{printf("%d\n",$1 + 0.5)}')
      else
        dist=0
      fi
      cat ${templateDir}${jsoTemplate} | sed "s|FFFF|${first}|g" | sed "s|LLLL|${last}|g" | sed "s|\"distance\":\"0\"|\"distance\":\"${dist}\"|g" > ${imageDir}${first}/${last}/data.jso
      echo Created json data file for $ref
      echo '<html><head><meta HTTP-EQUIV="REFRESH" content="0; url=/site/tools/view_stack/3rdPartyStack.htm?tpbid='${ref}'"></head></html>' > ${imageDir}${first}/${last}/index.html
      echo Created html link file for $ref
      SourceName=${VFBI[0]}
      SourceURI=${VFBI[1]}
      if [ $SourceName=='' ] ; then SourceName='See definition for reference'; fi
      if [ $SourceURI=='' ] ; then SourceURI='/site/tools/anatomy_finder/index.htm?id='${ref}; fi
      echo '<a href="'${SourceURI}'" target="_new" title="Source data from '${SourceName}'" >'${SourceName}'</a>' > ${imageDir}${first}/${last}/source.html
      echo Created source link file for $SourceName to $SourceURI
    else
      echo WARNING: Not processing $ref, $label
    fi
  done
  chmod -R 777 ${imageDir}${first} 2>/dev/null
  echo ------------------------------------------------------
  echo Now run the following comand inside the owl directory of the repository you want to add the files new files to
  echo .
  printf '%s\n' "cat /partition/karenin/VFB/IMAGE_DATA/StackLoader/linkData.tsv | while IFS=$'\t' read -ra VFBI; do last=$(echo ${VFBI[1]} | sed 's|VFB_||g' | cut -c 5-) ; first=$(echo ${VFBI[1]} | sed 's|VFB_||g' |  cut -c 1-4) ; ref=$(echo ${VFBI[1]} | sed 's|VFB_|VFBi_|g') ; ln -sf ../data/VFB/i/$first/$last/ ./$ref ; ln -sf ./${ref}/index.html ./${VFBI[1]} ; echo $ref ;done"
  echo .
  echo ------------------------------------------------------
fi
chmod -R 777 ${imageDir} 2>/dev/null || :
