# Earth System Model (ESM) Processing

This repository contains notebooks with instructions on how to access and process Coupled Model Intercomparison Project Phase 6 (CMIP6) data from the Earth System Grid Federation ([ESGF](https://esgf.nci.org.au/search/cmip6-nci/)) platform for ecological applications.
  
These notebooks use both [`R`](https://cran.r-project.org/) and [`Python`](https://www.python.org/downloads/) to query, access, manipulate and download CMIP6 data from ESGF. This repository contains all files needed to easily replicate this workflow. Note that you must have [RStudio](https://www.rstudio.com/products/rstudio/download/) and [Anaconda](https://docs.anaconda.com/anaconda/install/index.html) installed prior to running these scripts.  
  
## Installing `Python` libraries
To install all `Python` libraries used in this repository, use the `environment.yml` file. You can do this from the command line, make sure you navigate to the folder containing the `environment.yml` file, and then type the following line of code: `conda create -f environment.yml -n CMIP6_data`. The `-f` argument points to the file containing all libraries to be installed, while the `-n` contains the name to be given to the newly created environment. You can change the name of this environment if you prefer, but make sure this name is updated in all scripts when calling Python. Look for this line of code: `use_condaenv("CMIP6_data")` and update the name of the environment if you chose to use a different name.  
  
You can check if the conda environment has been successfully created by typing this line of code in your command line: `conda env list`. The output will include the name and location of your newly created environment and it should look something similar to the following:  
  
```
# conda environments:
#
base                     /file_path_to_environment/base
CMIP6_data            *  /file_path_to_environment/envs/CMIP6_data
```
  
Once we have successfully install the environment following the steps above, we will use the command line once again and type the following commands:  
- `conda activate CMIP6_data` (if you used a different name, remember to change `CMIP6_data` for whatever you named your environment). This will activate the environment you created in the previous steps.  
- `which python` (for Linux or Mac) or `where python` (for Windows) to locate where `Python` has been installed.  
  
Open the file named `.Rprofile`, replace the folder path for the `RETICULATE_PYTHON` variable in line 2 with the `Python `folder path that was printed in the command line.
  
## Installing `R` libraries
Once `Python` packages have been installed and the `.Rprofile` file has been updated, you are now ready to install all `R` libraries. To do, simply run `renv::restore()` in the `R` console. This will automatically install any libraries used in this collection of notebooks that are not yet installed in your local machine.  
  
## You are now ready to go!
That is it! You are now all set up to running all the notebooks contained in this repository.

