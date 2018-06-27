#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB...
# Note: All files will be removed after processing.
# Then apply these stacks against Symetirc Female VNS light level template (005)
export template=005
export voxelSize='-x0.4612588 -y0.4612588 -z0.7'
export zSlice='0.7'
./src/convert.sh
./src/setTemplate.sh
