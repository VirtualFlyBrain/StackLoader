#!/bin/bash
# Find files that match the label, convert to wlz, move the original and the wlz copy to their VFB ref folder.
echo Converting... 1>&3
source /partition/bocian/VFBTools/python-modules-2.6/bin/activate
if [ ! -f ./linkData.tsv ]
then
  echo "linkData.tsv file is missing! See linkData.tsv for an example"
  echo "No images set to load!" 1>&3
else
  export dirName='./PutAlignedFilesInHere/'
  export woolzDir='nice /disk/data/VFBTools/Woolz2013Full/bin/'
  export fijiBin='nice /disk/data/VFBTools/Fiji/ImageJ-linux64 --headless'
  export sriptDir='/disk/data/VFB/IMAGE_DATA/StackProcessing/scripts/'
  export imageDir='/disk/data/VFB/IMAGE_DATA/VFB/i/'
  cat linkData.tsv | while IFS=$'\t' read -ra VFBI
  do
    label=${VFBI[0]}
    ref=${VFBI[1]}
    echo $ref 1>&3
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | sed 's|VFB_||g' | cut -c 5-)
      first=$(echo ${ref} | sed 's|VFB_||g' |  cut -c 1-4)
      nf=$(ls ${dirName}*${label}*.nrrd 2>/dev/null | wc -l)
      if [ $nf -gt 0 ]
      then
        if [ $nf -gt 1 ]
        then
          echo ERROR: Multiple files found for $label when processing $ref
        else
          echo Processing ${ref}...
          file=$(ls ${dirName}*${label}*.nrrd 2>/dev/null)
          echo Found file $file for $label
          echo Converting to woolz format...
          if [ -f ${dirName}volume.wlz ]
          then
            rm -v ${dirName}volume*
          fi
          nice python /partition/bocian/VFBTools/Bound/Bound.py 3 ${file} ${dirName}volume.nrrd
          if [ -f ${dirName}volume.nrrd ]
          then
            script=$fijiBin' -macro '$sriptDir'nrrd2tif.ijm '${dirName}'volume.nrrd -batch'
            echo "Executing script: "$script
            $script

            wait
            sleep 1
            if [ -f ${dirName}volume.tif ]
            then
              #Creating Woolz file: Creating woolz
              script=$woolzDir'WlzExtFFConvert -f tif -F wlz -o '${dirName}'volume.wlz '${dirName}'volume.tif'
              echo "Executing Script: " $script
              $script

              echo "Created woolz!"

              script=$woolzDir"WlzThreshold -H -v2 "${dirName}"volume.wlz"
              echo "Theshold: " $script
              eval $script > ${dirName}volume_th.wlz

              rm -v ${dirName}volume.wlz

              script=$woolzDir"WlzSetVoxelSize ${voxelSize} "${dirName}"volume_th.wlz"
              echo "VoxelSize: " $script
              eval $script > ${dirName}volume.wlz
              if [ -f ${dirName}volume.wlz ]
              then
                rm -v ${dirName}volume_th.wlz
                rm -v ${dirName}volume.tif
                echo "Converted woolz successfully!"
                echo "Moving files:"
                if [ ! -d ${imageDir}${first} ]
                then
                  mkdir ${imageDir}${first}
                fi
                if [ ! -d ${imageDir}${first}/${last} ]
                then
                  mkdir ${imageDir}${first}/${last}
                fi
                if [ -e ${imageDir}${first}/volume.nrrd ]
                then
                  rm ${imageDir}${first}/${last}/volume.nrrd
                fi
                if [ -e ${imageDir}${first}/volume.wlz ]
                then
                  rm ${imageDir}${first}/${last}/volume.wlz
                fi
                mv -v ${file} ${imageDir}${first}/${last}/volume.nrrd
                mv -v ${dirName}volume.wlz ${imageDir}${first}/${last}/volume.wlz
                rm -v ${dirName}volume.nrrd
                # clear thumbnail if one already exists. Auto-created independantly.
                if [ -f ${imageDir}${first}/${last}/thumbnail.png ]
                then
                  rm -v ${imageDir}${first}/${last}/thumbnail.png
                fi
                # clear 3d point cloud if one already exists. Auto-created independantly.
                if [ -f ${imageDir}${first}/${last}/volume.obj ]
                then
                  rm -v ${imageDir}${first}/${last}/volume.obj
                fi

		echo $ref complete
              else
                echo "Error creating woolz!" 1>&3
              fi
            else
              echo ERROR: Failed to convet file $file into tif when processing $ref, $label 1>&3
            fi


          else
            echo ERROR: Failed to convet file $file found containing $label when processing $ref 1>&3
          fi
        fi
      else
        echo ERROR: No files found containing $label when processing $ref 1>&3
      fi
    else
      echo WARNING: Not processing $ref, $label 1>&3
    fi
  done
  chmod -R 777 ${imageDir} 2>/dev/null
fi
