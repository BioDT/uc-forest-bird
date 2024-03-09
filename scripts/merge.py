'''
 Script to read LUKE volume and age files, assign all nodata values (32766) to one shared nodata value (32767) and merge all tiles in inputdirectory; takes inputdirectory and outputfilename
 '''

import sys
import rasterio
import rasterio.merge
import glob

inputdir = sys.argv[1]
outfile = sys.argv[2]

files = glob.glob(inputdir + '*.tif')

with rasterio.open(files[0]) as f:
    out_meta = f.meta.copy()

arr, transform = rasterio.merge.merge(files)
arr[arr == 32766] = 32767

out_meta.update({
    "height": arr.shape[1],
    "width": arr.shape[2],
    "transform": transform,
    })


with rasterio.open(outfile, 'w', **out_meta) as f:
    f.write(arr)

