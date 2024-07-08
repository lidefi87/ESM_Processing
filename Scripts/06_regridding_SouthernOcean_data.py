#Load libraries
import xarray as xr
# import os
from glob import glob
import xesmf as xe
import matplotlib.pyplot as plt
import re

#Loading taregt data and select Southern Ocean only
da = xr.open_dataarray('cellarea_15arcmin.nc').sel(lat = slice(-30, -80))

#Get a list of files for the Southern Ocean
so_files = glob("/perm_storage/home/data/CMIP6_data/*/*/*SouthernOcean*")

#Loop through all files
for f in so_files:
  #New file path for regridded file
  f_out = re.sub("Ocean.nc", "Ocean_regulargrid.nc", f)
  #Load Southern Ocean file
  ds = xr.open_dataset(f)
  if(ds.lon.values.max()>180):
    ds['lon'] = ((ds['lon'] + 180)%360)-180
  if(ds.lat.max() > -30):
    continue
  #Calculate regridding
  reg_hr = xe.Regridder(ds, da, 'bilinear')
  #Apply regridder
  reg_obs = reg_hr(ds)
  #Save regridded file
  reg_obs.to_netcdf(f_out)
