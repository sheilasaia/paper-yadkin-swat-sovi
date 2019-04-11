# README.md #

Last updated: 20190410 <br>
Contact Name: Sheila Saia <br>
Contact Email: ssaia at ncsu dot edu <br>

This is the README file for the spatial directory (swat_svi_r_anlysis > data > spatial) of the GitHub repository titled ['paper-yadkin-swat-svi-study'](https://github.com/sheilasaia/paper-yadkin-swat-svi-study). For additional details on these data and the associated publication, visit the perviously mentioned GitHub repository.

## 1. Data Availability ##
Data assocated with the spatial directory is available for download on [Google Drive](https://drive.google.com/drive/folders/1zWioj-AI2iY1CkmvYIksyQNnrpdL3i_B?usp=sharing).

## 2. File Descriptions & Metadata ##

**Filename**: yadkin\_svi2014\_utm17N.shp <br>
**Short description**: This shape files includes the census tract social vulnerability index (SVI) data clipped to the Yadkin-Pee Dee River Watershed (YPD) boundary.<br>
**Metadata**: This file was derived from spatial social vulnerability index (SVI) data downloaded on the ATSDR website (https://svi.cdc.gov/data-and-tools-download.html). Specifically, we downloaded the US-wide 2010-2014 census tract SVI dataset. We did not include the US-wide dataset in this repository because it is publically available. We projected the original US-wide SVI dataset to the Universal Transver Mercator (UTM) Zone 17N projection using ESRI ArcGIS and used the 'clip' tool in ESRI ArcGIS to select census tract SVI data within the YPD using yadkin\_subs\_utm17N.shp described below. <br>
**Variable Descriptions**: <br>
All variable descriptions are given in full detail on the on the ATSDR website (https://svi.cdc.gov/data-and-tools-download.html).<br>

**Filename**: yadkin\_subs\_utm17N.shp <br>
**Short description**: This shape files includes each of the 28 YPD subbasin boundaries. <br>
**Metadata**: We obtained the Yadkin-Pee Dee River Watershed (YPD) subbasin boundaries from [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780), projected these boundaries to Universal Transver Mercator (UTM) Zone 17N projection using ESRI ArcGIS, and calculated the area of each subbasin. 'Area' column is in units of hectares. <br>
**Variable Descriptions**: <br>
'OBJECTID' - Row identification number <br>
'GRIDCODE' - Subbasin identification number <br>
'Subbasin' - Subbasin identification number <br>
'Area' - Subbasin area (hectares) <br>

**Filename**: yadkin\_counties\_svi2014\_utm17N.shp <br>
**Short description**: This shape files includes the census tract SVI data clipped to the county boundaries that touch the YPD boundary. <br>
**Metadata**: We projected the original US-wide SVI dataset to the Universal Transver Mercator (UTM) Zone 17N projection using ESRI ArcGIS and used the 'clip' tool in ESRI ArcGIS to select census tract SVI data within the YPD using yadkin\_unclip\_counties\_utm17N.shp described below.<br>
**Variable Descriptions**: <br>
All variable descriptions are given in full detail on the on the ATSDR website (https://svi.cdc.gov/data-and-tools-download.html).<br>

**Filename**: yadkin\_unclip\_counties\_utm17N.shp <br>
**Short description**: This shape files includes the county boundaries overlapping the YPD. <br>
**Metadata**: We downloaded county bounds for the entire US at https://catalog.data.gov/dataset/tiger-line-shapefile-2016-nation-u-s-current-county-and-equivalent-national-shapefile and selected counties only in NC, SC, and VA. We then projected the NC, VA, and SC county boundaries to the Universal Transver Mercator (UTM) Zone 17N projection using ESRI ArcGIS. Additional metadata for this spatial data is available at https://catalog.data.gov/harvest/object/0b750119-b436-4ce3-88ec-7aa59c5311bb.<br>
**Variable Descriptions**: <br>
'STATEFP' - <US Census 2-digit state FIPS codebr>
'COUNTYFP' - US Census 3-digit county FIPS code <br>
'GEOID' - US Census 5-digit FIPS code<br>
'NAME' - Short county name<br>
'NAMESLAD' - Full county name<br>

**Filename**: yadkin\_majortribs\_utm17N.shp <br>
**Short description**: This shape files includes the major tributaries of the YPD.<br>
**Metadata**: This file was obtained from Kelly Suttles of [Suttles et al. (2018)](https://www.fs.usda.gov/treesearch/pubs/56780). She derived it from the [USGS National Hydrography Dataset (NHD)](https://www.sciencebase.gov/catalog/item/5a96cdc6e4b06990606c4d76) for NC by sampling only the largest rivers in the state of NC. Specifically, where the 'GNIS_NAME' of the NC NHD hydromaj\_arc.shp file attribute table was not an empty cell. For this study, we clipped the NC major tributaries (the outer-most YPD boundary of yadkin\_subs\_utm17N.shp) using the 'clip' tool in ESRI ArcGIS. The resulting .shp file is in the the Universal Transver Mercator (UTM) Zone 17N projection.<br>
**Variable Descriptions**: <br>
'OBJECTID'- Object identification number<br>
'STREAM\_NAM'- Stream name<br>
'RIV\_BASIN'- River basin name<br>
