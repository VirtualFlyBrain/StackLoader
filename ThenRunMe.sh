#!/bin/bash
# Run this script to convert and load files listed in linkData.tsv to /disk/data/VFB/IMAGE_DATA/VFB... 
# Note: All files will be removed after processing.
source /partition/bocian/VFBTools/python-modules-2.7/bin/activate
./src/convert.sh
echo Done.
