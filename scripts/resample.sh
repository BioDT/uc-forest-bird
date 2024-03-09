# script to resample volume and age; taking input directory and outputdirectory

INPUT=$1
OUTDIR=$2

for FILE in "$INPUT"*.tif
do
  if [[ "$FILE" != *age* ]];then
    # unset no data value to include 0 in the calculations for volume, but not for age
    gdal_edit.py $FILE -unsetnodata
  fi
   #full filename from path 
   NAME="$(basename -- $FILE)"
   echo $NAME
   #remove extension from filename 
   FILENAME="${NAME%.*}"  
   # resample to 100x100 pixelsize by averaging original pixels 
   gdalwarp -tr 100.0 100.0 -r average -of GTiff $FILE "$OUTDIR"/"$FILENAME"_resampled.tif

done


