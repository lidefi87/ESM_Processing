# Earth System Model (ESM) Processing

This repository contains notebooks with instructions on how to access and process Coupled Model Intercomparison Project Phase 6 (CMIP6) data from the Earth System Grid Federation ([ESGF](https://esgf.nci.org.au/search/cmip6-nci/)) platform for ecological applications.
  
These notebooks use both [`R`](https://cran.r-project.org/) and [`Python`](https://www.python.org/downloads/) to query, access, manipulate and download CMIP6 data from ESGF. This repository contains all files needed to easily replicate this workflow. 

## Running these notebooks in your machine/instance
This repository contains all information needed for you to run all scripts (`R` and `Python`). The set up requirements vary depending on whether you want to run this notebooks in your own computer or in CLIOTOP. Click on the dropdown option relevant to you below for more detail instructions.  
  
### Setting up your machine/instance
<details>
<summary><b> Instructions for CLIOTOP users </b></summary>  
  
If you are a CLIOTOP user, you are in luck! You will need to copy or clone this repository in your home directory, and check the instructions under the [Checking `R` libraries](#checking-r-libraries) to ensure you have all relevant `R` packages installed in your instance.  
  
`Python` libraries are already installed and readily available for you.  
  
</details>
  
<details>
<summary><b> Instructions for non-CLIOTOP users </b></summary>  
  
All notebooks included in this repository can be run in your own computer, but you will need to ensure that all relevant software is installed before you can run them.  
  
1. **Install miniconda (includes `Python` installation)**  
Conda is a software distributor from where you can download `Python` and other programming languages, as well as hundreds of data science packages. Anaconda has two versions available: conda and miniconda, and their main difference is their size. We recommend that you install miniconda because it occupies less space in your hard drive. You can download the latest version from this [link](https://docs.conda.io/en/latest/miniconda.html). Note that you will need to select the installer that matches your operating system (e.g., Windows, Linux, MacOS).  
  
If you need any additional instructions on how to complete the installation, this [website](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html) has installation instructions for every operating system.  
  
    + Checking miniconda installation was successful
The [Anaconda documentation](https://docs.anaconda.com/free/anaconda/install/verify-install/) provides information on how to check your installation has been successful. Note that instructions vary slightly depending on your operating system.  
  
To verify the installation, we will use the *Anaconda Prompt* (a command line interface for Anaconda) on Windows and macOS, or the *Terminal* on Linux.  
  
To open Anaconda Prompt:  
- **Windows:** Click **Start**, search for *Anaconda Prompt*, and click to open.
- **macOS:** Use **Cmd+Space** to open Spotlight Search and type “*Navigator*” to open the program.
  
To open Terminal:  
- **Linux–CentOS:** Open **Applications** > **System Tools** > **terminal**.  
- **Linux–Ubuntu:** Open the Dash by clicking the Ubuntu icon, then type “terminal”.  
  
After opening Anaconda Prompt or the terminal, choose any of the following methods to verify:  
- Type `conda list` and press `Enter` or `Return`. If Anaconda is installed and working correctly, a list of installed packages and their versions will be printed in your screen.  
- Type `python` and press `Enter` or `Return`. This command calls `Python` to start. If miniconda was installed correctly, a `Python` session will beging and the version information will be displayed for `Python` and “Anaconda”. To exit the Python shell, type the command `quit()` and press `Enter` or `Return`.
- Open Anaconda Navigator by typing the command `anaconda-navigator`. If Anaconda is installed properly, Anaconda Navigator will open.
  
2. **Install `R`**   
`R` is distributed by CRAN and is available for Windows, Linux, and MacOS. Installers are available [here](https://cran.r-project.org/). Make sure you download the installer that matches the operating system in your machine.  
  
**Note:** You will need to have `R` installed before installing RStudio.  
  
    2.1. **Install RTools *(Windows users ONLY)***  
If you are running `R` in a Windows machine, you will also need to install RTools. This program will allow you to build some `R` packages. RTools installers can be downloaded from [here](https://cran.r-project.org/bin/windows/Rtools/).  
  
The version of RTools you need to install will depend on the version of `R` you have installed your computer. If you installed `R` while following these instructions, then you will need to download RTools 4.3. Otherwise, check the version of `R` you have installed in your machine to identify the correct RTools version. If you are unsure about the `R` version installed in your machine, you can simply type `version` in the RStudio console.  
  
If you are NOT using a Windows machine, then you do NOT need to install RTools.  
  
    2.2. **Install RStudio**   
Once you install `R` in your local machine, you will need to install a program that allows you to interact with `R`. This program is known as an integrated development environment (IDE). There are several IDEs that allow you to interact with `R`, but RStudio is by far the most popular. We will use RStudio in our workshop, so we recommend you install it, especially if you are not an experienced `R` user. However, if you are more comfortable using a different IDE, you do not need to install RStudio.  
  
You can download RStudio Desktop [here](https://posit.co/download/rstudio-desktop/) for free. Once again, ensure you select the installer that matches the operating system in your machine.  
    
    2.3. **Checking `R` and RStudio installations were successful**  
Open RStudio in your machine. If you cannot find RStudio, follow the instructions below.  
- **Windows:** Click **Start**, search for “*rstudio”*, and click to open.  
- **macOS:** Use **Cmd+Space** to open Spotlight Search and type “*rstudio*” to open the program.  
- **Linux–CentOS:** Open **Applications** > **System Tools** > ***rstudio***.  
- **Linux–Ubuntu:** Open the Dash by clicking the Ubuntu icon, then type “*rstudio*”.  
  
Once RStudio is opened, type `version` in the console (panel on the lower left) and press ENTER/RETURN. This should print output similar to the one shown below.

```r
> version
platform       x86_64-w64-mingw32               
arch           x86_64                           
os             mingw32                          
crt            ucrt                             
system         x86_64, mingw32                  
status                                          
major          4                                
minor          2.3                              
year           2023                             
month          03                               
day            15                               
svn rev        83980                            
language       R                                
version.string R version 4.2.3 (2023-03-15 ucrt)
nickname       Shortstop Beagle
```
  
If you were able to open RStudio and the console printed something similar to what is shown above, then you have successfully installed R and RStudio in your machine.  
  
</details>
  
### Ensuring all libraries are available in your machine/instance
After setting up your computer, you will need to make sure all libraries used in this repository are available in your machine.  
  
<details>
<summary><b> Instructions for CLIOTOP users </b></summary>  
  
### Checking `R` libraries
We have included an `R` script that automatically checks that all libraries used in these notebooks are installed in your machine. If there are any missing libraries, then the script will install them for you. This script is called `useful_functions.R` and can be found in the `Scripts` folder of our repository.  
  
To run this script, use RStudio to open this repository. You can do this by double clicking on the `ESM_Processing.Rproj` file included in the repository. This will open the repository as a project in RStudio.

Once you have open this project in RStudio. Head over to the console and type the following lines:  
  
```r
source("Scripts/useful_functions.R")
checking_libraries()
```
  
This will start the process of checking all packages are installed in your machine and install any missing packages.   
  
As noted before, `Python` libraries are already installed and readily available for you in CLIOTOP.  
  
</details>
  
<details>
<summary><b> Instructions for non-CLIOTOP users </b></summary>  
  
### Installing `R` libraries
We have included an `R` script that automatically checks that all libraries used in these notebooks are installed in your machine. If there are any missing libraries, then the script will install them for you. This script is called `useful_functions.R` and can be found in the `Scripts` folder of our repository.  
  
To run this script, use RStudio to open this repository. You can do this by double clicking on the `ESM_Processing.Rproj` file included in the repository. This will open the repository as a project in RStudio.

Once you have open this project in RStudio. Head over to the console and type the following lines:  
  
```r
source("Scripts/useful_functions.R")
checking_libraries()
```
  
This will start the process of checking all packages are installed in your machine and install any missing packages.   
  
### Installing `Python` libraries
We have included an *environment* file in this repository called `conda-lock.yml`, which will allow you to install all Python libraries needed to run this notebook with relative ease. You will need to follow these steps: 
  
1. Get the full path to the folder containing this repository. For example, if this file is located in your Documents folder, your full path should look something similar to `C:/Users/user_name/Documents`.  
2. Open a *Terminal* window if you use macOS or Linux. If you use Windows, search for *Anaconda Prompt* in the Start menu and open it.  
3. Install the `conda-lock` library by typing the following line: `conda install -c conda-forge conda-lock` and press `Enter` or `Return`.  
4. After the installation is complete, check the current location of your *Terminal* or *Anaconda Prompt*. This should be at the beginning of the line showing in your window, and it should look something like this: `C:/Users/user_name/`. If the current location of your window is different to the path from step 1, then navigate to the repository folder. You can do this with the `cd` (changing directory) command. For example: `cd C:/Users/user_name/Documents/ESM_Processing`.  
5. Once you are in the repository folder, you can install all Python libraries by typing the following command: `conda-lock install --name CMIP6_data conda-lock.yml` and press `Enter` or `Return`. Installation will start and this make take a few minutes.  
6. You can check that you have installed everything correctly by typing the following: `conda env list`. The output will include the name and location of your newly created environment and it should look something similar to the information below. Keep this window open.    
  
```
# conda environments:
#
base                  *  /file_path_to_environment/base
CMIP6_data               /file_path_to_environment/envs/CMIP6_data
```
  
7. Finally, head back to the repository folder and find the `.Rprofile` file. Open this file (you can do this in RStudio or in the Notepad app), and replace the file path in between the quotation marks (""). You will use the fill path showing next to the `CMIP6_data` environment you created in the previous step. Save this file and close all windows.    
  
</details>

## You are now ready to go!
That is it! You are now all set up to running all the notebooks contained in this repository.
