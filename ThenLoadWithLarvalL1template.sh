#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB...
# Note: All files will be removed after processing.
# Then apply these stacks against CATMAID Larval L1 light level template (005)
export template=005
export voxelSize='-x380.0 -y380.0 -z50.0'
export zSlice='50.0'
./src/convert.sh
./src/setTemplate.sh
