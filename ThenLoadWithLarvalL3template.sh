#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB...
# Note: All files will be removed after processing.
# Then apply these stacks against David Wood's Larval L3 light level template (003)
export template=003
export voxelSize='-x0.29 -y0.29 -z0.5'
export zSlice='0.5'
./src/convert.sh
./src/setTemplate.sh
