# paper-yadkin-swat-sovi
Data repository for paper titled: "Applying Climate Change Risk Management Tools to Combine Streamflow Projections and Social Vulnerability".

(DOI *Ecosystems* link XXXX)

This README.md file was generated on 20181219 by Sheila Saia.

This GitHub repository was created to provide access to collected data, analysis code, and other information associated with the paper by Saia et al. titled "Applying Climate Change Risk Management Tools to Combine Streamflow Projections and Social Vulnerability" in *Ecosystems* (paper link XXXX).

## General Information ##

**Title of Dataset**<br>
"paper-yadkin-swat-sovi"

**Dataset & Repo Contact Information**<br>
Name: Sheila Saia<br>
Institution: United States Department of Agriculture Forest Service, Southern Research Station<br>
Address: XXXX Cornwallis Road, Durham, NC 27703<br>
Email: ssaia at ncsu dot edu

**Date of data collection**<br>
SWAT model outputs were generated in 2016. United States Forest Service landuse predictions were generated in 2015. SoVI results were downloaded from the Centers for Disease Control XXXX website (link XXXX) in 2018. All other data originated from publically available sites as described in the associated paper.

**Geographic location of data collection**<br>
All data is associated with the Upper Yadkin-Pee Dee River Watershed in North Carolina, USA.

**Information about funding sources that supported the collection of the data**<br>
Sheila Saia was supported by funding through the Oak Ridge Institute for Science and Education (ORISE).

## Sharing & Access Information ##

**Licenses/restrictions placed on the data**<br>
Please use and distribute according to CC-BY v4.0. For a human readible version of this license visit [https://creativecommons.org/licenses/by/4.0/](https://creativecommons.org/licenses/by/4.0/).

**Links to publications that cite or use the data**<br>
SWAT simulated streamflow data was also used by [Suttles et al. (XXXX)](XXXX).

**Links to other publicly accessible locations of the data**<br>
This dataset and associated R code are available at https://github.com/sheilasaia/paper-yadkin-swat-sovi and via Zenodo (XXXX). The associated publication is available via *Ecosystems* (XXXX).

**Links/relationships to ancillary data sets**<br>
All links to publically available data is described here and in Saia et al. (XXXX) and Suttles et al. (2018). With respect to simulated data and data analysis scripts, there is data is also linked to the study dataset explained in [Suttles et al. (XXXX)](XXXX).

**Data derived from another source**<br>
All links to publically available data is described here, in Saia et al. (2018), and in Suttles et al. (2018).

**Additional related data collected that was not included in the current data package**<br>
This directory does not include...

**Are there multiple versions of the dataset?**<br>
All publically available data is described here, in Saia et al. (XXXX), and in Suttles et al. (2018). With respect to simulated data and data analysis scripts, there are no other versions available online.

**Recommended citation for the data**<br>
XXXX

**Paper Availability**<br>
The paper is available online at via [*Ecosystems*](XXXX), [*Ecosystems*](XXXX) [*Treesearch*](XXXX). If you do not have a subscription to the journal or are having trouble accessing it, please contact Sheila Saia directly for a copy of the pre-print.

## Data & File Overview ##
This repository is organized into XXXX main directories:

### 1. observed\_data directory ###
The observed\_data directory contains


#### 1.1 weather subdirectory ####
Directory name: weather <br>
Short description: This subdirectory contains

**File List**<br>
Filename: \*.txt files <br>
Short description: These text files include

**Relationship Between Files**<br>
The text files listed above are all required for running in SWAT. Please see README inside this subdirectory for more details on these files.

**Raw Data**<br>
This subdirectory does not contain any raw data because everything in it was automatically formatted for use with SWAT when it was downloaded from publically available sites.<br>

## Methodological Information ##

**Description of methods used for collection/generation of data:**<br>
See the associated *Ecosystems* journal article for a full description of the methods used to collect and analyze these data.

**Methods for processing the data:**<br>
See the R and Python scripts in this repository as well as the associated *Ecosystems* journal article for a full description of the methods used to collect and analyze these data.

**Instrument- or software-specific information needed to interpret the data:**<br>
R (open-source, [https://www.r-project.org/](https://www.r-project.org/)) is needed to run .R files, Microsoft Excel (license required, [https://products.office.com/en-us/excel](https://products.office.com/en-us/excel)) is needed to open .xlsx files, and Matlab (license required, [https://www.mathworks.com/products/matlab.html](https://www.mathworks.com/products/matlab.html)) is needed to run .m files. Land use and land cover data can be opened using ArcGIS (license required, [desktop.arcgis.com/en/](desktop.arcgis.com/en/)) or QGIS (open-source, [https://qgis.org/en/site/](https://qgis.org/en/site/)).

Python XXXX

**Standards and calibration information, if appropriate:**<br>
Information on calibrations are included in the 'Raw Data' section of this README file.

**Environmental/experimental conditions:**<br>
See the associated *Science of the Total Environment* journal article for a full description of observed and modeled data used in this study.

**Describe any quality-assurance procedures performed on the data:**<br>
SWAT simulations were calibrated and validated. This is described in further detail in Suttles et al. (2018). When possible, data analysis was automated in MatLab and R to ensure consistency.

**People involved with sample collection, processing, analysis and/or submission:**<br>
See the associated *Science of the Total Environment* journal article for a full description of author contributions and acknowledgments.

## Data-Specific Information For: swat\_precip\_summary\_outlet\_1982-2002.xlsx ##

**Variable list**<br>


**Missing data codes**<br>
No missing data codes.
