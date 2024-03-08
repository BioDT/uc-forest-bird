import rasterio
import rasterio.merge
from pathlib import Path

out_fpath = 'out.tif'

files = list(Path('.').glob('data/koivu*.tif'))

with rasterio.open(files[0]) as f:
    out_meta = f.meta.copy()

arr, transform = rasterio.merge.merge(files)
arr[arr == 32766] = 32767

out_meta.update({
    "height": arr.shape[1],
    "width": arr.shape[2],
    "transform": transform,
    })


with rasterio.open(out_fpath, 'w', **out_meta) as f:
    f.write(arr)

