Accessing CMIP6 ESM data
================
Denisse Fierro Arcos
2022-10-12

-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#loading-libraries" id="toc-loading-libraries">Loading
        libraries</a>
    -   <a href="#examples" id="toc-examples">Examples</a>
        -   <a href="#preparing-search-results-to-download-data"
            id="toc-preparing-search-results-to-download-data">Preparing search
            results to download data</a>
    -   <a href="#downloading-files" id="toc-downloading-files">Downloading
        files</a>
    -   <a href="#checking-contents-of-netcdf"
        id="toc-checking-contents-of-netcdf">Checking contents of netcdf</a>
    -   <a href="#loading-dataset-with-metr"
        id="toc-loading-dataset-with-metr">Loading dataset with
        <code>metR</code></a>
    -   <a href="#loading-dataset-with-stars"
        id="toc-loading-dataset-with-stars">Loading dataset with
        <code>stars</code></a>

# Introduction

In this notebook we will access Coupled Model Intercomparison Project
Phase 6 (CMIP6) data from the Earth System Grid Federation
([ESGF](https://esgf.nci.org.au/search/cmip6-nci/)) platform.

We will be using some functions from the
[epwshiftr](https://github.com/ideas-lab-nus/epwshiftr) package, which
have been modified slightly to access ocean and sea ice outputs.

## Loading libraries

``` r
search_CMIP6 <- source("search_download_functions.R")
library(tidyverse)
library(metR)
```

## Examples

``` r
idx <- cmip6_index(
  # Including CMIP (past conditions) and ScenarioMIP (projections) activities
  activity = c("ScenarioMIP", "CMIP"),
  
  # SST, Primary Organic Carbon Production, SIC
  variable = c("tos", "siconc", "intpp"),
  
  # specify report frequent
  frequency = "mon",
  
  # specifying experiment names
  experiment = c("ssp126", "ssp245", "ssp585", "historical"),
  
  # specify GCM name
  source = "ACCESS-ESM1-5",
  
  # specify variant,
  variant = "r1i1p1f1",
  
  # specify years of interest
  years = NULL,
  
  # save to data dictionary
  save = TRUE
)

idx
```

    ##                                                                                                                                                               file_id
    ##  1:       CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ##  2:           CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ##  3:        CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##  4:            CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##  5:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.SImon.siconc.gn.v20200817.siconc_SImon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##  6: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.SImon.siconc.gn.v20200817.siconc_SImon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc_0|esgf.nci.org.au
    ##  7:      CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##  8:        CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ##  9:          CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 10:            CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ## 11:          CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 12:            CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ## 13:      CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 14:        CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ## 15:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_1|esgf.nci.org.au
    ## 16:    CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ## 17:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 18:    CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc|esgf.nci.org.au
    ##                                                                                          dataset_id
    ##  1:      CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##  2:        CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ##  3:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##  4:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ##  5: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.SImon.siconc.gn.v20200817|esgf.nci.org.au
    ##  6:    CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.SImon.siconc.gn.v20200817|esgf.nci.org.au
    ##  7:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ##  8:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ##  9:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ## 10:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ## 11:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ## 12:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ## 13:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ## 14:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ## 15: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ## 16: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ## 17: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ## 18: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ##     mip_era activity_drs institution_id     source_id experiment_id member_id
    ##  1:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  2:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  3:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  4:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  5:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  6:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  7:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##  8:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##  9:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ## 10:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ## 11:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 12:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 13:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 14:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 15:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 16:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 17:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ## 18:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##     table_id frequency grid_label  version nominal_resolution variable_id
    ##  1:     Omon       mon         gn 20191115             250 km       intpp
    ##  2:     Omon       mon         gn 20191115             250 km         tos
    ##  3:     Omon       mon         gn 20191115             250 km       intpp
    ##  4:     Omon       mon         gn 20191115             250 km         tos
    ##  5:    SImon       mon         gn 20200817             250 km      siconc
    ##  6:    SImon       mon         gn 20200817             250 km      siconc
    ##  7:     Omon       mon         gn 20210318             250 km       intpp
    ##  8:     Omon       mon         gn 20210318             250 km       intpp
    ##  9:     Omon       mon         gn 20210318             250 km         tos
    ## 10:     Omon       mon         gn 20210318             250 km         tos
    ## 11:     Omon       mon         gn 20210318             250 km         tos
    ## 12:     Omon       mon         gn 20210318             250 km         tos
    ## 13:     Omon       mon         gn 20210318             250 km       intpp
    ## 14:     Omon       mon         gn 20210318             250 km       intpp
    ## 15:    SImon       mon         gn 20210318             250 km      siconc
    ## 16:    SImon       mon         gn 20210318             250 km      siconc
    ## 17:    SImon       mon         gn 20210318             250 km      siconc
    ## 18:    SImon       mon         gn 20210318             250 km      siconc
    ##                                                  variable_long_name
    ##  1: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  2:                                         Sea Surface Temperature
    ##  3: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  4:                                         Sea Surface Temperature
    ##  5:                            Sea-Ice Area Percentage (Ocean Grid)
    ##  6:                            Sea-Ice Area Percentage (Ocean Grid)
    ##  7: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  8: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  9:                                         Sea Surface Temperature
    ## 10:                                         Sea Surface Temperature
    ## 11:                                         Sea Surface Temperature
    ## 12:                                         Sea Surface Temperature
    ## 13: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 14: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 15:                            Sea-Ice Area Percentage (Ocean Grid)
    ## 16:                            Sea-Ice Area Percentage (Ocean Grid)
    ## 17:                            Sea-Ice Area Percentage (Ocean Grid)
    ## 18:                            Sea-Ice Area Percentage (Ocean Grid)
    ##     variable_units datetime_start datetime_end file_size       data_node
    ##  1:    mol m-2 s-1     1850-01-01   2014-12-01 500537777 esgf.nci.org.au
    ##  2:           degC     1850-01-01   2014-12-01 490332982 esgf.nci.org.au
    ##  3:    mol m-2 s-1     2015-01-01   2100-12-01 261237227 esgf.nci.org.au
    ##  4:           degC     2015-01-01   2100-12-01 256505287 esgf.nci.org.au
    ##  5:              %     2015-01-01   2100-12-01  82121102 esgf.nci.org.au
    ##  6:              %     1850-01-01   2014-12-01 166027439 esgf.nci.org.au
    ##  7:    mol m-2 s-1     2015-01-01   2100-12-01 261311595 esgf.nci.org.au
    ##  8:    mol m-2 s-1     2101-01-01   2300-12-01 606339676 esgf.nci.org.au
    ##  9:           degC     2015-01-01   2100-12-01 256376896 esgf.nci.org.au
    ## 10:           degC     2101-01-01   2300-12-01 595184789 esgf.nci.org.au
    ## 11:           degC     2015-01-01   2100-12-01 256432477 esgf.nci.org.au
    ## 12:           degC     2101-01-01   2300-12-01 588382588 esgf.nci.org.au
    ## 13:    mol m-2 s-1     2015-01-01   2100-12-01 261199002 esgf.nci.org.au
    ## 14:    mol m-2 s-1     2101-01-01   2300-12-01 605478129 esgf.nci.org.au
    ## 15:              %     2015-01-01   2100-12-01  79338189 esgf.nci.org.au
    ## 16:              %     2101-01-01   2300-12-01  65296270 esgf.nci.org.au
    ## 17:              %     2015-01-01   2100-12-01  83669672 esgf.nci.org.au
    ## 18:              %     2101-01-01   2300-12-01 190656139 esgf.nci.org.au
    ##                                                                                                                                                                                             file_url
    ##  1:     http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  2:         http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  3:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  4:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  5:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/SImon/siconc/gn/v20200817/siconc_SImon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  6: http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/SImon/siconc/gn/v20200817/siconc_SImon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  7:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ##  8:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc
    ##  9:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ## 10:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc
    ## 11:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 12:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc
    ## 13:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 14:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc
    ## 15:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 16:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_210101-230012.nc
    ## 17:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ## 18:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_210101-230012.nc
    ##                                           dataset_pid
    ##  1: hdl:21.14100/311d0772-ce1e-3440-8745-85eb365c65e0
    ##  2: hdl:21.14100/f485bfb8-0aa6-3ba1-a413-9ffa4a2e9ef2
    ##  3: hdl:21.14100/1997ec1e-1ffb-3133-a4f5-efd9d1f53ab9
    ##  4: hdl:21.14100/feb45e04-2915-3fdd-b2dd-abffa42c5d9b
    ##  5: hdl:21.14100/21ecb154-2707-3afc-875f-8c1517d3fc85
    ##  6: hdl:21.14100/9a49b498-6997-3ad0-8f8c-8ca9c33c1a18
    ##  7: hdl:21.14100/f2c19a60-93cb-3f62-b39f-b18deba189b3
    ##  8: hdl:21.14100/f2c19a60-93cb-3f62-b39f-b18deba189b3
    ##  9: hdl:21.14100/09d00a5d-490a-3fde-8625-39718ec1c4f3
    ## 10: hdl:21.14100/09d00a5d-490a-3fde-8625-39718ec1c4f3
    ## 11: hdl:21.14100/c1440219-32ed-351a-b449-c024d9e17596
    ## 12: hdl:21.14100/c1440219-32ed-351a-b449-c024d9e17596
    ## 13: hdl:21.14100/84531ec4-cdbc-31f5-82ec-cfe9a7209a38
    ## 14: hdl:21.14100/84531ec4-cdbc-31f5-82ec-cfe9a7209a38
    ## 15: hdl:21.14100/16d2d8f3-001d-34e5-8e1f-9fb6b1d7ebb3
    ## 16: hdl:21.14100/16d2d8f3-001d-34e5-8e1f-9fb6b1d7ebb3
    ## 17: hdl:21.14100/b1fc862b-3373-3855-a7cb-7e5b1fbb25c1
    ## 18: hdl:21.14100/b1fc862b-3373-3855-a7cb-7e5b1fbb25c1
    ##                                           tracking_id
    ##  1: hdl:21.14100/44046366-ac50-4be5-bf42-e1be7c65e37e
    ##  2: hdl:21.14100/02850fcc-be64-40de-b7ca-9b8aa6e688a0
    ##  3: hdl:21.14100/5ab2f881-d384-4b73-b358-25c33a1d8eb7
    ##  4: hdl:21.14100/ea8ff790-77c2-4a4c-bc3f-3f2048c626ba
    ##  5: hdl:21.14100/26c69272-0a1c-4d0d-8bb9-0f767c064404
    ##  6: hdl:21.14100/931b0664-d90c-46d5-b9fb-f7f17b8cefd5
    ##  7: hdl:21.14100/3245dfe2-439e-47e2-ba73-332016f091a2
    ##  8: hdl:21.14100/848753e2-a5c3-4450-b238-82a0ae1d54ea
    ##  9: hdl:21.14100/b2b1fd90-3b5e-4e39-8622-ca49cce52038
    ## 10: hdl:21.14100/15830029-440c-4e76-a22d-6c28145356e8
    ## 11: hdl:21.14100/39125f03-b0c7-4cb1-95fd-72e6b2114417
    ## 12: hdl:21.14100/a842cfd0-7c22-4c89-8744-ed6fff9dec50
    ## 13: hdl:21.14100/8903e171-e202-4a0e-9a6f-9564c39b82a6
    ## 14: hdl:21.14100/3054f65e-05f2-4c92-bb8d-8caf1588a1a3
    ## 15: hdl:21.14100/41a18599-3d5b-4d43-92b3-ce1c28b2da2a
    ## 16: hdl:21.14100/1eea2300-1ebe-454a-9431-6237c8df35a7
    ## 17: hdl:21.14100/ac2ebb2c-11d7-4bcb-91e2-32a8fd81990f
    ## 18: hdl:21.14100/5a2faf55-d9fb-4c91-b80d-8109179d6e9f

### Preparing search results to download data

``` r
idx <- idx %>% 
  #Adding a filepath for files to be downloaded as temporary files
  mutate(out_name = file.path(tempdir(), 
                              str_split(file_id, pattern = "\\|", simplify = T)[1,1])) %>% 
  #Removing any datasets ending after 2100
  filter(lubridate::year(datetime_end) <= 2100)

idx
```

    ##                                                                                                                                                               file_id
    ##  1:       CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ##  2:           CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc|esgf.nci.org.au
    ##  3:        CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##  4:            CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.tos.gn.v20191115.tos_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ##  5:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.SImon.siconc.gn.v20200817.siconc_SImon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##  6: CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.SImon.siconc.gn.v20200817.siconc_SImon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc_0|esgf.nci.org.au
    ##  7:      CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##  8:          CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##  9:          CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318.tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 10:      CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318.intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ## 11:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc_1|esgf.nci.org.au
    ## 12:  CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318.siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc_0|esgf.nci.org.au
    ##                                                                                          dataset_id
    ##  1:      CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##  2:        CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ##  3:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ##  4:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.tos.gn.v20191115|esgf.nci.org.au
    ##  5: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.SImon.siconc.gn.v20200817|esgf.nci.org.au
    ##  6:    CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.SImon.siconc.gn.v20200817|esgf.nci.org.au
    ##  7:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ##  8:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ##  9:     CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.tos.gn.v20210318|esgf.nci.org.au
    ## 10:   CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.Omon.intpp.gn.v20210318|esgf.nci.org.au
    ## 11: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp585.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ## 12: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp126.r1i1p1f1.SImon.siconc.gn.v20210318|esgf.nci.org.au
    ##     mip_era activity_drs institution_id     source_id experiment_id member_id
    ##  1:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  2:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  3:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  4:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  5:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ##  6:   CMIP6         CMIP          CSIRO ACCESS-ESM1-5    historical  r1i1p1f1
    ##  7:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##  8:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##  9:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 10:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 11:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp585  r1i1p1f1
    ## 12:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp126  r1i1p1f1
    ##     table_id frequency grid_label  version nominal_resolution variable_id
    ##  1:     Omon       mon         gn 20191115             250 km       intpp
    ##  2:     Omon       mon         gn 20191115             250 km         tos
    ##  3:     Omon       mon         gn 20191115             250 km       intpp
    ##  4:     Omon       mon         gn 20191115             250 km         tos
    ##  5:    SImon       mon         gn 20200817             250 km      siconc
    ##  6:    SImon       mon         gn 20200817             250 km      siconc
    ##  7:     Omon       mon         gn 20210318             250 km       intpp
    ##  8:     Omon       mon         gn 20210318             250 km         tos
    ##  9:     Omon       mon         gn 20210318             250 km         tos
    ## 10:     Omon       mon         gn 20210318             250 km       intpp
    ## 11:    SImon       mon         gn 20210318             250 km      siconc
    ## 12:    SImon       mon         gn 20210318             250 km      siconc
    ##                                                  variable_long_name
    ##  1: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  2:                                         Sea Surface Temperature
    ##  3: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  4:                                         Sea Surface Temperature
    ##  5:                            Sea-Ice Area Percentage (Ocean Grid)
    ##  6:                            Sea-Ice Area Percentage (Ocean Grid)
    ##  7: Primary Organic Carbon Production by All Types of Phytoplankton
    ##  8:                                         Sea Surface Temperature
    ##  9:                                         Sea Surface Temperature
    ## 10: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 11:                            Sea-Ice Area Percentage (Ocean Grid)
    ## 12:                            Sea-Ice Area Percentage (Ocean Grid)
    ##     variable_units datetime_start datetime_end file_size       data_node
    ##  1:    mol m-2 s-1     1850-01-01   2014-12-01 500537777 esgf.nci.org.au
    ##  2:           degC     1850-01-01   2014-12-01 490332982 esgf.nci.org.au
    ##  3:    mol m-2 s-1     2015-01-01   2100-12-01 261237227 esgf.nci.org.au
    ##  4:           degC     2015-01-01   2100-12-01 256505287 esgf.nci.org.au
    ##  5:              %     2015-01-01   2100-12-01  82121102 esgf.nci.org.au
    ##  6:              %     1850-01-01   2014-12-01 166027439 esgf.nci.org.au
    ##  7:    mol m-2 s-1     2015-01-01   2100-12-01 261311595 esgf.nci.org.au
    ##  8:           degC     2015-01-01   2100-12-01 256376896 esgf.nci.org.au
    ##  9:           degC     2015-01-01   2100-12-01 256432477 esgf.nci.org.au
    ## 10:    mol m-2 s-1     2015-01-01   2100-12-01 261199002 esgf.nci.org.au
    ## 11:              %     2015-01-01   2100-12-01  79338189 esgf.nci.org.au
    ## 12:              %     2015-01-01   2100-12-01  83669672 esgf.nci.org.au
    ##                                                                                                                                                                                             file_url
    ##  1:     http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  2:         http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  3:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  4:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/tos/gn/v20191115/tos_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  5:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/SImon/siconc/gn/v20200817/siconc_SImon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ##  6: http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/CMIP/CSIRO/ACCESS-ESM1-5/historical/r1i1p1f1/SImon/siconc/gn/v20200817/siconc_SImon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  7:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ##  8:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ##  9:          http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/tos/gn/v20210318/tos_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 10:      http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/Omon/intpp/gn/v20210318/intpp_Omon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 11:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp585/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp585_r1i1p1f1_gn_201501-210012.nc
    ## 12:  http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp126/r1i1p1f1/SImon/siconc/gn/v20210318/siconc_SImon_ACCESS-ESM1-5_ssp126_r1i1p1f1_gn_201501-210012.nc
    ##                                           dataset_pid
    ##  1: hdl:21.14100/311d0772-ce1e-3440-8745-85eb365c65e0
    ##  2: hdl:21.14100/f485bfb8-0aa6-3ba1-a413-9ffa4a2e9ef2
    ##  3: hdl:21.14100/1997ec1e-1ffb-3133-a4f5-efd9d1f53ab9
    ##  4: hdl:21.14100/feb45e04-2915-3fdd-b2dd-abffa42c5d9b
    ##  5: hdl:21.14100/21ecb154-2707-3afc-875f-8c1517d3fc85
    ##  6: hdl:21.14100/9a49b498-6997-3ad0-8f8c-8ca9c33c1a18
    ##  7: hdl:21.14100/f2c19a60-93cb-3f62-b39f-b18deba189b3
    ##  8: hdl:21.14100/09d00a5d-490a-3fde-8625-39718ec1c4f3
    ##  9: hdl:21.14100/c1440219-32ed-351a-b449-c024d9e17596
    ## 10: hdl:21.14100/84531ec4-cdbc-31f5-82ec-cfe9a7209a38
    ## 11: hdl:21.14100/16d2d8f3-001d-34e5-8e1f-9fb6b1d7ebb3
    ## 12: hdl:21.14100/b1fc862b-3373-3855-a7cb-7e5b1fbb25c1
    ##                                           tracking_id
    ##  1: hdl:21.14100/44046366-ac50-4be5-bf42-e1be7c65e37e
    ##  2: hdl:21.14100/02850fcc-be64-40de-b7ca-9b8aa6e688a0
    ##  3: hdl:21.14100/5ab2f881-d384-4b73-b358-25c33a1d8eb7
    ##  4: hdl:21.14100/ea8ff790-77c2-4a4c-bc3f-3f2048c626ba
    ##  5: hdl:21.14100/26c69272-0a1c-4d0d-8bb9-0f767c064404
    ##  6: hdl:21.14100/931b0664-d90c-46d5-b9fb-f7f17b8cefd5
    ##  7: hdl:21.14100/3245dfe2-439e-47e2-ba73-332016f091a2
    ##  8: hdl:21.14100/b2b1fd90-3b5e-4e39-8622-ca49cce52038
    ##  9: hdl:21.14100/39125f03-b0c7-4cb1-95fd-72e6b2114417
    ## 10: hdl:21.14100/8903e171-e202-4a0e-9a6f-9564c39b82a6
    ## 11: hdl:21.14100/41a18599-3d5b-4d43-92b3-ce1c28b2da2a
    ## 12: hdl:21.14100/ac2ebb2c-11d7-4bcb-91e2-32a8fd81990f
    ##                                                                                                                                                        out_name
    ##  1: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  2: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  3: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  4: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  5: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  6: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  7: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  8: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ##  9: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 10: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 11: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc
    ## 12: /tmp/RtmplIah5L/CMIP6.CMIP.CSIRO.ACCESS-ESM1-5.historical.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_historical_r1i1p1f1_gn_185001-201412.nc

## Downloading files

``` r
download.file(idx$file_url[1], idx$out_name[1])
```

## Checking contents of netcdf

``` r
GlanceNetCDF(idx$out_name[1])
```

    ## ----- Variables ----- 
    ## time_bnds:
    ##     time_bnds
    ##     Dimensions: bnds by time
    ## latitude:
    ##     latitude in degrees_north
    ##     Dimensions: i by j
    ## longitude:
    ##     longitude in degrees_east
    ##     Dimensions: i by j
    ## vertices_latitude:
    ##     vertices_latitude in degrees_north
    ##     Dimensions: vertices by i by j
    ## vertices_longitude:
    ##     vertices_longitude in degrees_east
    ##     Dimensions: vertices by i by j
    ## intpp:
    ##     Primary Organic Carbon Production by All Types of Phytoplankton in mol m-2 s-1
    ##     Dimensions: i by j by time
    ## 
    ## 
    ## ----- Dimensions ----- 
    ##   time: 1980 values from 1850-01-16 12:00:00 to 2014-12-16 12:00:00 
    ##   j: 300 values from 0 to 299 1
    ##   i: 360 values from 0 to 359 1
    ##   bnds: 2 values from 1 to 2 
    ##   vertices: 4 values from 1 to 4

## Loading dataset with `metR`

``` r
ds <- ReadNetCDF(idx$out_name[1], vars = idx$variable_id[1])

#Subsetting dataset: First and last available decades
dec0 <- ds %>% filter(lubridate::year(time) <= lubridate::year(idx$datetime_start[1])+9)
decN <- ds %>% filter(lubridate::year(time) >= lubridate::year(idx$datetime_end[1])-9)
```

## Loading dataset with `stars`

``` r
library(stars)
```

    ## Loading required package: abind

    ## Loading required package: sf

    ## Linking to GEOS 3.10.2, GDAL 3.4.3, PROJ 8.2.0; sf_use_s2() is TRUE

``` r
dss <- read_stars(idx$out_name[1])
```

    ## Warning in CPL_get_metadata(file, NA_character_, options): GDAL Message 1:
    ## dimension #2 (i) is not a Longitude/X dimension.

    ## Warning in CPL_get_metadata(file, NA_character_, options): GDAL Message 1:
    ## dimension #1 (j) is not a Latitude/Y dimension.

    ## Warning in CPL_get_metadata(file, domain_item, options): GDAL Message 1:
    ## dimension #2 (i) is not a Longitude/X dimension.

    ## Warning in CPL_get_metadata(file, domain_item, options): GDAL Message 1:
    ## dimension #1 (j) is not a Latitude/Y dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #1 (i) is not a Longitude/X
    ## dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #0 (j) is not a Latitude/Y
    ## dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #1 (i) is not a Longitude/X
    ## dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #0 (j) is not a Latitude/Y
    ## dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #2 (i) is not a Longitude/X
    ## dimension.

    ## Warning in CPL_read_gdal(as.character(x), as.character(options),
    ## as.character(driver), : GDAL Message 1: dimension #1 (j) is not a Latitude/Y
    ## dimension.

``` r
dss_dim <- st_dimensions(dss)
dss_0 <- dss[, , , seq(1, length(dss_dim$time$values))[lubridate::year(dss_dim$time$values) <= 1859]]

write_stars(dss_0, "../CMIP6_data/test.nc")
```
