#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB... 
# Note: All files will be removed after processing.
# Then apply these stacks against the JFRC adult main brain template (001)
export template=001
export voxelSize='-x0.622088 -y0.622088 -z0.622088'
./src/convert.sh
./src/setTemplate.sh
