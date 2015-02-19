#!/bin/bash
# Find files that match the label, convert to wlz, move the original and the wlz copy to their VFB ref folder.
if [ ! -f ./linkData.tsv ]
then
  echo "linkData.tsv file is missing! See linkData.tsv for an example"
else
  export dirName='./PutAlignedFilesInHere/'
  export woolzDir='nice /disk/data/VFBTools/Woolz2013Full/bin/'
  export fijiBin='nice /disk/data/VFBTools/Fiji/ImageJ-linux64 --headless'
  export sriptDir='/disk/data/VFB/IMAGE_DATA/StrackProcessing/scripts/'
  export imageDir='/disk/data/VFB/IMAGE_DATA/VFB/i/'
  export thumbGen='nice python /disk/data/VFBTools/3DstackDisplay/images2MaxProjPNG_tn.py'
  cat linkData.tsv | while IFS=$'\t' read -ra VFBI
  do 
    label=${VFBI[0]}
    ref=${VFBI[1]}
    if [[ $ref == "VFB_"* ]]
    then
      last=$(echo ${ref} | replace 'VFB_' '' | cut -c 5-)
      first=$(echo ${ref} | replace 'VFB_' '' |  cut -c 1-4)
      nf=$(ls ${dirName}*${label}*.nrrd | wc -l)
      if [ nf -gt 0 ]
      then
        if [ nf -gt 1 ]
        then
          echo ERROR: Multiple files found for $label when processing $ref
        else
          echo Processing ${ref}...
          file=$(ls ${dirName}*${label}*.nrrd)
          echo Found file $file for $label
          echo Converting to woolz format...
          if [ -f ${dirName}volume.wlz ] 
          then 
            rm -v ${dirName}volume*
          fi
          nice python /disk/data/VFBTools/python\ packages/Bound.py 3 ${file} ${dirName}volume.nrrd 
          if [ -f ${dirName}volume.wlz ]
          then
            script=$fijiBin' -macro '$sriptDir'nrrd2tif.ijm '${dirName}'volume.nrrd -batch'
            echo "Executing script: "$script
            $script
            
            wait
            sleep 1
            if [ -f ${dirName}volume.tif ]
            then
              #Creating Woolz file: Creating woolz
              script=$woolzDir'WlzExtFFConvert -f tif -F wlz -o '$dirName'/wlz/0020.wlz '${dirName}'volume.tif'
              echo "Executing Script: " $script
              $script
              
              echo "Created woolz!"
              
              script=$woolzDir"WlzThreshold -v2 "${dirName}"volume.wlz"
              echo "Theshold: " $script
              eval $script > ${dirName}volume_th.wlz
              
              rm -v ${dirName}volume.wlz
              
              script=$woolzDir"WlzSetVoxelSize -x1 -y1 -z1.5 "${dirName}"volume_th.wlz"
              echo "VoxelSize: " $script
              eval $script > ${dirName}volume.wlz
              if [ -f ${dirName}volume.wlz ]
              then
                rm -v ${dirName}volume_th.wlz
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
                mv -v ${file} ${imageDir}${first}/${last}/volume.nrrd
                mv -v ${dirName}volume.wlz 
                rm -v ${dirName}volume.nrrd
                
                echo "Handling Thumbnails:"
                nf=$(ls ${dirName}*${label}*.png | wc -l)
                if [ nf -gt 0 ]
                then
                  if [ nf -gt 1 ]
                  then
                    echo ERROR: Multiple files found for $label when processing $ref
                  else
                    file=$(ls ${dirName}*${label}*.png)
                    mv -v $file ${imageDir}${first}/${last}/thumbnail.png
                  fi
                else
                  echo WARNING: No thumbnail files found containing $label when processing $ref
                  echo Creating one...
                  ${thumbGen} ${dirName}volume.nrrd
                  mv -v ${dirName}volume_tn.png ${dirName}thumbnail.png
                  echo $ref complete
                fi
              else
                echo "Error creating woolz!"
              fi
            else
              echo ERROR: Failed to convet file $file into tif when processing $ref, $label
            fi

    
          else
            echo ERROR: Failed to convet file $file found containing $label when processing $ref
          fi
        fi
      else
        echo ERROR: No files found containing $label when processing $ref
      fi
    else
      echo WARNING: Not processing $ref, $label
    fi
  done  
fi
