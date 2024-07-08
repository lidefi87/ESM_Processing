import xarray as xr
import os
import matplotlib.pyplot as plt
from glob import glob
import cartopy.crs as ccrs
import re


#List of problem files
list_files = glob('/perm_storage/home/data/CMIP6_data/NorESM2-LM/*/*/*siconc_S*')
# list_files = glob('/perm_storage/home/data/CMIP6_data/NorESM2-MM/*/*/*siconc_S*')

#Sample grid
x = xr.open_dataset('/perm_storage/home/data/CMIP6_data/NorESM2-LM/ssp585/CMIP6.ScenarioMIP.NCC.NorESM2-LM.ssp585.r1i1p1f1.Omon.intpp.gn.v20191108.intpp_Omon_NorESM2-LM_ssp585_r1i1p1f1_gn_201501-202012.nc)
# x = xr.open_dataset('/perm_storage/home/data/CMIP6_data/NorESM2-MM/ssp585/CMIP6.ScenarioMIP.NCC.NorESM2-MM.ssp585.r1i1p1f1.Omon.intpp.gn.v20191108.intpp_Omon_NorESM2-MM_ssp585_r1i1p1f1_gn_201501-202012.nc')

#Correct grid
for f in list_files:
  f_out = re.sub("/raw/", "/", f)
  ds = xr.open_dataset(f, autoclose = True)
  ds.coords['lat'] =  (('y', 'x'), x.lat.values[0:384])
  ds.coords['lon'] =  (('y', 'x'), x.lon.values[0:384])
  ds.to_netcdf(f_out)


list_files = glob('/perm_storage/home/data/CMIP6_data/NorESM2-MM/ssp585/*siconc_S*')
len(list_files)
ds = xr.open_mfdataset(list_files)
t1 = ds.siconc.sel(time = slice('2015', '2024'))
t2 = ds.siconc.sel(time = slice('2091', '2100'))
ds_sub = xr.concat([t1, t2], dim = 'time')
[f_out] = glob('/perm_storage/home/data/CMIP6_data/NorESM2-MM/ssp585/*siconc*2024_2091*')
f_out
ds_sub.to_netcdf(f_out)
del ds, t1, t2, ds_sub


[list_files] = glob('/perm_storage/home/data/CMIP6_data/NorESM2-LM/historical/*siconc*1850-1859_2005*')
ds = xr.open_dataarray(list_files)
t1 = ds.sel(time = slice('1850', '1859')).groupby('time.month').mean('time')
t2 = ds.sel(time = slice('2005', '2014')).groupby('time.month').mean('time')
[f_out1] = glob('/perm_storage/home/data/CMIP6_data/NorESM2-LM/historical/*siconc*Mean.1850-1859.nc')
[f_out2] = glob('/perm_storage/home/data/CMIP6_data/NorESM2-LM/historical/*siconc*Mean.2005-2014.nc')
t1.to_netcdf(f_out1)
t2.to_netcdf(f_out2)
del ds, t1, t2


list_files = glob('/perm_storage/home/data/CMIP6_data/NorESM2-LM/historical/*siconc*Mean*[0-9].nc')
len(list_files)

for f in list_files:
  ds = xr.open_dataarray(f)
  ds_so = ds.where(ds.lat <= -30, drop = True)
  f_out = re.sub(".nc$", "_SouthernOcean.nc", f)
  ds_so.to_netcdf(f_out)


fig = plt.figure()
ax = fig.add_subplot(111, projection = ccrs.SouthPolarStereo())
# x.intpp.isel(time = 0).plot(x= 'lon', y= 'lat', transform = ccrs.PlateCarree())
ds_so.isel(month = 0).plot(x= 'lon', y= 'lat', transform = ccrs.PlateCarree())
plt.show()
plt.close()








