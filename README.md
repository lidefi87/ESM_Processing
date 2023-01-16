# Earth System Model (ESM) Processing

This repository contains notebooks with instructions on how to access and process Coupled Model Intercomparison Project Phase 6 (CMIP6) data from the Earth System Grid Federation ([ESGF](https://esgf.nci.org.au/search/cmip6-nci/)) platform for ecological applications.
  
These notebooks use both [`R`](https://cran.r-project.org/) and [`Python`](https://www.python.org/downloads/) to query, access, manipulate and download CMIP6 data from ESGF. This repository contains all files needed to easily replicate this workflow. Note that you must have installed [RStudio](https://www.rstudio.com/products/rstudio/download/), and either [Anaconda](https://docs.anaconda.com/anaconda/install/index.html) or its smaller version, [Miniconda](https://docs.conda.io/en/latest/miniconda.html), prior to following instructions below.  
  
## Installing `Python` libraries
The `environment.yml` file contained in this repository has a list of `Python` libraries and dependencies needed to run these notebooks. If you are running these notebooks outside the `CLIOTOP` project hosted in the `ARDC Nectar Research Cloud`, you will need to follow the instructions below. However, if you are a `CLIOTOP` user, jump to the **`Python` for CLIOTOP users** section below.

### `Python` for non-CLIOTOP users
You will have to download or `clone` this repository to your local machine. To install all relevant `Python` libraries to this project, we will use the `environment.yml` file. Open a `command line` window and navigate to the folder where you downloaded or `cloned` this repository, which contains the `environment.yml` file.  
  
Once you are in the correct folder, type the following line of code: `conda env create -f environment.yml -n CMIP6_data`. The `-f` argument points to the file containing all libraries to be installed, while the `-n` contains the name to be given to the newly created environment. It should be noted that although you can give your environment any name, it is not advisable to do because all `Python` notebooks in this repository refer to the conda environment by this specific name. However, if you decide to change the name of this environment, make sure you update this name in all `Python` scripts. Look for this line of code: `use_condaenv("CMIP6_data")` and update the name of the environment **only** if you chose to use a different name.  
  
You can check if the conda environment has been successfully created by typing this line of code in your command line: `conda env list`. The output will include the name and location of your newly created environment and it should look something similar to the following:  
  
```
# conda environments:
#
base                     /file_path_to_environment/base
CMIP6_data            *  /file_path_to_environment/envs/CMIP6_data
```
    
Once you have successfully installed the conda environment, you can use the command line to activate this environment by typing the following command: `conda activate CMIP6_data` (if you used a different name, remember to change `CMIP6_data` for whatever name you gave your environment). This will activate the environment you created in the previous steps.  

Finally, you will need to get the path to the local folder where `Python` was installed. You can do this by opening the command line and typing either `which python` (for Linux or Mac) or `where python` (for Windows). You will need this path to let `R` known which version `Python` we expect it to use when running these notebooks. Go back to the folder where you downloaded this repository and look for a file named `.Rprofile`. This is a text file that you can open using any text editor, or in `RStudio`. Once you open this file, replace the folder path within the quotation marks ("") for the `RETICULATE_PYTHON` variable in line 2 with the `Python `folder path that was printed in the command line.  
  
### `Python` for CLIOTOP users
If you are a `CLIOTOP` user, you are in luck! The conda environment with all relevant libraries is already installed in this project, so there is no need to install anything at all. The `.Rprofile` file already contains the folder path where our preferred version of `Python` is installed. If you would like to use a different `Python` version, you will need to update the path in line 2. Make sure your path is written between quotation marks ("").  
  
## Installing `R` libraries
Once `Python` packages have been installed and the `.Rprofile` file has been updated, you are now ready to install all `R` libraries. To do, simply run `renv::restore()` in the `R` console. This will automatically install any libraries used in this collection of notebooks that are not yet installed in your local machine.  
  
## You are now ready to go!
That is it! You are now all set up to running all the notebooks contained in this repository.


