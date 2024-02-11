# Conda environments for reproducible science
In creating this repository, a conda environment containing all `Python` packages used in here was created. This allows for anyone in CLIOTOP to use these notebooks without having to install all `Python` libraries in their `home` folder. Further, this conda environment can be shared with anyone outside CLIOTOP (via the `conda-lock.yml` file) so they can install all `Python` packages needed to run all notebooks in their own machines.  
  
This conda environment can be updated by either upgrading to the latest version of an already installed package, or by adding/remove packages. If a conda environment is changed, then the `conda-lock.yml` will also need to be updated.  
  
Here, we will include information on how to change a conda environment and how to update the `conda-lock.yml` files.  
  
## Changing a conda environment
If you need to upgrade, add or remove a `Python` package, you will need to make use of the `Terminal` or command line and follow these instructions:  
1. Activate the conda environment by typing: `conda activate /perm_storage/home/lidefi87/miniconda3/envs/CMIP6_data`, and press Enter.  
2. Before attempting to make changes, check that package and version is not already installed in the conda environment. To get a list of all packages type: `conda list` and press Enter. This will print a list of `Python` packages available in the environment and their version.  
3. To install a new package or version, it is preferable that you use the conda-forge channel. For example, if you would like to install the latest version of `matplotlib`, you will need to type `conda install -c conda-forge matplotlib` and press Enter. The `-c conda-forge` tells conda to install `matplotlib` from the conda-forge channel. If you are not sure how to install a package, you can refer to the documentation.  
  
## Keeping a record of the new environment
If you make any changes to the conda environment, it is always a good idea to keep a record of the latest working environment. You may want to do this because of two reasons:  
1. You can share the latest conda environment with anyone wanting to run these notebooks in their own computer,  
2. It will help you recreate the environment easily in the event that installing a new package or package version breaks the environment.  
  
To keep a record of the latest working environment, we will use conda and `conda-lock`. Conda will help us recreate the environment in CLIOPTOP or Linux-based machines with ease, while `conda-lock` will help us share the environment across operating systems (Linux, Windows and MacOS). To do this, follow these steps:  
1. Activate the conda environment by typing in the command line the following: `conda activate /perm_storage/home/lidefi87/miniconda3/envs/CMIP6_data`, and press Enter.  
2. Ensure `conda-lock` is installed. Type `conda list` and press Enter, and look for `conda-lock` in the list printed in your screen (the list is in alphabetical order). If it is not listed, you need to install it by typing: `conda install -c conda-forge conda-lock` and press Enter.  
3. Use conda to export the environment by typing: `conda env export --from-history>environment.yml` and press Enter. This will create a file called `environment.yml` inside the folder where you run the line above.  
4. Finally, create the cross-platform installing file by typing: `conda-lock --file environment.yml` and press Enter. This will take several minutes while it checks for the correct package versions across all operating systems. At the end, this will produce a file named `conda-lock.yml` which can be shared with anyone regardless of the operating system they use to recreate the environment used in CLIOTOP to run these notebooks.  
  
**Note 1:** The `environment.yml` created in step 3 is the file that you would need to use to recreate the conda environment in case it breaks after attempting to install or upgrade a package. To use it, you will need to run `conda env create -n CMIP6_data --file environment.yml` and press Enter. This will take a few minutes to run.    
  
**Note 2:** Users outside CLIOTOP using any operating system can use the `conda-lock.yml` file to recreate the conda environment used in the server. Users will need to type the following line to install the conda environment: `conda-lock install --name CMIP6_data conda-lock.yml`. Detailed instructions for non-CLIOTOP users are provided in the `README.md` file of this repository.  
  
**Note 3:** Ensure both the `conda-lock.yml` and the `environment.yml` files are shared in the GitHub repository to keep a record of any changes.  
  
