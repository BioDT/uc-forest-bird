'''
 Script to read LUKE volume and age files, assign all nodata values (32766) to one shared nodata value (given as input) and merge all tiles in inputdirectory; takes inputdirectory, outputfilename and nodatavalue (32767 for age, 0 for volume) '''

import sys
import rasterio
import rasterio.merge
import glob

inputdir = sys.argv[1]
outfile = sys.argv[2]
nodatavalue = sys.argv[3]

files = glob.glob(inputdir + '*.tif')

with rasterio.open(files[0]) as f:
    out_meta = f.meta.copy()

arr, transform = rasterio.merge.merge(files)

arr[arr == 32766] = 32767
arr[arr == 32767] = nodatavalue

out_meta.update({
    "height": arr.shape[1],
    "width": arr.shape[2],
    "transform": transform,
    "nodata": nodatavalue
    })


with rasterio.open(outfile, 'w', **out_meta) as f:
    f.write(arr)

