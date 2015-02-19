#!/bin/bash
# Assign convert and these stacks against the JFRC adult main brain template (001)
export template=001
expost voxelSize='-x0.622088 -y0.622088 -z0.622088'
./src/convert.sh
./src/setTemplate.sh
