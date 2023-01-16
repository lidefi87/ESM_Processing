Querying CMIP6 database
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
    -   <a href="#querying-esgf-server-searching-for-one-specific-variable"
        id="toc-querying-esgf-server-searching-for-one-specific-variable">Querying
        ESGF server: Searching for one specific variable</a>

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
used in the script use the `data_node` parameter of the `cmip6_index`
function to change the node used in the database search. Otherwise, you
can provide the URL address of the search page for the node by the
`node_url` parameter. The link points to a `xml` file and should look
like this: <https://esgf.nci.org.au/esg-search/search/?>, which is
similar to a table of contents for the datasets available within the
node.

Note that changing the data node is optional, and you either need to
provide the `data_node` or the `node_url` to change the default NCI
server node used in this notebook.

All other libraries allow us to manipulate and save CMIP6 data.

``` r
search_CMIP6 <- source("search_download_functions.R")
library(tidyverse)
library(lubridate)
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
Data Request - Variable
Search](https://clipc-services.ceda.ac.uk/dreq/mipVars.html) - [CMIP6
Global Attributes
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
  source = c("ACCESS-ESM1-5"),
  
  # Specifying variant, which refers to the model run 
  variant = "r1i1p1f1")

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
save our data. Note that you must update this path to a folder where you
would like to save the CMIP6 files of interest.

``` r
out_folder <- "/perm_storage/home/data/CMIP6_data"
```

Now we will add the columns we need to automate process into the search
results data frame.

``` r
results_query <- results_query %>%
  #Removing any datasets starting after 2100
  filter(year(datetime_start) <= 2100) %>% 
  #Checking if there are multiple files for each variable/model/experiment
  group_by(dataset_id) %>% 
  #Counting files per variable/model/experiment
  mutate(count = n(),
         #Get the start year for each variable/model/experiment
         decade_0_start = min(year(datetime_start)),
         #Calculate the end of the initial decade
         decade_0_end = decade_0_start+9L,
         #Get the end year for each variable/model/experiment
         decade_N_end = max(year(datetime_end)),
         #Calculate the beginning of the last decade
         decade_N_start = decade_N_end-9L,
         #Adding a column that will help us easily identify the files linked to first and last decades
         keep = case_when(count > 2 & year(datetime_start) <= decade_0_end | year(datetime_end) <= decade_0_end ~ T,
                          count > 2 & year(datetime_end) >= decade_N_start ~ T | year(datetime_start) >= decade_N_start,
                          count <= 2 ~ T,
                          T ~ F),
         #Adding a column to easily identify decades
         decade = case_when(count > 2 & year(datetime_start) <= decade_0_end ~ "dec0",
                          count > 2 & year(datetime_end) >= decade_N_start ~ "decN",
                          count <= 2 ~ "both"),
         #Defining the name of the model outputs that we will save locally
         base_file_name = str_remove(dataset_id, pattern = "\\|.*"),
         out_file_name = case_when(decade == "dec0" ~ paste0(base_file_name, ".", decade_0_start, "-", 
                                                             decade_0_end, ".nc"),
                                   decade == "decN" ~  paste0(base_file_name, ".", decade_N_start, "-", 
                                          decade_N_end, ".nc"),
                                   T~ paste0(base_file_name, ".", decade_0_start, "-", 
                                          decade_0_end, "_", decade_N_start, "-", 
                                          decade_N_end, ".nc")),
         #Defining the correct file path for local copies
         out_full_folder = file.path(out_folder, source_id, experiment_id),
         #Defining full file path for subset data
         out_path = file.path(out_full_folder, out_file_name))

head(results_query, n = 3)
```

    ## # A tibble: 3 × 34
    ## # Groups:   dataset_id [3]
    ##   file_id        datas…¹ mip_era activ…² insti…³ sourc…⁴ exper…⁵ membe…⁶ table…⁷
    ##   <chr>          <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
    ## 1 CMIP6.CMIP.CS… CMIP6.… CMIP6   CMIP    CSIRO   ACCESS… histor… r1i1p1… Omon   
    ## 2 CMIP6.CMIP.CS… CMIP6.… CMIP6   CMIP    CSIRO   ACCESS… histor… r1i1p1… Omon   
    ## 3 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… CSIRO   ACCESS… ssp245  r1i1p1… Omon   
    ## # … with 25 more variables: frequency <chr>, grid_label <chr>, version <chr>,
    ## #   nominal_resolution <chr>, variable_id <chr>, variable_long_name <chr>,
    ## #   variable_units <chr>, datetime_start <dttm>, datetime_end <dttm>,
    ## #   file_size <int>, data_node <chr>, file_url <chr>, dataset_pid <chr>,
    ## #   tracking_id <chr>, count <int>, decade_0_start <dbl>, decade_0_end <dbl>,
    ## #   decade_N_end <dbl>, decade_N_start <dbl>, keep <lgl>, decade <chr>,
    ## #   base_file_name <chr>, out_file_name <chr>, out_full_folder <chr>, …

Now that we are happy with our results, we will save them to disk for
future reference.

``` r
write_csv(results_query, "../Outputs/results_query.csv")
```

## Querying ESGF server: Searching for one specific variable

We can also carry out a search using a variable name only as shown in
the example below. We are using `intpp` which refers to primary
productivity.

``` r
# Standardised name for variables of interest - See CMIP6 Data Request for more information
results_query_intpp <- cmip6_index(variable = "intpp",
  
  # We are interested in monthly data only
  frequency = "mon",
  
  # We will only consider scenario SSP245
  experiment = "ssp245",
  
  # Specifying variant, which refers to the model run 
  variant = "r1i1p1f1")

head(results_query_intpp, n = 3)
```

    ##                                                                                                                                                       file_id
    ## 1: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115.intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc|esgf.nci.org.au
    ## 2:    CMIP6.ScenarioMIP.DKRZ.MPI-ESM1-2-HR.ssp245.r1i1p1f1.Omon.intpp.gn.v20190710.intpp_Omon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_201501-201912.nc|esgf3.dkrz.de
    ## 3:    CMIP6.ScenarioMIP.DKRZ.MPI-ESM1-2-HR.ssp245.r1i1p1f1.Omon.intpp.gn.v20190710.intpp_Omon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_202001-202412.nc|esgf3.dkrz.de
    ##                                                                                       dataset_id
    ## 1: CMIP6.ScenarioMIP.CSIRO.ACCESS-ESM1-5.ssp245.r1i1p1f1.Omon.intpp.gn.v20191115|esgf.nci.org.au
    ## 2:    CMIP6.ScenarioMIP.DKRZ.MPI-ESM1-2-HR.ssp245.r1i1p1f1.Omon.intpp.gn.v20190710|esgf3.dkrz.de
    ## 3:    CMIP6.ScenarioMIP.DKRZ.MPI-ESM1-2-HR.ssp245.r1i1p1f1.Omon.intpp.gn.v20190710|esgf3.dkrz.de
    ##    mip_era activity_drs institution_id     source_id experiment_id member_id
    ## 1:   CMIP6  ScenarioMIP          CSIRO ACCESS-ESM1-5        ssp245  r1i1p1f1
    ## 2:   CMIP6  ScenarioMIP           DKRZ MPI-ESM1-2-HR        ssp245  r1i1p1f1
    ## 3:   CMIP6  ScenarioMIP           DKRZ MPI-ESM1-2-HR        ssp245  r1i1p1f1
    ##    table_id frequency grid_label  version nominal_resolution variable_id
    ## 1:     Omon       mon         gn 20191115             250 km       intpp
    ## 2:     Omon       mon         gn 20190710              50 km       intpp
    ## 3:     Omon       mon         gn 20190710              50 km       intpp
    ##                                                 variable_long_name
    ## 1: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 2: Primary Organic Carbon Production by All Types of Phytoplankton
    ## 3: Primary Organic Carbon Production by All Types of Phytoplankton
    ##    variable_units datetime_start datetime_end file_size       data_node
    ## 1:    mol m-2 s-1     2015-01-01   2100-12-01 261237227 esgf.nci.org.au
    ## 2:    mol m-2 s-1     2015-01-01   2019-12-01  49398399   esgf3.dkrz.de
    ## 3:    mol m-2 s-1     2020-01-01   2024-12-01  49376079   esgf3.dkrz.de
    ##                                                                                                                                                                                       file_url
    ## 1: http://esgf.nci.org.au/thredds/fileServer/master/CMIP6/ScenarioMIP/CSIRO/ACCESS-ESM1-5/ssp245/r1i1p1f1/Omon/intpp/gn/v20191115/intpp_Omon_ACCESS-ESM1-5_ssp245_r1i1p1f1_gn_201501-210012.nc
    ## 2:           http://esgf3.dkrz.de/thredds/fileServer/cmip6/ScenarioMIP/DKRZ/MPI-ESM1-2-HR/ssp245/r1i1p1f1/Omon/intpp/gn/v20190710/intpp_Omon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_201501-201912.nc
    ## 3:           http://esgf3.dkrz.de/thredds/fileServer/cmip6/ScenarioMIP/DKRZ/MPI-ESM1-2-HR/ssp245/r1i1p1f1/Omon/intpp/gn/v20190710/intpp_Omon_MPI-ESM1-2-HR_ssp245_r1i1p1f1_gn_202001-202412.nc
    ##                                          dataset_pid
    ## 1: hdl:21.14100/1997ec1e-1ffb-3133-a4f5-efd9d1f53ab9
    ## 2: hdl:21.14100/2f80bd9c-22bc-36f7-9045-09c80b4564dc
    ## 3: hdl:21.14100/2f80bd9c-22bc-36f7-9045-09c80b4564dc
    ##                                          tracking_id
    ## 1: hdl:21.14100/5ab2f881-d384-4b73-b358-25c33a1d8eb7
    ## 2: hdl:21.14100/52ed0674-02f9-4410-a35d-a628ebe7198b
    ## 3: hdl:21.14100/7f2538ce-966f-400e-9042-c9a51a87fb4e

We can further refine search results using the `filter` function from
the `dplyr` package, which is part of the `tidyverse`. We will remove
any datasets going beyond 2100 and those results that do not have their
native grid (labelled `gn` under the `grid_label` column). Finally, we
will check if a single model has multiple files available for `intpp`,
and we will keep only the rows containing the years we are interested
in.

``` r
results_query_intpp <- results_query_intpp %>%
  #Removing any datasets ending after 2100
  filter(year(datetime_end) <= 2100) %>% 
  #Checking if one model has multiple files - Select only files for the first and last decade
  group_by(dataset_id) %>% 
  mutate(count = n(),
         #Defining the first and last decade of each experiment
         decade_0_start = min(year(datetime_start)),
         #Calculate the end of the initial decade
         decade_0_end = decade_0_start+9L,
         #Get the end year for each variable/model/experiment
         decade_N_end = max(year(datetime_end)),
         #Calculate the beginning of the last decade
         decade_N_start = decade_N_end-9L,
         keep = case_when(count > 2 & year(datetime_start) <= decade_0_end | year(datetime_end) <= decade_0_end ~ T,
                          count > 2 & year(datetime_end) >= decade_N_start ~ T | year(datetime_start) >= decade_N_start,
                          count <= 2 ~ T,
                          T ~ F),
         #Adding a column to easily identify decades
         decade = case_when(count > 2 & year(datetime_start) <= decade_0_end ~ "dec0",
                          count > 2 & year(datetime_end) >= decade_N_start ~ "decN",
                          count <= 2 ~ "both")) %>% 
  #Grouping removed - No longer needed
  ungroup() %>% 
  filter(keep == T) %>%
  #Defining the name of the model outputs that we will save locally
  mutate(base_file_name = str_remove(dataset_id, pattern = "\\|.*"),
         out_file_name = case_when(decade == "dec0" ~ paste0(base_file_name, ".", decade_0_start, "-", 
                                                             decade_0_end, ".nc"),
                                   decade == "decN" ~  paste0(base_file_name, ".", decade_N_start, "-", 
                                          decade_N_end, ".nc"),
                                   T~ paste0(base_file_name, ".", decade_0_start, "-", 
                                          decade_0_end, "_", decade_N_start, "-", 
                                          decade_N_end, ".nc")),
         #Defining the correct file path for local copies
         out_full_folder = file.path(out_folder, source_id, experiment_id),
         #Defining full file path for subset data
         out_path = file.path(out_full_folder, out_file_name))

#We will only show the first three results of our search.
head(results_query_intpp, n = 3)
```

    ## # A tibble: 3 × 34
    ##   file_id        datas…¹ mip_era activ…² insti…³ sourc…⁴ exper…⁵ membe…⁶ table…⁷
    ##   <chr>          <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
    ## 1 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… CSIRO   ACCESS… ssp245  r1i1p1… Omon   
    ## 2 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… DKRZ    MPI-ES… ssp245  r1i1p1… Omon   
    ## 3 CMIP6.Scenari… CMIP6.… CMIP6   Scenar… DKRZ    MPI-ES… ssp245  r1i1p1… Omon   
    ## # … with 25 more variables: frequency <chr>, grid_label <chr>, version <chr>,
    ## #   nominal_resolution <chr>, variable_id <chr>, variable_long_name <chr>,
    ## #   variable_units <chr>, datetime_start <dttm>, datetime_end <dttm>,
    ## #   file_size <int>, data_node <chr>, file_url <chr>, dataset_pid <chr>,
    ## #   tracking_id <chr>, count <int>, decade_0_start <dbl>, decade_0_end <dbl>,
    ## #   decade_N_end <dbl>, decade_N_start <dbl>, keep <lgl>, decade <chr>,
    ## #   base_file_name <chr>, out_file_name <chr>, out_full_folder <chr>, …

We will save these results to disk for future reference.

``` r
write_csv(results_query_intpp, "../Outputs/results_query_intpp.csv")
```

We can also merge both data frames into one before saving the results
locally.

``` r
results_query %>% 
  bind_rows(results_query_intpp) %>% 
  #Ensure any duplicate rows are removed before saving results
  distinct() %>% 
  write_csv("../Outputs/results_merged.csv")
```

We have successfully searched the CMIP6 datasets available through ESGF
and narrowed down our results using functions available in the
`tidyverse` package.

In [step 2](02_Downloading_CMIP6_data.md), we will download datasets
using `Python` libraries.
