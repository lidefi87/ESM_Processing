Calculating monthly means using CMIP6 ESM data
================
Denisse Fierro Arcos
2022-10-24

-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#loading-search-results-from-previous-step"
        id="toc-loading-search-results-from-previous-step">Loading search
        results from <span>previous step</span></a>
    -   <a href="#calculating-monthly-means-per-decade"
        id="toc-calculating-monthly-means-per-decade">Calculating monthly means
        per decade</a>

# Introduction

In this notebook, we will use the `ncdf4` library in `R` to calculate
monthly means using the CMIP6 data downloaded in the previous step:
[01_Accessing_CMIP6_data](01_Accessing_CMIP6_data.md). We will then save
the results as a netcdf files locally.

``` r
library(tidyverse)
library(lubridate)
library(ncdf4)
```

## Loading search results from [previous step](01_Accessing_CMIP6_data.md)

In the first notebook, we added a new column that points to the location
where the CMIP6 data we are interested in where saved. We will load them
to our environment before we calculate the monthly means for each
variable.

Recall from the previous step, some models had multiple files available
for the `intpp` variable. We will remove any duplicate entries as we
saved a single file with the initial and last decade per model.

``` r
#Loading ACCESS-ESM 1.5 query
results_query <- read_csv("../Outputs/results_query.csv", show_col_types = F) %>% 
  #Loading intpp variable query
  bind_rows(read_csv("../Outputs/results_query_intpp.csv", show_col_types = F)) %>% 
  #Removing duplicate entries
  distinct(dataset_id, .keep_all = T)
```

## Calculating monthly means per decade

There are several `R` packages that could be used to calculate monthly
means from `netcdf` files with ease, but most do not offer the option of
saving the results as `netcdf` files.

Here we use the `ncdf4` package to achieve this. The resulting workflow
is rather complicated, so if you prefer a more streamlined option, refer
to the [`Python` version](02b_Calculating_monthly_means_in_Python.Rmd)
of this notebook.

``` r
# We will loop through the results data frame
for(i in 1:nrow(results_query)){
  #Loading raster
  r <- nc_open(results_query$out_path[i])
  #Accessing variable of interest
  var <- ncvar_get(r, results_query$variable_id[i])
  #Accessing coordinates - notice these are 2D arrays
  lon <- ncvar_get(r, "lon")
  lat <- ncvar_get(r, "lat")
  #Creating 1D index for coordinates for easy plotting
  #longitude coordinates formatted -180 to +180
  x <- ifelse(lon[,1,1] > 180, lon[,1,1]-360, lon[,1,1])
  y <- lat[1,,1]
  #Accessing time dimension
  time <- ncvar_get(r, "time")
  #Reordering variables along x axis for easy plotting
  var <- var[order(x),,]
  lon <- lon[order(x),,]
  x <- x[order(x)]

  #Getting years where decade 0 and decade N start from
  dec0 <- results_query$decade_0_start[i]
  decN <- results_query$decade_N_start[i]

  #Converting time from integers to dates
  #Extracting date time origin
  origin <- str_extract(ncatt_get(r, "time", "units")$value, "\\d{4}-\\d{2}-\\d{2}")
  #Saving converted dates into tibble
  ds_dates <- time %>%
    as_tibble() %>%
    #Adding column ID for easy reference
    rowid_to_column("id") %>%
    #Adding month, year and decade
    mutate(time = as_date(value, origin = origin),
           year = year(time),
           month = month(time),
           #First decade classified as 1, final decade identified as 2
           dec = case_when(year <= results_query$decade_0_end[i] ~ 1,
                           T ~ 2)) %>%
    #Removing original time values
    select(-value)

  #Calculating monthly means per decade
  for(d in unique(ds_dates$dec)){
    month_mean <- list()
    for(m in 1:12){
      #Slicing dataset per month/decade
      #Identifying indices
      ind <- ds_dates %>%
        filter(dec == d & month == m) %>%
        select(id) %>%
        pull()
      #Calculating monthly means and reordering for easy plotting
      month_mean[[m]] <- apply(var[,,ind], 1:2, mean, na.rm = T)
    }
    #Creating a single file per decade
    dec_month_mean <- array(unlist(month_mean), dim = c(length(x), length(y), 12))

    #Creating netcdf
    #Adding lat and lon coordinates as indexes
    xdim <- ncdim_def("x", "degrees_east", x)
    ydim <- ncdim_def("y", "degrees_north", y)
    #Adding time dimension
    timedim <- ncdim_def("month", "month of the year", 1:12)
    #Adding monthly mean
    clim_ds <- ncvar_def("monthly_mean", ncatt_get(r, results_query$variable_id[i])$units,
                         list(xdim, ydim, timedim),
                         ncatt_get(r, results_query$variable_id[i])$missing_value,
                         paste0("Monthly mean ",
                                ncatt_get(r, results_query$variable_id[i])$long_name))
    #Adding lat and lon as separate dimension
    lon_ds <- ncvar_def("lon", ncatt_get(r, "lon")$units,
                         list(xdim, ydim, timedim), ncatt_get(r, "lon")$missing_value,
                         ncatt_get(r, "lon")$long_name)
    lat_ds <- ncvar_def("lat", ncatt_get(r, "lat")$units,
                         list(xdim, ydim, timedim), ncatt_get(r, "lat")$missing_value,
                         ncatt_get(r, "lat")$long_name)
    #Copying global attributes from original file
    global_atts <- ncatt_get(r, 0)

    #Naming monthly mean files per decade
    if(d == 1){
      dec_start <- dec0
    }else{dec_start <- decN}
    #Creating file name
    file_name <- paste0(results_query$base_file_name[i], ".MonthlyMean.",
                        dec_start, "-", (dec_start+9), ".nc")
    #Creating full path
    file_out <- file.path(results_query$out_full_folder[i], file_name)

    #Putting everything together in one file
    ncout <- nc_create(file_out, list(clim_ds, lon_ds, lat_ds), force_v4 = T)
    ncvar_put(ncout, clim_ds, dec_month_mean)
    ncvar_put(ncout, lon_ds, lon[,,1:12])
    ncvar_put(ncout, lat_ds, lat[,,1:12])
    for(j in 1:length(global_atts)){
      ncatt_put(ncout, 0, names(global_atts)[j], global_atts[[j]])
    }

    #Closing the file so it is saved on disk
    nc_close(ncout)
  }
  nc_close(r)
}
```
