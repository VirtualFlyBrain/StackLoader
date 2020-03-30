#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB...
# Note: All files will be removed after processing.
# Then apply these stacks against the JFRC adult main brain template (001)
export template=006
export voxelSize='-x0.512 -y0.512 -z0.512'
export zSlice='0.512'
./src/convert.sh
