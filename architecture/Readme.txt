Here is the basic architecture on server environment. I worked on the latest version of Ubuntu. (See the details of my VM in vmversion.PNG)

1. Prerequisities:
1.1   Install anaconda
1.1.1 Download the linux version
1.1.2 Run bash ~/Downloads/Anaconda3-4.3.1-Linux-x86_64.sh

1.2 Install the R essentials in conda environment:
>conda install -c r r-essentials

1.3 Install texlive, texlive-latex-extra for pdf generation and for fancy output
>sudo apt-get install texlive
>sudo apt-get install texlive-latex-extra
(In case of error: sudo apt-get update) 

1.4 Install cowplot library from Anaconda cloud's szintakacseva repository
conda install -c szintakacseva r-cowplot   

1.5 Install tidyverse library (2018.03.09)
conda install r-tidyverse
(This command installs the new packages. Also updates the existing ones. Please type 'Y' for update.)

2. Architecture
Required Files:

2.1 analyse.ini
The main config file of the reports. The section name of the config file is the identifier of the individual reports. Under the section name are listed the parameters of the report.

2.2  createprefix.sh
Creates a session specific report parameter config file from the analyse.ini having the name {prefix}.ini - the unic identifier of the session. Prefix is coming outside from the calling system.
  
2.3. analyse.sh
This is the main batch analysis file. It's input config file is {prefix}.ini. 
Runs the runRmd.R file getting the parameters from the {prefix}.ini.

2.4. runRmd
The main R script responsible to run Rmd notebook files. It should be in the working directory.

2.5. *.Rmd notebook files do the actual analysis. They need as input the above the csv files listed in analyse.ini , which are the results of Athena sql queries without modifications. Rmd files should be in the WORKDIR/rmd.
In this version the results of the analysis are html or pdfs having the same name as Rmd files extended with 'prefix'.

Available rmd files are:
   recheckitClientSectionAnalysis.Rmd
   recheckitSessionAnalysebyClient.Rmd 
   recheckitSessionAll.Rmd 
   funnelExcel.Rmd
   recheckit_value_traffic.Rmd

2.6 csv/*.csv are the input files for the analysis. 
Required csv files are listed in analyse.ini.
In order to be able to identify individual sessions, the csv files names are extended with the 'prefix' name by the calling system.
   
2.7. utils/functions.R - contains helper functions for the notebook files (Rmds')

So the steps to do are as follows:

1. Install conda and other libraries. See the prerequisities.
2. Download 'Pacific' repository from github (https://github.com/szintakacseva/datascience_for_webshops).
3. cd /path/datascience_for_webshops/architecture 
4. ./createprefixini.sh 'section' 'prefix'
5. ./analyse.sh 'prefix'

'section' option can have the following values:
  all - all the .Rmd files are running
  client-section - ClientSessionAnalysis.Rmd is running
  traffic-value - value_traffic.Rmd is running
  funnel - funnelExcel.Rmd
  all-clients - SessionAll.Rmd
  client-session - SessionAnalysebyClient.Rmd
  
5. As a result you should find and html, pdf or file in the /path/datascience_for_webshops/architecture/rmd folder having the same name as the running *.Rmd file extended with 'prefix'. 

6. The calling system can set the running parameters in the analyse.ini. DO NOT CHANGE SECTION names.!!!!!!! 

Examples of running:
> cd WORKDIR/architecture
> ./createprefixini.sh client-section prefix
> ./analyse.sh prefix

