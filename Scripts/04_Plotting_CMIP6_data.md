Plotting CMIP6 ESM data in R
================
Denisse Fierro Arcos
2022-10-29

-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#loading-libraries" id="toc-loading-libraries">Loading
        libraries</a>
    -   <a href="#loading-search-results-from-first-notebook"
        id="toc-loading-search-results-from-first-notebook">Loading search
        results from <span>first notebook</span></a>
    -   <a href="#loading-data-using-python"
        id="toc-loading-data-using-python">Loading data using Python</a>
    -   <a href="#loading-relevant-python-libraries"
        id="toc-loading-relevant-python-libraries">Loading relevant Python
        libraries</a>

# Introduction

In this notebook, we will use the `xarray`, `matplotlib` and `cartopy`
libraries in `Python` to plot monthly decadal means calculated from the
CMIP6 data in our previous notebooks for
[`R`](%2203a_Calculating_monthly_means_in_R.md%22) or
[`Python`](%2203b_Calculating_monthly_means_in_Python.md%22).

## Loading libraries

``` r
library(tidyverse)
library(reticulate)
```

## Loading search results from [first notebook](01_Querying_CMIP6_database.md)

We will use the search results from the first notebook to find the files
we need. We will only focus on the `intpp` variable and the `ssp245`
scenario. This first part of the script is done in `R` because it offers
an easy way to manipulate tabular data.

``` r
#Loading search results
results_query <- read_csv("../Outputs/results_query_intpp.csv") %>% 
  #We will remove any duplicated entries - based on the output file name
  distinct(out_file_name, .keep_all = T) %>% 
  mutate(mean_dec0 = NA,
         mean_decN = NA)
```

    ## Rows: 39 Columns: 33
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr  (23): file_id, dataset_id, mip_era, activity_drs, institution_id, sourc...
    ## dbl   (7): version, file_size, count, decade_0_start, decade_0_end, decade_N...
    ## lgl   (1): keep
    ## dttm  (2): datetime_start, datetime_end
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

Adding the full file path for the files containing the mean `intpp`
values for the first and last decade for each model.

``` r
for(i in 1:nrow(results_query)){
  results_query$mean_dec0[i] = list.files(results_query$out_full_folder[i],
                                          pattern = paste0("*.intpp.*Mean.", results_query$decade_0_start[i]), 
                                          full.names = T)
  results_query$mean_decN[i] = list.files(results_query$out_full_folder[i],
                                          pattern = paste0("*.intpp.*Mean.", results_query$decade_N_start[i]), 
                                          full.names = T)
}

#Checking results
head(results_query, n = 2)
```

    ## # A tibble: 2 × 35
    ##   file_id        datas…¹ mip_era activ…² insti…³ sourc…⁴ exper…⁵ membe…⁶ table…⁷
    ##   <chr>          <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
    ## 1 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… CSIRO   ACCESS… ssp245  r1i1p1… Omon   
    ## 2 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… DKRZ    MPI-ES… ssp245  r1i1p1… Omon   
    ## # … with 26 more variables: frequency <chr>, grid_label <chr>, version <dbl>,
    ## #   nominal_resolution <chr>, variable_id <chr>, variable_long_name <chr>,
    ## #   variable_units <chr>, datetime_start <dttm>, datetime_end <dttm>,
    ## #   file_size <dbl>, data_node <chr>, file_url <chr>, dataset_pid <chr>,
    ## #   tracking_id <chr>, count <dbl>, decade_0_start <dbl>, decade_0_end <dbl>,
    ## #   decade_N_end <dbl>, decade_N_start <dbl>, keep <lgl>, base_file_name <chr>,
    ## #   out_file_name <chr>, out_full_folder <chr>, out_path <chr>, …

## Loading data using Python

We will use the `reticulate` package to load `Python` into our
environment.

``` r
use_condaenv("CMIP6_data")
```

## Loading relevant Python libraries

We will now load relevant libraries that will allow us to load `netcdf`
files and prepare plots easily.

``` python
import xarray as xr
import os
from glob import glob
import calendar
import pandas as pd
import numpy as np

#Packages for plotting
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import cmocean as cm
import cartopy.crs as ccrs
import cartopy.feature as cft
import matplotlib.gridspec as gridspec
```

We will load the query results that we processed at the beginning of
this script. This will help us identify the files that are relevant to
our work. We will also define a new variable called `months_interest`
where we will include the months that we will be plotting in our
figures. In this case, we will plot the months of January and September.

``` python
#We will only keep a handful of columns that are relevant to our plots.
results_query = r.results_query[['variable_id', 'mean_dec0', 'mean_decN', 'source_id', 'experiment_id']]

#We define the months that are interested in plotting.
months_interest = ['January', 'September']

#Getting variable of interest
var = np.unique(results_query['variable_id'])[0]
exp = np.unique(results_query['experiment_id'])[0]
```

The datasets contain a `months` dimension which indicates to which month
the data is linked to. But, it uses numbers to represent the month. We
will update this names are used instead.

``` python
#Starting an empty dictionary to hold results
data = dict()

for i in range(len(results_query)):
  #Loading decadal means
  dec0 = xr.open_dataset(results_query.mean_dec0[i])
  decN = xr.open_dataset(results_query.mean_decN[i])
  #Removing negative values as they are only present in GFDL-ESM4
  dec0 = dec0.where(dec0 >= 0)
  decN = decN.where(decN >= 0)
  #Calculating differences between decades
  diff = dec0-decN
  #Stacking everything together - Decade dimension added to identify data easily
  stack = xr.concat([dec0[var].expand_dims({'decade': ['dec0']}), 
  decN[var].expand_dims({'decade': ['decN']}), 
  diff[var].expand_dims({'decade': ['diff']})], dim = 'decade')
  #Changing months values from digits to names
  stack['month'] = [calendar.month_name[m] for m in stack.month.values]
  #Getting name of model to use it as key in library
  model = results_query.source_id[i]
  #Keeping months of interest only
  data[model] = stack.sel(month = months_interest)
```

\#Finding range of values in data to create colorbar for plots

``` python
#Month of interest
month_plot = months_interest[0]

#Finding maximum and minimum values
min_intpp = min([data[mod][:-1].sel(month = month_plot).min().values for mod in data])
max_intpp = max([data[mod][:-1].sel(month = month_plot).max().values for mod in data])
min_diff = min([data[mod][-1].sel(month = month_plot).min().values for mod in data])
max_diff = max([data[mod][-1].sel(month = month_plot).max().values for mod in data])
```

We will include a few variables to set up plots below.

``` python
#Create colormap for differences
#Ensure colormap diverges at zero regardless of max and min values
divnorm_diff = mcolors.TwoSlopeNorm(vmin = min_diff, vcenter = 0,
vmax = max_diff)
#Create new diverging colormap from existing colormaps to make it
#easy to distinguish positive and negative values
colors1 = plt.cm.magma(np.linspace(0.25, 1, 128))
colors2 = cm.cm.ice_r(np.linspace(0.1, 0.75, 128))
colors = np.vstack((colors1, colors2))
mymap_diff = mcolors.LinearSegmentedColormap.from_list('mymap_diff', colors)
#Set NA values to show as white
mymap_diff.set_bad('white', alpha = 0)

#Create variable containing the Antarctic continent - 50m is medium scale
land_50m = cft.NaturalEarthFeature('physical', 'land', '50m', edgecolor = 'black', 
                                    facecolor = 'gray', linewidth = 0.5)
                                   
#Defining groups for plots
decadeName = {'dec0': 'First decade', 
              'decN': 'Last decade', 
              'diff': 'Difference (first - last)'}

#Getting names of models to be plotted
models = [mod for mod in data.keys()]
```

Finally, we will plot the data for the month selected above. For this
example, the data has been projected to the [Robinson
projection](https://scitools.org.uk/cartopy/docs/latest/reference/projections.html#robinson)
using the `cartopy` package because it is visually appealing. A list of
other projections available in this package can be found
[here](https://scitools.org.uk/cartopy/docs/latest/reference/projections.html#cartopy-projections).

``` python
plt.close()

#Set projection
proj = ccrs.Robinson()

#Set font family and font size for the entire graph
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.size'] = 9

#Create figure with models across rows and decades/comparison across columns
fig, axs = plt.subplots(len(models), len(decadeName), 
                        #Maps will be projected using the selection above
                        subplot_kw = {'projection': proj}, 
                        #Adjusting space between maps
                        gridspec_kw = {'wspace': 0.0, 'hspace': 0.1}, 
                        #Maps to appear close to each other to minimise white space
                        layout = 'constrained', 
                        #Figure size must kept similar ratios for maps to show well
                        figsize = (7, 12.6))

#Looping through every model
for i, mod in enumerate(models):
  #Extracting data for each model and select appropriate month
  x = data[mod].sel(month = month_plot)
  #Looping through every decade
  for j, dec in enumerate(x.decade.values):
    #Add land and coastlines and land
    axs[i, j].add_feature(land_50m)
    axs[i, j].coastlines(resolution = '50m')
    #Plotting decades with power normalised colorbar
    if j < 2:
      p1 = x.sel(decade = dec).plot.pcolormesh('lon', 'lat', ax = axs[i, j], 
      transform = ccrs.PlateCarree(), cmap = cm.cm.speed, vmin = min_intpp, 
      #We will plot up to 80% of the maximum values because maximum values are uncommon
      vmax = max_intpp*0.8, add_colorbar = False, norm = mcolors.PowerNorm(gamma = 0.5))
    else:
      #PLotting differences with colorbar developed in previous chunk
      p2 = x.sel(decade = dec).plot.pcolormesh('lon', 'lat', ax = axs[i, j], transform = ccrs.PlateCarree(),
      cmap = mymap_diff, norm = divnorm_diff, add_colorbar = False)
    #Adding labels to each row and column
    if i == 0 and j == 1:
      dec_lab = decadeName[dec]
      axs[i, j].set_title(f'{dec_lab}\n{mod}')
    elif i == 0 and j != 1:
      dec_lab = decadeName[dec]
      axs[i, j].set_title(f'{dec_lab}\n')
    elif i > 0 and j == 1:
      axs[i, j].set_title(mod)
    else:
      axs[i, j].set_title('')

#Colorbar settings
#Get power of scientific notation
cb = plt.colorbar(p1, ax = axs[i, 0:2], use_gridspec = True, orientation = 'horizontal',
                  shrink = 0.95, extend = 'max')
cb.set_label(r'Primary Organic Carbon' + '\n' + 'Production (mol $m^{{{-2}}}}$ $s^{{{-1}}}$)', 
y = 5, ha = 'center')

#Difference
cb_dif = plt.colorbar(p2, ax = axs[i, -1], use_gridspec = True, orientation = 'horizontal',
                      shrink = 0.9)
cb_dif.set_label('Difference' + '\n' + '(mol $m^{{{-2}}}$ $s^{{{-1}}}$)', y = 1.5, ha = 'center')

#Add title to figure
fig.suptitle(f'Mean {month_plot} values', y = 1.015)

#Create name of file to be used to save figure
fn = f'../Figures/Mean_monthly_{month_plot}_{var}_comparison_{exp}.png'

#Save figure to disk
plt.savefig(fn, dpi = 300, bbox_inches = 'tight', pad_inches = 0.05)

#The final figure can be seen in the document by activating the line below
# plt.show()
```

We have now finished plotting the mean values for the start and end
decade, as well as the differences between them. We have also saved the
final figure to our local disk. This ends the series of notebooks
guiding you how to query CMIP6 databases, download data, perform basic
calculations and visualise results.
