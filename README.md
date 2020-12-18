# paper-yadkin-swat-svi-study
Data repository for paper titled: "Applying Climate Change Risk Management Tools to Combine Streamflow Projections and Social Vulnerability".

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2635878.svg)](https://doi.org/10.5281/zenodo.2635878)

This README.md file was generated on 20190410 by Sheila Saia.

This GitHub repository was created to provide access to collected data, analysis code, and other information associated with the paper by Saia et al. titled "Applying Climate Change Risk Management Tools to Combine Streamflow Projections and Social Vulnerability" in *Ecosystems* (Ecosystems link: https://link.springer.com/article/10.1007/s10021-019-00387-5, TreeSearch link: https://www.fs.usda.gov/treesearch/pubs/56780).

## General Information ##

**Title of Dataset**<br>
"paper-yadkin-swat-svi-study"

**Dataset & Repo Contact Information**<br>
Name: Sheila Saia<br>
Institution: United States Department of Agriculture Forest Service, Southern Research Station<br>
Address: 3041 Cornwallis Road, Durham, NC 27709<br>
Email: ssaia at ncsu dot edu

**Date of data collection**<br>
Soil and Water Assessment Tool (SWAT) model outputs were generated in 2016 and are available at on GitHub at https://github.com/sheilasaia/paper-yadkin-swat-study. United States Forest Service (USFS) land use predictions were generated in 2015 and are also available at the previously mentioned GitHub link. Social vulnerability index (SVI) results (2010-2014) were downloaded from the [Centers for Disease Control Agency for Toxic Substance and Disease Registry (ATSDR) data download website](https://svi.cdc.gov/data-and-tools-download.html) in 2018. All other data originated from publically available sites as described in the paper associated with this dataset.

**Geographic location of data collection**<br>
All data is associated with the Yadkin-Pee Dee River Watershed (YPD) in North Carolina, USA.

**Information about funding sources that supported the collection of the data**<br>
Sheila Saia was supported by funding through the Oak Ridge Institute for Science and Education (ORISE).

## Sharing & Access Information ##

**Licenses/restrictions placed on the data**<br>
Please use and distribute according to CC-BY v4.0. For a human readible version of this license visit [https://creativecommons.org/licenses/by/4.0/](https://creativecommons.org/licenses/by/4.0/).

**Links to publications that cite or use the data**<br>
SWAT simulated streamflow data was also used by [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780).

**Links to other publicly accessible locations of the data**<br>
This dataset and associated R code are available at https://github.com/sheilasaia/paper-yadkin-swat-svi-study and via [Zenodo](https://doi.org/10.5281/zenodo.2635878). The associated publication is available via [*Ecosystems*](https://link.springer.com/article/10.1007/s10021-019-00387-5) and via [*TreeSearch*](https://www.fs.usda.gov/treesearch/pubs/56780).

**Links/relationships to ancillary data sets**<br>
All links to publically available data are described here, in Saia et al. (2019), and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780).

**Data derived from another source**<br>
All links to publically available data are described here, in Saia et al. (2019), and in [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780).

**Additional related data collected that was not included in the current data package**<br>
This directory does not include all environmental data required to run and calibrate the SWAT model developed by [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). For this information, visit the GitHub repository associated with Suttles et al. (2018): https://github.com/sheilasaia/paper-yadkin-swat-study.

**Are there multiple versions of the dataset?**<br>
All publically available data is described here, in Saia et al. (2019), and in [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). With respect to simulated data and data analysis scripts, there are no other versions available online.

**Recommended citation for the data**<br>
Saia, S.M., K.M. Suttles, B.B. Cutts, R.E. Emanuel, K.L. Martin, D.N. Wear, J.W. Coulston, J.M. Vose. 2019. Applying Climate Change Risk Management Tools to Integrate Streamflow Projections and Social Vulnerability. *Ecosystems*. 23:67-83. [Ecosystems link](https://link.springer.com/article/10.1007/s10021-019-00387-5) [TreeSearch link](https://www.fs.usda.gov/treesearch/pubs/56780)

**Paper Availability**<br>
The paper is available online at via [*Ecosystems*](https://link.springer.com/article/10.1007/s10021-019-00387-5) and [*TreeSearch*](https://www.fs.usda.gov/treesearch/pubs/56780). If you do not have a subscription to the journal or are having trouble accessing it, please contact Sheila Saia directly for a copy of the pre-print.

## Data & File Overview ##
This repository is organized into two main directories: (1) swat\_svi\_python\_analysis and (2) swat\_svi\_r\_analysis.

### 1. swat\_svi\_python\_analysis directory ###
The swat\_svi\_python\_analysis directory contains two sub directories: data and scripts. The data directory includes spatial data and a scratch directory needed for storing temporary outputs. The scripts directory includes Python scripts (.py files) for calculating percent land cover for each subbasin and scaling SVI data from the census tract to  subbasin scale.

#### 1.1 data ####
Directory name: data <br>
Short description: This directory contains the spatial data directory.

##### 1.1.2 spatial #####
Directory names: spatial <br>
Short description: This directory contains spatial data and the scratch directory.

**File List**<br>
Filename: yadkin\_subs\_albers.shp <br>
Short description: This shape file contains the 28 YPD subbasin boundaries as delineated by SWAT. This file was generated by SWAT and then projected to the United States of America Contiguous Albers Equal Area Conic USGS projection to ensure more accurate area calculations later on. <br>

Filename: yadtracts\_30m <br>
Short description: This raster file contains the boundaries of census tracts within the YPD watershed at a 30 x 30m resolution. <br>

Filename: yadlu\_1992.tif <br>
Short description: This raster file contains the 1992 National Land Cover Dataset (NLCD) land use classes for the YPD watershed at a 30 x 30m resolution. <br>

Filename: yadlurec\_1992 <br>
Short description: This raster file was created using by reclassifying (i.e., combining) land use categories from yadlu\_1992.tif so they could be compared to the 2060 data. We used the ESRI ArcGIS raster calculator and exported the summary table to caculate watershed wide land use classes and save these data to yadkin\_lu\_baseline\_reclass\_1992.txt (see 2.5.2).<br>

Filename: yadluA\_2060.tif <br>
Short description: This raster file represents the 2060 land use under the MIROC 8.5 scenario as described in Saia et al. (2019) and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). These data came from the USFS Southern Research Station's Forest Futures report as described in further detail in Saia et al. (2019) and Suttles et al. (2018). We used the ESRI ArcGIS raster calculator and exported the summary table to caculate watershed wide land use classes and save this data to yadkin\_lu\_miroc8\_5\_2060.txt (see 2.5.2).<br>

Filename: yadluB\_2060.tif <br>
Short description: This raster file represents the 2060 land use under the CSIRO 8.5 scenario as described in Saia et al. (2019) and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). These data came from the USFS Southern Research Station's Forest Futures report as described in further detail in Saia et al. (2019) and Suttles et al. (2018). We used the ESRI ArcGIS raster calculator and exported the summary table to caculate watershed wide land use classes and save this data to yadkin\_lu\_csiro8\_5\_2060.txt (see 2.5.2).<br>

Filename: yadluC\_2060.tif <br>
Short description: This raster file represents the 2060 land use under the CSIRO 4.5 scenario as described in Saia et al. (2019) and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). These data came from the USFS Southern Research Station's Forest Futures report as described in further detail in Saia et al. (2019) and Suttles et al. (2018). We used the ESRI ArcGIS raster calculator and exported the summary table to caculate watershed wide land use classes and save this data to yadkin\_lu\_csiro4\_5\_2060.txt (see 2.5.2).<br>

Filename: yadluD\_2060.tif <br>
Short description: This raster file represents the 2060 land use under the Hadley 4.5 scenario as described in Saia et al. (2019) and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). These data came from the USFS Southern Research Station's Forest Futures report as described in further detail in Saia et al. (2019) and Suttles et al. (2018). We used the ESRI ArcGIS raster calculator and exported the summary table to caculate watershed wide land use classes and save this data to yadkin\_lu\_hadley4\_5\_2060.txt (see 2.5.2).<br>

Filename: scratch directory <br>
Short description: The scrach directory is an intentionally empty directory that is used to hold temporary (intermediate) files generated by the .py scrips in the scripts directory (see 1.2).

**Relationship Between Files**<br>
These files were used to compute percentage of land use in the baseline (1982-2002) and projected (2050-2070) periods. The Python files used to do these calculations are explained in further detail in 1.2 and tabular data (.txt files) are described in further detail in 2.5.1. These results were then compared to assess land use change in the YPD.

**Raw Data**<br>
The directory does not contain raw data but data sources are explained in the README.md file contained within the spatial directory.<br>

#### 1.2 scripts ####
Directory name: scripts<br>
Short description: This directory contains six Python scripts that were used to automate land use percentage calculations and SVI scaling for each subbasin in the YPD. <br>

**File List**<br>
Filename: lu\_baseline\_1992\_area\_calcs.py <br>
Short description: This Python script automates the percent area calculation for various 1992 NLCD land use types within each of the 28 subbasins. This script generates the lu\_baseline\_1992\_allsubs.csv file (see 2.5.2). <br>

Filename: lu\_miroc8\_5\_2060\_area\_calcs.py <br>
Short description: This Python script automates the percent area calculation for various 2060 MIROC 8.5 scenario land use types within each of the 28 subbasins. This script generates the lu\_miroc8\_5\_2060\_allsubs.csv file (see 2.5.2). <br>

Filename: lu\_csiro8\_5\_2060\_area\_calcs.py <br>
Short description: This Python script automates the percent area calculation for various 2060 CSIRO 8.5 scenario land use types within each of the 28 subbasins. This script generates the lu\_csiro8\_5\_2060\_allsubs.csv file (see 2.5.2). <br>

Filename: lu\_csiro4\_5\_2060\_area\_calcs.py <br>
Short description: This Python script automates the percent area calculation for various 2060 CSIRO 4.5 scenario land use types within each of the 28 subbasins. This script generates the lu\_csiro4\_5\_2060\_allsubs.csv file (see 2.5.2).<br>

Filename: lu\_hadley4\_5\_2060\_area\_calcs.py <br>
Short description: This Python script automates the percent area calculation for various 2060 Hadley 4.5 scenario land use types within each of the 28 subbasins. This script generates the lu\_hadley4\_5\_2060\_allsubs.csv file (see 2.5.2). <br>

Filename: svibd\_2014\_scaling\_calcs.py <br>
Short description: This Python script automates SVI scaling calculations for each of the 28 YPD subbasins. These proportions (saved in svibd\_2014\_scaling\_allsubs.csv, see 2.5.2) are needed to convert census tract SVI result to the subbasin scale.<br>

**Relationship Between Files**<br>
The lu*.py scripts are used to calculate the percent area of a given land use type for each of the 28 subbasins in the YPD and results are exported to the tabular data director for R analysis (see 2.5.2). The svibd\_2014\_scaling\_calcs.py script calculates the percentage of subbasin area that each census tract takes up for scaling purposes (see 2.3) and generates svibd\_2014\_scaling\_allsubs.csv to do so (see 2.5.2). The scratch directory is intentionally empty but holds temporary files when the .py scrits in the scripts directory are executed.

**Raw Data**<br>
The directory does not contain raw data but does rely on raw data provided by publically available sources as explained in the README.md file contained within the spatial directory.<br>

### 2. swat\_svi\_r\_analysis directory ###
The swat\_svi\_r\_analysis directory contains R scripts as well as three subdirectories: data, figures, and functions.

#### 2.1 hiflow\_analysis.R ####
Filename: hiflow\_analysis.R <br>
Short description: This R script reformats SWAT output.rch files and uses them to calculate the percent change in the number of 10yr and outlier streamflow events as described by Saia et al. (2019). <br>

**Relationship Between Files**<br>
This R script requires several R fucntions (see 2.6), raw SWAT outputs (output.rch files, see 2.5.2) and the YPD subbasin boundary shape file yadkin_subs_utm17N.shp (see 2.5.1). This R script generates tabular data (i.e., hiflow\_10yr\_change\_calcs.csv and hiflow\_outlier\_change\_calcs.csv described in 2.5.2) and figures presented in Saia et al. (2019).

**Raw Data**<br>
The file does not contain raw data but relies on raw data stored in the tabular directory (see 2.5.2).<br>

#### 2.2 svi\_reformatting.R ####
Filename: svi\_reformatting.R <br>
Short description: This R script reformats raw SVI (2010-2014 period) for the US and generates the us\_svi\_2014\_albers\_reformatted.csv file (see 2.5.2). <br>

**Relationship Between Files**<br>
This R script generates the us\_svi\_2014\_albers\_reformatted.csv file (see 2.5.2), which is required to run the svi\_analysis.R script (see 2.3).

**Raw Data**<br>
The directory does not contain raw data but relies on raw data obtained from publically available datasets as described in the spatial directory README file (see 2.5.1).<br>

#### 2.3 svi\_analysis.R ####
Filename: svi\_analysis.R <br>
Short description: This R script analyzes SVI data for the YPD, combines SVI data with SWAT outputs as described by Saia et al. (2019), and generates figures for this publication. <br>

**Relationship Between Files**<br>
This R script requires several R fucntions (see 2.6), svibd\_2014\_scaling\_allsubs.csv (see 1.2 and 2.5.2), us\_svi\_2014\_albers\_reformatted.csv (see 2.5.2), and several shape files (see 2.5.1). It generates data and figures as presented in Saia et al. (2019). Figures are exported to the figures directory (see 2.7).

**Raw Data**<br>
The directory does not contain raw data.<br>

#### 2.4 landuse\_analysis.R ####
Filename: landuse\_analysis.R <br>
Short description: This R script caculates percent change in land use between the baseline and projected periods for each subbasin in the YPD as presented in Saia et al. (2019).

**Relationship Between Files**<br>
This R script requires several R fucntions (see 2.6), outputs from Python land use script analysis (see 1.2 and 2.5.2), raw SWAT outputs for baseline conditions (true_baseline_output.rch, see 2.5.1), and the yadkin\_subs\_utm17N.shp shape file (see 2.5.1). This R script generates data and figures that are presented in Saia et al. (2019). Figures are exported to the figures directory (see 2.7).<br>

**Raw Data**<br>
The directory does not contain raw data.<br>

#### 2.5 data ####
Directory name: data <br>
Short description: This directory contains the spatial and tabular data directories. These data are required for R data analysis.

##### 2.5.1 spatial #####
Directory names: spatial <br>
Short description: This directory contains spatial data.

**File List**<br>
Filename: yadkin\_subs\_utm17N.shp <br>
Short description: This shape files includes each of the 28 YPD subbasin boundaries. For further details on where this information was obtained, see the README file in the spatial directory. <br>

Filename: yadkin\_svi2014\_utm17N.shp <br>
Short description: This shape files includes the census tract SVI data clipped to the YPD boundary. For further details on where this information was obtained, see the README file in the spatial directory. <br>

Filename: yadkin\_counties\_svi2014\_utm17N.shp <br>
Short description: This shape files includes the census tract SVI data clipped to the county boundaries that touch the YPD boundary. For further details on where this information was obtained, see the README file in the spatial directory. <br>

Filename: yadkin\_majortribs\_utm17N.shp <br>
Short description: This shape files includes the major rivers of the YPD. For further details on where this information was obtained, see the README file in the spatial directory. <br>

Filename:yadkin\_unclip\_counties\_utm17N.shp
Short description: This shape files includes the county boundaries overlapping the YPD. For further details on where this information was obtained, see the README file in the spatial directory.

**Relationship Between Files**<br>
These files are required to run some of the R scripts (see 2.1-2.4). For further details on where this information was obtained, see the README file in the spatial directory.

**Raw Data**<br>
The directory does not contain raw data.<br>

##### 2.5.2 tabular #####
Directory names: tabular <br>
Short description: This directory contains tabular data.

**File List**<br>
Filename: *output.rch files <br>
Short description: These output.rch files were generated by SWAT as explained by [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780) and Saia et al. (2019). The tabular data directory includes SWAT output.rch files the baseline (true\_baseline\_output.rch, miroc\_backcast\_baseline_output.rch, csiro\_backcast\_baseline\_output.rch, hadley\_backcast\_baseline\_output.rch) and each of the four projection (miroc8\_5\_projected\_output.rch, csiro8\_5\_projected\_output.rch, csiro4\_5\_projected\_output.rch, hadley4\_5\_projected\_output.rch). <br>

Filename: yadkin\_lu\_*.txt files <br>
Short description: These files (yadkin\_lu\_baseline\_reclass\_1992.txt, yadkin\_lu\_miroc8\_5\_2060.txt, yadkin\_lu\_csiro8\_5\_2060.txt, yadkin\_lu\_csiro4\_5\_2060.txt, yadkin\_lu\_hadley4\_5\_2060.txt) were obtained by exporting the summary tables from baseline and projected land use data (see 1.1.2).<br>

Filename: lu\_*\_allsubs.csv files <br>
Short description: These files (lu\_baseline\_1992\_allsubs.csv, lu\_miroc8\_5\_2060\_allsubs.csv, lu\_csiro8\_5\_2060\_allsubs.csv, lu\_csiro4\_5\_2060\_allsubs.csv, lu\_hadley4\_5\_2060\_allsubs.csv) were generated by Python scripts (see 1.2) and are used in the landuse\_analysis.R script (see 2.4).  <br>

Filename: kn\_table\_appendix4\_usgsbulletin17b.csv <br>
Short description: This file was created by converting the k<sub/>n</sub> table in Appendix 4 from the USGS Bulletin 17b as referenced in Saia et al. (2019). <br>

Filename: us\_svi\_2014\_albers.txt <br>
Short description: This file was derived spatial SVI data obtained on the the [ATSDR data download website](https://svi.cdc.gov/data-and-tools-download.html) for all census tracts in the United States but does not include spatial data (i.e., it was obtained by exporting the attribute data in ESRI ArcGIS). For further details on where this information was obtained, see the README file in the spatial directory (see 2.5.1). It was projected to United States of America Contiguous Albers Equal Area Conic USGS projection using ESRI ArcGIS; we did not check the 'preserve shape' box. <br>

Filename: us\_svi\_2014\_albers\_reformatted.txt <br>
Short description: This file is the reformatted version of us\_svi\_2014\_albers.txt. Reformatting was done using the svi\_reformatted.R script (see 2.2). <br>

Filename: svibd\_2014\_scaling\_allsubs.csv <br>
Short description: This file includes the scaling factors to convert cenus tract SVI data to the subbasin scale. It was generated using the svibd\_2014\_scaling\_calcs.py script described in 1.2.<br>

Filename: hiflow\_10yr\_change\_calcs.csv <br>
Short description: This file includes the percent change in number of 10yr flows as calculated using the hiflow\_analysis.R script (see 2.1). <br>

Filename: hiflow\_outlier\_change\_calcs.csv <br>
Short description: This file includes the percent change in number of outlier flows as calculated using the hiflow\_analysis.R script (see 2.1). <br>

**Relationship Between Files**<br>
These tabular files are required to run the various R scripts described in 2.1-2.4.

**Raw Data**<br>
The directory does not contain raw data.<br>

#### 2.6 functions ####
Directory name: functions <br>
Short description: This directory contains the home-made R functions needed to run the .R scripts (see 2.1-2.4).

**File List**<br>
Filename: count\_hiflow\_outliers\_using\_baseline.R <br>
Short description: This R function finds outliers in the SWAT baseline output.rch files for high flow risk analysis. <br>

Filename: count\_hiflow\_outliers.R <br>
Short description: This R function finds outliers in projected SWAT output.rch file for high flow risk analysis. <br>

Filename: flow\_change.R <br>
Short description: This R function calculates the percent change in the number of flows between baseline and projection datasets for a given return period. <br>

Filename: logperson3\_factor\_calc.R <br>
Short description: This R function calculates log-Pearson type III frequency factor (kt) for high flow frequency analysis of streamflow data (i.e., output.rch files). <br>

Filename: model\_freq\_calcs\_one\_rch.R <br>
Short description: This R function generates log-Pearson type III model curves for high flow frequency analysis of one subbasin. <br>

Filename: model\_freq\_calcs\_all\_rchs.R <br>
Short description: This R function generates log-Pearson type III model curves for high flow frequency analysis of all subbasins. <br>

Filename: multiplot.R <br>
Short description: This R function enables plotting of multiple ggplot objects in one layout.<br>

Filename: obs\_freq\_calcs\_one\_rch.R <br>
Short description: This R function selects observations for high flow frequency analysis of one subbasin.<br>

Filename: obs\_freq\_calcs\_all\_rchs.R <br>
Short description: This R function selects observations for high flow frequency analysis of all subbasins.<br>

Filename: outlier\_change.R <br>
Short description: This R function calculates the percent change in number of minor and major outliers between baseline and projection datasets.<br>

Filename: reformat\_rch\_file.R <br>
Short description: This R function prepares (reformats) SWAT output.rch files for high flow frequency and high outlier flow analysis.<br>

Filename: remove\_outliers.R <br>
Short description: This R function identifies and removes statistically significant high outliers and then gives new data frame without them.<br>

Filename: rp\_n\_flow\_change.R <br>
Short description: This R function determines the percent change in number of flows greater than or equal to a specified return period between the baseline and projection datasets. <br>

**Relationship Between Files**<br>
These functions are required to run the .R scripts (see 2.1-2.4).

**Raw Data**<br>
The directory does not contain raw data.<br>

#### 2.7 figures ####
Directory name: figures <br>
Short description: This directory is left intentionally empty to store figure outputs from the .R scripts (see 2.1-2.4).

**Relationship Between Files**<br>
There are intentionally no files in this directory.

**Raw Data**<br>
The directory does not contain raw data.<br>

## Methodological Information ##

**Description of methods used for collection/generation of data:**<br>
See the associated *Ecosystems* journal article for a full description of the methods used to collect and analyze these data.

**Methods for processing the data:**<br>
See the R and Python scripts in this repository as well as the associated *Ecosystems* journal article for a full description of the methods used to collect and analyze these data.

**Instrument- or software-specific information needed to interpret the data:**<br>
R (open-source, version 3.4.3, [https://www.r-project.org/](https://www.r-project.org/)) is needed to run .R files, Python (open-source, version 2.7, [https://www.python.org/](https://www.python.org/)) is needed to run .R files, and an ESRI ArcGIS (license required, version 10.4.1, [http://desktop.arcgis.com/en/](http://desktop.arcgis.com/en/)) license is required to run Python scripts that use the arcpy library. Land use data (.tif) and shape files (.shp) can be opened using ESRI ArcGIS or QGIS (open-source, version 2.18 [https://qgis.org/en/site/](https://qgis.org/en/site/). R, Python, or an all purpose text editor can be used to run .csv and .txt files.

**Standards and calibration information, if appropriate:**<br>
See [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780) for destails on SWAT model calibration.

**Environmental/experimental conditions:**<br>
See the associated *Ecosystems* journal article and [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780) for a full description of observed and modeled data used in this study.

**Describe any quality-assurance procedures performed on the data:**<br>
SWAT simulations were calibrated and validated. This is described in further detail in [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). When possible, data analysis was automated in R and Python to ensure consistency.

**People involved with sample collection, processing, analysis and/or submission:**<br>
See the associated *Ecosystems* journal article for a full description of author contributions and acknowledgments.

## Data-Specific Information For Tabular Data ##

**Variable list**<br>
Variables descirptions for *output.rch files are included in the GitHub repository associated with Suttles et al. (2018) found here: https://github.com/sheilasaia/paper-yadkin-swat-study and in README files within the associated tabular data directory. SVI, land use, and SWAT model variable listings are described in the associated tabular data directory README file (see swat\_svi\_r\_analysis > data > tabular). For further descriptions of SVI data variables see the [ATSDR data download website](https://svi.cdc.gov/data-and-tools-download.html). For further description of NLCD data variables see the [NLCD website](https://catalog.data.gov/dataset/usgs-national-land-cover-dataset-nlcd-downloadable-data-collection). For further description of SWAT output.rch file variables see the [SWAT Documentation] (https://swat.tamu.edu/media/69395/ch32_output.pdf).

**Missing data codes**<br>
'NA' indicates missing data unless otherwise noted.
