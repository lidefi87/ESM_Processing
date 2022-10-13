#This script contains functions to search and download Coupled Model
#Intercomparison Project Phase 6 (CMIP6) data from the Earth System Grid 
#Federation (ESGF) platform (https://esgf.nci.org.au/search/cmip6-nci/).
#
#The functions included in this script were slightly modified from 
#the epwshiftr package (https://github.com/ideas-lab-nus/epwshiftr)


# Loading relevant libraries ----------------------------------------------
library(checkmate)
library(data.table)

# Function extract_query_dataset ------------------------------------------
#Extract information about dataset of interest
eqd <- function(q){
  dt <- rbindlist(lapply(q$response$docs, function(l) {
    l <- l[c("id", "mip_era", "activity_drs", "institution_id", 
             "source_id", "experiment_id", "member_id", "table_id", 
             "frequency", "grid_label", "version", "nominal_resolution", 
             "variable_id", "variable_long_name", "variable_units", 
             "data_node", "pid")]
    lapply(l, unlist)
  }))
  setnames(dt, c("id", "pid"), c("dataset_id", "dataset_pid"))
}


# Function parse_file_date ------------------------------------------------
#Ensures date is correctly formatted to get filenames
pfdate <- function(id, frequency){
  dig <- fifelse(grepl("hr", frequency, fixed = TRUE), 12L, 
                 fifelse(frequency == "day", 8L, 
                         fifelse(frequency == "dec", 4L, 
                                 fifelse(grepl("mon", frequency, fixed = TRUE), 6L, 
                                         fifelse(grepl("yr", frequency, fixed = TRUE), 4L, 0L)))))
  reg <- sprintf("([0-9]{%i})-([0-9]{%i})", dig, dig)
  reg[dig == 0L] <- NA_character_
  suf <- fifelse(dig == 0L, "", 
                 fifelse(dig == 4L, "0101", 
                         fifelse(dig == 6L, "01", "")))
  fmt <- fifelse(dig == 0L, NA_character_, 
                 fifelse(dig == 4L, "%Y%m%d", 
                         fifelse(dig == 6L, "%Y%m%d", 
                                 fifelse(dig == 8L, "%Y%m%d", 
                                         fifelse(dig == 12L, "%Y%m%d%H%M%s", NA_character_)))))
  data.table(id, reg, suf, fmt)[!J(NA_character_), on = "reg", 
                                by = "reg", `:=`(c("datetime_start", "datetime_end"), 
                                                 {
                                                   m <- regexpr(.BY$reg, id)
                                                   s <- tstrsplit(regmatches(id, m), "-", fixed = TRUE)
                                                   lapply(s, function(x) as.POSIXct(paste0(x, suf), 
                                                                                    format = fmt[1L], 
                                                                                    tz = "UTC"))
                                                 })][, .SD, .SDcols = c("datetime_start", "datetime_end")]
}


# Function extract_query_file ---------------------------------------------
#Getting the file URL
eqf <- function(q){
  id <- NULL
  dt_file <- rbindlist(lapply(q$response$docs, 
                              function(l){l <- l[c("id", "dataset_id", "mip_era", "activity_drs", 
                                                   "institution_id", "source_id", "experiment_id", 
                                                   "member_id", "table_id", "frequency", "grid_label", 
                                                   "version", "nominal_resolution", "variable_id", 
                                                   "variable_long_name", "variable_units", "data_node", 
                                                   "size", "url", "tracking_id")]
                                          l$url <- grep("HTTPServer", unlist(l$url), fixed = TRUE, 
                                                        value = TRUE)
                                          if (!length(l$url)){
                                            warning("Dataset with id '", l$id,
                                                    "' does not have a HTTPServer download method.")
                                              l$url <- NA_character_}
                                          lapply(l, unlist)
                                          }))
  dt_file[, `:=`(c("datetime_start", "datetime_end"), pfdate(id, frequency))]
  dt_file[, `:=`(url, gsub("\\|.+$", "", url))]
  setnames(dt_file, c("id", "size", "url"), c("file_id", "file_size", "file_url"))
  setcolorder(dt_file, c("file_id", "dataset_id", "mip_era", "activity_drs", "institution_id", 
                         "source_id", "experiment_id", "member_id", "table_id", "frequency", 
                         "grid_label", "version", "nominal_resolution", "variable_id", 
                         "variable_long_name", "variable_units", "datetime_start", 
                         "datetime_end", "file_size", "data_node", "file_url", "tracking_id"))
  dt_file
}


# Function verbose --------------------------------------------------------
verb <- function(..., sep = ""){
  if(getOption("epwshiftr.verbose", FALSE)){
    cat(..., "\n", sep = sep)}
}


# Function esgf_query -----------------------------------------------------
e_query <- function(activity = "ScenarioMIP",
                    variable = c("tos", "siconc", "intpp"), 
                    frequency = "mon", node_url = NULL,
                    experiment = c("ssp126", "ssp245", "ssp585"), 
                    source = c("CESM2", "CESM2-WACCM", "GFDL-CM4", "GFDL-ESM4", "IPSL-CM6A-LR", "
                               MPI-ESM1-2-HR", "NorESM2-LM", "NorESM2-MM", "ACCESS-ESM1-5"), 
                    variant = "r1i1p1f1", replica = FALSE, latest = TRUE, 
                    type = "Dataset", limit = 10000L, data_node = NULL){
  assert_subset(activity, empty.ok = FALSE, 
                choices = c("AerChemMIP", "C4MIP", "CDRMIP", "CFMIP", "CMIP", "CORDEX", "DAMIP", 
                            "DCPP", "DynVarMIP", "FAFMIP", "GMMIP", "GeoMIP", "HighResMIP", 
                            "ISMIP6", "LS3MIP", "LUMIP", "OMIP", "PAMIP", "PMIP", 
                            "RFMIP", "SIMIP", "ScenarioMIP", "VIACSAB", "VolMIP"))
  assert_character(variable, any.missing = FALSE, null.ok = TRUE)
  assert_subset(frequency, empty.ok = TRUE, 
                choices = c("1hr", "1hrCM", "1hrPt", "3hr", "3hrPt", "6hr", "6hrPt", "day", 
                            "dec", "fx", "mon", "monC", "monPt", "subhrPt", "yr", "yrPt"))
  assert_character(experiment, any.missing = FALSE, null.ok = TRUE)
  assert_character(source, any.missing = FALSE, null.ok = TRUE)
  assert_character(variant, any.missing = FALSE, pattern = "r\\d+i\\d+p\\d+f\\d+", null.ok = TRUE)
  assert_flag(replica)
  assert_flag(latest)
  assert_count(limit, positive = TRUE)
  assert_choice(type, choices = c("Dataset", "File"))
  assert_character(data_node, any.missing = FALSE, null.ok = TRUE)
  if(is.null(node_url)){
    url_base <- "https://esgf.nci.org.au/esg-search/search/?"
    }else{url_base <- node_url}
  dict <- c(activity = "activity_id", experiment = "experiment_id", source = "source_id", 
            variable = "variable_id", resolution = "nominal_resolution", variant = "variant_label")
  pair <- function(x, first = FALSE){
    var <- deparse(substitute(x))
    if (is.null(x) || length(x) == 0) 
      return()
    key <- dict[names(dict) == var]
    if (!length(key)) 
      key <- var
    if (is.logical(x)) 
      x <- tolower(x)
    s <- paste0(key, "=", paste0(x, collapse = "%2C"))
    if (first) 
      s
    else paste0("&", s)
  }
  `%and%` <- function(lhs, rhs) if (is.null(rhs)) 
    lhs
  else paste0(lhs, rhs)
  
  project <- "CMIP6"
  format <- "application%2Fsolr%2Bjson"
  q <- url_base %and% pair(project, TRUE) %and% pair(activity) %and% 
    pair(experiment) %and% pair(source) %and% pair(variable) %and% 
    pair(variant) %and% pair(data_node) %and% pair(frequency) %and% 
    pair(replica) %and% pair(latest) %and% pair(type) %and% 
    pair(limit) %and% pair(format)
  q <- tryCatch(jsonlite::read_json(q), warning = function(w) w, 
                error = function(e) e)
  if (inherits(q, "warning") || inherits(q, "error")) {
    message("No matched data. Please check network connection and the availability of LLNL ESGF node.")
    dt <- data.table()
  }
  else if (q$response$numFound == 0L) {
    message("No matched data. Please examine the actual response using 'attr(x, \"response\")'.")
    dt <- data.table()
  }
  else if (type == "Dataset") {
    dt <- eqd(q)
  }
  else if (type == "File") {
    dt <- eqf(q)
  }
  setattr(dt, "response", q)
  dt
}


# Function .data_dir ------------------------------------------------------
#Get the package data storage directory
ddir <- function(init = FALSE, force = TRUE){
  d <- getOption("epwshiftr.dir", NULL)
  if(is.null(d)){
    if(.Platform$OS.type == "windows"){
      d <- normalizePath(rappdirs::user_data_dir(appauthor = "epwshiftr"), 
                         mustWork = FALSE)
    }else{
      d <- normalizePath(rappdirs::user_data_dir(appname = "epwshiftr"), 
                         mustWork = FALSE)
    }
    if(init && !dir.exists(d)){
      verb(sprintf("Creating %s package data storage directory '%s'", 
                      "epwshiftr", d))
      dir.create(d, recursive = TRUE)}
  }else{
    d <- normalizePath(d, mustWork = FALSE)
    init <- FALSE
    force <- TRUE
  }
  if ((init || force) && !test_directory_exists(d, "rw")) {
    stop(sprintf("%s package data storage directory '%s' does not exists or is not writable.", 
                 "epwshiftr", d))
  }
  d
}


# Function init_cmip6_index -----------------------------------------------
cmip6_index <- function(activity = "ScenarioMIP",
                        variable = c("tos", "siconc", "intpp"), 
                        frequency = "mon", node_url = NULL,
                        experiment = c("ssp126", "ssp245", "ssp585"), 
                        source = c("CESM2", "CESM2-WACCM", "GFDL-CM4", "GFDL-ESM4", "IPSL-CM6A-LR", 
                                   "MPI-ESM1-2-HR", "NorESM2-LM", "NorESM2-MM", "ACCESS-ESM1-5"), 
                        variant = "r1i1p1f1", replica = FALSE, latest = TRUE, 
                        limit = 10000L, data_node = NULL, years = NULL, save = FALSE){
  assert_integerish(years, lower = 1900, unique = TRUE, sorted = TRUE, any.missing = FALSE, 
                    null.ok = TRUE)
  assert_flag(save)
  verb("Querying CMIP6 Dataset Information")
  qd <- e_query(activity = activity, variable = variable, frequency = frequency, node_url = NULL,
                experiment = experiment, source = source, replica = replica, 
                latest = latest, variant = variant, limit = limit, type = "Dataset", 
                data_node = data_node)
  if (!nrow(qd)) 
    return(qd)
  if (nrow(qd) == 10000L) {
    warning("The dataset query returns 10,000 results which ", 
            "hits the maximum record limitation of a single query using ESGF search RESTful API. ", 
            "It is possible that the returned Dataset query responses are not complete. ", 
            "It is suggested to examine and refine your query.")
  }
  dt <- set(qd, NULL, "file_url", NA_character_)
  file_url <- NULL
  attempt <- 0L
  retry <- 10L
  while (nrow(nf <- dt[is.na(file_url)]) && attempt <= retry) {
    attempt <- attempt + 1L
    verb("Querying CMIP6 File Information [Attempt ", 
            attempt, "]")
    .SD <- NULL
    q <- unique(nf[, .SD, .SDcols = c("activity_drs", "source_id", 
                                      "member_id", "experiment_id", "nominal_resolution", 
                                      "table_id", "frequency", "variable_id")])
    qf <- e_query(activity = unique(q$activity_drs), variable = unique(q$variable_id), 
                  frequency = unique(q$frequency), node_url = NULL,
                  experiment = unique(q$experiment_id), source = unique(q$source_id), 
                  variant = unique(q$member_id), replica = replica, latest = latest, 
                  type = "File", data_node = data_node)
    set(qf, NULL, value = NULL, setdiff(intersect(names(qd), names(qf)), c("dataset_id", "file_url")))
    set(nf, NULL, value = NULL, setdiff(intersect(names(qf), names(nf)), c("dataset_id")))
    dt <- rbindlist(list(dt[!nf, on = "dataset_id"], qf[nf, on = "dataset_id"]), fill = TRUE)
  }
  verb("Checking if data is complete")
  if (anyNA(dt$file_url)) {
    warning("There are still ", length(unique(dt$dataset_id[is.na(dt$file_url)])), 
            " Dataset that ", "did not find any matched output file after ", 
            retry, " retries.")
  }
  setcolorder(dt, c("file_id", "dataset_id", "mip_era", "activity_drs", "institution_id", 
                    "source_id", "experiment_id", "member_id", "table_id", "frequency", 
                    "grid_label", "version", "nominal_resolution", "variable_id", 
                    "variable_long_name", "variable_units", "datetime_start", "datetime_end", 
                    "file_size", "data_node", "file_url", "dataset_pid", "tracking_id"))
  if (!is.null(years)) {
    exp <- data.table(expect_start = ISOdatetime(years - 1L, 1, 1, 0, 0, 0, "UTC"), 
                      expect_end = ISOdatetime(years + 1L, 12, 31, 0, 0, 0, "UTC"))
    dt[, `:=`(expect_start = datetime_start, expect_end = datetime_end)]
    dt <- dt[exp, on = c("expect_start<=expect_end", 
                         "expect_end>=expect_start")][, `:=`(expect_start = NULL, 
                                                             expect_end = NULL)]
  }
  dt <- unique(dt, by = "file_id")
  if(save){fwrite(dt, file.path(ddir(TRUE), "cmip6_index.csv"))
    verb("Data file index saved to '", 
         normalizePath(file.path(ddir(TRUE), "cmip6_index.csv")), "'")
  }
  dt
}



