Accessing and downloading CMIP6 data
================
Denisse Fierro Arcos
2022-10-28

-   <a href="#accessing-and-downloading-subsets-of-cmip6-data"
    id="toc-accessing-and-downloading-subsets-of-cmip6-data">Accessing and
    downloading subsets of CMIP6 data</a>
    -   <a href="#switching-to-python" id="toc-switching-to-python">Switching to
        <code>Python</code></a>
    -   <a href="#loading-python-libraries"
        id="toc-loading-python-libraries">Loading <code>Python</code>
        libraries</a>
    -   <a href="#transforming-cmip6-search-results-into-a-python-variable"
        id="toc-transforming-cmip6-search-results-into-a-python-variable">Transforming
        CMIP6 search results into a <code>Python</code> variable</a>
    -   <a href="#accessing-and-saving-cmip6-data"
        id="toc-accessing-and-saving-cmip6-data">Accessing and saving CMIP6
        data</a>
    -   <a href="#checking-subsetted-data"
        id="toc-checking-subsetted-data">Checking subsetted data</a>
    -   <a href="#plotting-results" id="toc-plotting-results">Plotting
        results</a>

## Accessing and downloading subsets of CMIP6 data

We will now switch to `Python` to make use of the `xmip` library that
allow us to standardise variable names for CMIP6 data.

### Switching to `Python`

The `reticulate` package in `R` allow us to use `Python` within an `R`
script. We will be using a `conda environment` which in simple terms is
a directory that contains all the `Pyhton` libraries and the
dependencies needed to run this script. The `README` file in this
repository has instructions on how to create this environment.

``` r
#Activating the conda environment containing relevant Python libraries
use_condaenv("CMIP6_data")
```

### Loading `Python` libraries

``` python
#Easy access to data hosted online
import requests

#Loading and manipulating netcdf files
from netCDF4 import Dataset
import xarray as xr
import numpy as np
import pandas as pd

#Standardisation of CMIP6 data for easy data post-processing
from xmip.preprocessing import rename_cmip6, promote_empty_dims, broadcast_lonlat#, replace_x_y_nominal_lat_lon

#Dealing with file paths
import os
from glob import glob

#Plotting
import matplotlib.pyplot as plt
```

### Transforming CMIP6 search results into a `Python` variable

In this step we can use either of the search results. In the example
below, we will be working with the merged search results.

``` python
#Load data and ensure there are no duplicates
CMIP6_query = pd.read_csv("../Outputs/results_merged.csv").drop_duplicates()

CMIP6_query = CMIP6_query.astype({'decade_0_start': 'int32', 'decade_0_end': 'int32',\
'decade_N_start': 'int32', 'decade_N_end': 'int32'})

CMIP6_query.head(n = 2)
```

    ##                                              file_id  ...                                           out_path
    ## 0  CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1...  ...  /perm_storage/home/data/CMIP6_data/ACCESS-ESM1...
    ## 1  CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1...  ...  /perm_storage/home/data/CMIP6_data/ACCESS-ESM1...
    ## 
    ## [2 rows x 34 columns]

### Accessing and saving CMIP6 data

We will define a new function that will access the CMIP6 data, load into
memory, extract years of interest and standardise all variable names
before saving a copy locally.

``` python
def download_CMIP6(df):
  #Getting key information to load CMIP6 data locally from query results
  #URL address (include "#mode=bytes" at the end of the URL if not working)
  url = np.unique(df['file_url'])
  #Variable name
  var_id = np.unique(df['variable_id']).tolist()
  #Start decades
  dec_0 = int(np.unique(df['decade_0_start']))
  dec_N = int(np.unique(df['decade_N_start']))
  #File paths
  out_folder = np.unique(df['out_full_folder']).tolist()
  #Ensuring folder exists
  os.makedirs(out_folder[0], exist_ok = True)
  #File name with full path
  out_file = np.unique(df['out_path']).tolist()
  
  ds = []
  for ind in df.index:
    #Loading data to memory in a temporary file
    link = requests.get(url[ind]).content
    remote = Dataset(var_id, memory = link)
    #Loading as xarray dataset
    sub = xr.open_dataset(xr.backends.NetCDF4DataStore(remote))
    ds.append(sub)
  ds = xr.concat(ds, dim = 'time')
    
  #Standardising CMIP6 data
  ds = rename_cmip6(ds)
  ds = promote_empty_dims(ds)
  ds = broadcast_lonlat(ds)
  #ds = replace_x_y_nominal_lat_lon(ds)
  
  #Subsetting data - First and last decade and stitching them together
  d0 = ds.sel(time = slice(str(dec_0), str(dec_0+9)))
  dN = ds.sel(time = slice(str(dec_N), str(dec_N+9)))
  
  #Combining first and last decade into one dataset
  ds_sub = xr.concat([d0, dN], dim = 'time')
  
  #Saving subsetted dataset
  ds_sub.to_netcdf(out_file[0])
```

We will loop through each item in the search results.

``` python
#Starting loop through each model
for mod in np.unique(CMIP6_query['source_id']):
  print(mod)
  mod_id = CMIP6_query[CMIP6_query['source_id'] == mod].reset_index()
  #Group by variable name, experiment ID and grid type before starting data download
  for names, sub in mod_id.groupby(['experiment_id', 'grid_label', 'variable_id']):
    print(sub[['experiment_id', 'grid_label', 'variable_id']])
    download_CMIP6(sub.reset_index())
```

### Checking subsetted data

We can load one of the datasets we saved in the previous step to check
its contents.

``` python
#Loading last dataset saved locally
ds = xr.open_dataset(CMIP6_query['out_path'][10])
#Checking contents
ds
```

    ## <xarray.Dataset>
    ## Dimensions:      (time: 240, bnds: 2, y: 300, x: 360, vertex: 4)
    ## Coordinates:
    ##   * time         (time) datetime64[ns] 2015-01-16T12:00:00 ... 2100-12-16T12:...
    ##     time_bounds  (time, bnds) datetime64[ns] ...
    ##   * y            (y) int32 0 1 2 3 4 5 6 7 8 ... 292 293 294 295 296 297 298 299
    ##   * x            (x) int32 0 1 2 3 4 5 6 7 8 ... 352 353 354 355 356 357 358 359
    ##     lat          (y, x) float64 ...
    ##     lon          (y, x) float64 ...
    ##     lat_bounds   (time, y, x, vertex) float64 ...
    ##     lon_bounds   (time, y, x, vertex) float64 ...
    ##   * bnds         (bnds) int64 0 1
    ##   * vertex       (vertex) int64 0 1 2 3
    ## Data variables:
    ##     type         |S7 ...
    ##     siconc       (time, y, x) float32 ...
    ## Attributes: (12/47)
    ##     Conventions:            CF-1.7 CMIP-6.2
    ##     activity_id:            ScenarioMIP
    ##     branch_method:          standard
    ##     branch_time_in_child:   60265.0
    ##     branch_time_in_parent:  60265.0
    ##     creation_date:          2020-08-17T00:31:08Z
    ##     ...                     ...
    ##     variable_id:            siconc
    ##     variant_label:          r1i1p1f1
    ##     version:                v20200817
    ##     license:                CMIP6 model data produced by CSIRO is licensed un...
    ##     cmor_version:           3.4.0
    ##     tracking_id:            hdl:21.14100/41a18599-3d5b-4d43-92b3-ce1c28b2da2a

### Plotting results

Finally, we can calculate monthly means over the first decade of
interest and plot these results.

``` python
#Selecting the first decade
ds = ds.sel(time = str(CMIP6_query['decade_0_start'][10]))
#Calculating monthly means and plotting only the first month
ds[CMIP6_query['variable_id'][10]].mean('time').plot(levels = 9)
#Show plot
plt.show()
#Close plot if needed
#plt.close()
```

![](02a_Downloading_CMIP6_data_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

In this notebook, we have successfully downloading a subset of the CMIP6
datasets that we identified in [the first
notebook](01_Querying_CMIP6_database.md). Next, we will describe how to
calculate monthly means from the datasets that we saved locally.
