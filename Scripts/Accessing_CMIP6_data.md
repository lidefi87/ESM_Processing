Accessing CMIP6 ESM data
================
Denisse Fierro Arcos
2022-10-12

-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#loading-libraries" id="toc-loading-libraries">Loading
        libraries</a>
    -   <a href="#querying-esgf-server" id="toc-querying-esgf-server">Querying
        ESGF server</a>
        -   <a href="#reviewing-and-tidying-up-search-results"
            id="toc-reviewing-and-tidying-up-search-results">Reviewing and tidying
            up search results</a>
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

# Introduction

In this notebook we will access Coupled Model Intercomparison Project
Phase 6 (CMIP6) data from the Earth System Grid Federation
([ESGF](https://esgf.nci.org.au/search/cmip6-nci/)) platform.

We will be using some functions from the
[epwshiftr](https://github.com/ideas-lab-nus/epwshiftr) package, which
have been modified slightly to access ocean and sea ice outputs.

Once the correct datasets have been identified, a subset of the dataset
will be selected and downloaded to your local machine. Here we have
chosen to select the first and last decades for each dataset, that is
from 1850 to 1859 and from 2005 to 2014 for the historical runs, and
from 2015 to 2024 and from 2091 to 2100 for the shared socioeconomic
pathways (SSPs). Future scenario runs up to 2300 have been excluded
here.

## Loading libraries

The functions adapted from `epwshiftr`, which are on the accompanying
`search_download_functions` script will help us connect to the
Australian-based ESGF node hosted by the National Computational
Infrastructure ([NCI](http://nci.org.au/)). There are several ESGF nodes
available worldwide and they can be found
[here](https://aims2.llnl.gov/nodes). If you wish to change the node
used in the script use the `node_url` parameter of the `cmip6_index`
function to provide the link to the search page for the node. The link
should look like this: <https://esgf.nci.org.au/esg-search/search/?> and
it points to a `xml` file, which is similar to a table of contents for
the datasets available within the node.

All other libraries allow us to manipulate and save CMIP6 data.

``` r
search_CMIP6 <- source("search_download_functions.R")
library(tidyverse)
# library(purrr)
# library(metR)
library(reticulate)
```

## Querying ESGF server

We will use the `cmip6_index` function included in the accompanying
`search_download_functions` script to search the Australian node of
ESGF. We save the results as a table in our environment.

There are thousands of CMIP6 endorsed model outputs available through
ESGF, so providing as many parameters as possible in the database search
is important to narrow down results. You could refer to the following
websites for more information:  
- [CMIP6
documentation](https://github.com/ES-DOC/esdoc-docs/tree/master/cmip6/experiments/spreadsheet) -
[CMIP6 controlled vocabulary](https://github.com/WCRP-CMIP/CMIP6_CVs) -
[World Climate Research Programme
(WCRP)](https://www.wcrp-climate.org/modelling-wgcm-mip-catalogue/modelling-wgcm-cmip6-endorsed-mips) -
[CMIP6 overview](https://pcmdi.llnl.gov/CMIP6/) - [CMIP6 Guidance for
Data Users](https://pcmdi.llnl.gov/CMIP6/Guide/dataUsers.html) - [CMIP6
Data Request](https://clipc-services.ceda.ac.uk/dreq/mipVars.html) -
[CMIP6 Global Attributes
Definitions](https://docs.google.com/document/d/1h0r8RZr_f3-8egBMMh7aqLwy3snpD6_MrDz1q8n5XUk/edit)

Note that parameters are compulsory, we can provide as many or as little
as needed.

``` r
results_query <- cmip6_index(
  # This parameter relates to the broad experiment group a dataset belongs to. In this example we consider:
  # CMIP (past conditions) and ScenarioMIP (future scenarios, SSPs) activities
  activity = c("ScenarioMIP", "CMIP"),
  
  # Standardised name for variables of interest - See CMIP6 Data Request for more information
  variable = c("tos", "siconc", "intpp"),
  
  # This ranges from hours to years - See CMIP6 Data Request for frequency available for each variable
  frequency = "mon",
  
  # Specifying experiment names - Descriptions are available in the CMIP6 documentation
  experiment = c("ssp126", "ssp245", "ssp585", "historical"),
  
  # Specifying model names - A list of all models can be found in the CMIP6 controlled vocabulary link
  source = "ACCESS-ESM1-5",
  
  # Specifying variant, which refers to the model run 
  variant = "r1i1p1f1",
  
  # Specifying time frame of interest
  years = NULL,
  
  # Save to data dictionary
  save = TRUE
  
  # This is how we specify the node that we want to use. The default node is NCI (Australia).
  #node_url = NULL
)

#We will only show the first three results of our search.
head(results_query, n = 3)
```

    ##                                                                                                                                                        file_id
    ## 1: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ## 2:     CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ## 3:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##                                                                                       dataset_id
    ## 1:    CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ## 2:      CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ## 3: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##    mip_era activity_drs institution_id     source_id experiment_id member_id
    ## 1:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ## 2:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ## 3:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##    table_id frequency grid_label  version nominal_resolution variable_id
    ## 1:     Omon       mon         gn 20191115             250 km       intpp
    ## 2:     Omon       mon         gn 20191115             250 km         tos
    ## 3:     Omon       mon         gn 20191115             250 km       intpp
    ##                                                 variable_long_name
    ## 1: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 2:                                         Sea Surface Temperature
    ## 3: Primary Organic Carbon Production by All Types of Phytoplankton
    ##    variable_units datetime_start datetime_end file_size       data_node
    ## 1:    mol m-2 s-1     1850-01-01   2014-12-01 500537777 esgf.nci.org.au
    ## 2:           degC     1850-01-01   2014-12-01 490332982 esgf.nci.org.au
    ## 3:    mol m-2 s-1     2015-01-01   2100-12-01 261237227 esgf.nci.org.au
    ##                                                                                                                                                                                        file_url
    ## 1: http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 2:     http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 3:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##                                          dataset_pid
    ## 1: hdl:21.14100/311d0772-ce1e-3440-8745-85eb365c65e0
    ## 2: hdl:21.14100/f485bfb8-0aa6-3ba1-a413-9ffa4a2e9ef2
    ## 3: hdl:21.14100/1997ec1e-1ffb-3133-a4f5-efd9d1f53ab9
    ##                                          tracking_id
    ## 1: hdl:21.14100/44046366-ac50-4be5-bf42-e1be7c65e37e
    ## 2: hdl:21.14100/02850fcc-be64-40de-b7ca-9b8aa6e688a0
    ## 3: hdl:21.14100/5ab2f881-d384-4b73-b358-25c33a1d8eb7

### Reviewing and tidying up search results

We will add a few extra columns into our results data frame that will
help us automate the extraction and storage of the data we need. We will
also ensure that any datasets beyond 2100 are removed from our results.

For this example, we are interested in extracting data for the first and
last decade of each experiment.

But first, we will provide the file path to the folder where we will
save our data.

``` r
out_folder <- "/perm_storage/home/data/CMIP6_data"
```

Now we will add the columns we need to automate process into the search
results data frame.

``` r
results_query <- results_query %>%
  #Removing any datasets ending after 2100
  filter(year(datetime_end) <= 2100) %>% 
  #Defining the first and last decade of each experiment
  mutate(decade_0_start = year(datetime_start),
         decade_0_end = decade_0_start+9L,
         decade_N_start = year(datetime_end)-9L,
         decade_N_end = year(datetime_end),
         #Defining the name of the model outputs that we will save locally
         out_file_name = paste0(str_split(dataset_id, pattern = "\\|", 
                                          simplify = T)[1,1],
                                ".", decade_0_start, "-", decade_0_end,
                                "_", decade_N_start, "-", decade_N_end,
                                ".nc"),
         #Defining the correct file path for local copies
         out_full_folder = file.path(out_folder, source_id, experiment_id),
         #Defining full file path for subset data
         out_path = file.path(out_full_folder, out_file_name))

head(results_query, n = 3)
```

    ##                                                                                                                                                        file_id
    ## 1: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ## 2:     CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ## 3:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##                                                                                       dataset_id
    ## 1:    CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ## 2:      CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ## 3: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##    mip_era activity_drs institution_id     source_id experiment_id member_id
    ## 1:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ## 2:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ## 3:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##    table_id frequency grid_label  version nominal_resolution variable_id
    ## 1:     Omon       mon         gn 20191115             250 km       intpp
    ## 2:     Omon       mon         gn 20191115             250 km         tos
    ## 3:     Omon       mon         gn 20191115             250 km       intpp
    ##                                                 variable_long_name
    ## 1: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 2:                                         Sea Surface Temperature
    ## 3: Primary Organic Carbon Production by All Types of Phytoplankton
    ##    variable_units datetime_start datetime_end file_size       data_node
    ## 1:    mol m-2 s-1     1850-01-01   2014-12-01 500537777 esgf.nci.org.au
    ## 2:           degC     1850-01-01   2014-12-01 490332982 esgf.nci.org.au
    ## 3:    mol m-2 s-1     2015-01-01   2100-12-01 261237227 esgf.nci.org.au
    ##                                                                                                                                                                                        file_url
    ## 1: http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 2:     http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 3:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##                                          dataset_pid
    ## 1: hdl:21.14100/311d0772-ce1e-3440-8745-85eb365c65e0
    ## 2: hdl:21.14100/f485bfb8-0aa6-3ba1-a413-9ffa4a2e9ef2
    ## 3: hdl:21.14100/1997ec1e-1ffb-3133-a4f5-efd9d1f53ab9
    ##                                          tracking_id decade_0_start
    ## 1: hdl:21.14100/44046366-ac50-4be5-bf42-e1be7c65e37e           1850
    ## 2: hdl:21.14100/02850fcc-be64-40de-b7ca-9b8aa6e688a0           1850
    ## 3: hdl:21.14100/5ab2f881-d384-4b73-b358-25c33a1d8eb7           2015
    ##    decade_0_end decade_N_start decade_N_end
    ## 1:         1859           2005         2014
    ## 2:         1859           2005         2014
    ## 3:         2024           2091         2100
    ##                                                                                        out_file_name
    ## 1: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.1850-1859_2005-2014.nc
    ## 2: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.1850-1859_2005-2014.nc
    ## 3: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.2015-2024_2091-2100.nc
    ##                                                out_full_folder
    ## 1: /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/historical
    ## 2: /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/historical
    ## 3:     /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/ssp245
    ##                                                                                                                                                         out_path
    ## 1: /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/historical/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.1850-1859_2005-2014.nc
    ## 2: /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/historical/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.1850-1859_2005-2014.nc
    ## 3:     /perm_storage/home/data/CMIP6_data/ACCESS-ESM1-5/ssp245/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.2015-2024_2091-2100.nc

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

#Standardisation of CMIP6 data for easy data post-processing
from xmip.preprocessing import rename_cmip6, replace_x_y_nominal_lat_lon

#Dealing with file paths
import os
```

### Transforming CMIP6 search results into a `Python` variable

``` python
CMIP6_query = r.results_query
CMIP6_query.head(n = 2)
```

    ##                                              file_id  ...                                           out_path
    ## 0  CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1...  ...  /perm_storage/home/data/CMIP6_data/ACCESS-ESM1...
    ## 1  CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1...  ...  /perm_storage/home/data/CMIP6_data/ACCESS-ESM1...
    ## 
    ## [2 rows x 30 columns]

### Accessing and saving CMIP6 data

We will now load the CMIP6 data into a temporary file in memory, so we
can subset it, standardise its variables names and save a local copy. We
will loop through each item in the search results.

``` python
#Starting loop
for i in CMIP6_query.index:
  #Getting key information to load CMIP6 data locally from query results
  #URL address (include "#mode=bytes" at the end of the URL if not working)
  url = CMIP6_query['file_url'][i]
  #Variable name
  var_id = CMIP6_query['variable_id'][i]
  #Start decades
  dec_0 = CMIP6_query['decade_0_start'][i]
  dec_N = CMIP6_query['decade_N_start'][i]
  #File paths
  out_folder = CMIP6_query['out_full_folder'][i]
  out_file = CMIP6_query['out_path'][i]
  
  #Loading data to memory in a temporary file
  link = requests.get(url).content
  remote = Dataset(var_id, memory = link)
  
  #Loading as xarray dataset
  ds = xr.open_dataset(xr.backends.NetCDF4DataStore(remote))
  
  #Standardising CMIP6 data
  ds = rename_cmip6(ds)
  ds = replace_x_y_nominal_lat_lon(ds)
  
  #Subsetting data - First and last decade
  ds_sub = xr.concat([ds.sel(time = slice(str(dec_0), str(dec_0+9))),\
  ds.sel(time = slice(str(dec_N), str(dec_N+9)))], dim = 'time')
  
  #Ensure folder path exists
  os.makedirs(out_folder, exist_ok = True)
  
  #Saving subsetted dataset
  ds.to_netcdf(out_file)
```
