# python script to calculate weighted average of svi census tract data for each subbasin
# last updated: 20171212

# import libraries
import arcpy
import pandas

# check out extensions
arcpy.CheckOutExtension('Spatial')

# set workspace
arcpy.env.workspace=r'...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial'
# add in your specific project directory path wherever you see '...'

# get subbasin id's
subs_shp=r'...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\yadkin_subs_albers.shp'
subs_list=[]
with arcpy.da.SearchCursor(subs_shp, ['Subbasin']) as cursor:
    for i in cursor:
        subs_list.append(i[0])

# define yadkin svi (census tract) bounds
yad_svibd_ras=r'\\Mac\Home\Documents\ArcGIS\yadkin_arcgis_analysis_albers\yadtracts_30m'

# save number of subs
num_subs=len(subs_list)

# create empty data frame for output
output_df=pandas.DataFrame(columns=['SUB','fips','tract_perc','sub_perc'])

# run for loop for each subbasin
for sub in subs_list:
    # make mask for one subbasin
    raster_calc_str='SetNull("subs_30m"!='+str(sub)+',1)'
    mask_filename='...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\scratch\rastercalc'+str(sub)
    arcpy.gp.RasterCalculator_sa(raster_calc_str,mask_filename)

    # save total subbasin area for one subbasin
    sub_area_km2=[]
    with arcpy.da.SearchCursor(in_table=mask_filename,field_names=['COUNT']) as cursor:
        for i in cursor:
            sub_area_km2.append(i[0]*0.0009)

    # extract svi boundary data for one subbasin
    outputlu_filename='...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\scratch\svibdsub'+str(sub)
    arcpy.gp.ExtractByMask_sa(yad_svibd_ras,mask_filename,output_filename)

    # check if fields already exist (to avoid errors later)
    svidbsub_fields=[]
    for i in arcpy.ListFields(output_filename):
        field_name=i.name
        svidbsub_fields.append(field_name)

    # add fields
    arcpy.management.AddField(in_table=output_filename,field_name='SUB_AREA_KM2',field_type='FLOAT')
    arcpy.management.AddField(in_table=output_filename,field_name='TRACT_PERC',field_type='FLOAT')
    arcpy.management.AddField(in_table=output_filename,field_name='SUB_PERC',field_type='FLOAT')

    # calculate area of each svi boundary in one subbasin
    with arcpy.da.UpdateCursor(in_table=output_filename,field_names=['COUNT','SUB_AREA_KM2']) as cursor:
        for i in cursor:
            i[1]=i[0]*0.0009
            cursor.updateRow(i)

    # calculate the fraction of a census tract as it lies within the subbasin (wrt it's total, unclipped census tract area)
    # AREA_KM2 is the total census tract area and SUB_AREA_KM2 is the area of the census tract that lies within the subbasin (mostly it's 1 but in somecases it's < 1)
    with arcpy.da.UpdateCursor(in_table=output_filename,field_names=['AREA_KM2','SUB_AREA_KM2','TRACT_PERC']) as cursor:
        for i in cursor:
            i[2]=i[1]/i[0]
            cursor.updateRow(i)

    # calcuate the fraction of each census tract within the subbasin
    # (what percent of the subbasin is made up of that census tract)
    with arcpy.da.UpdateCursor(in_table=output_filename,field_names=['SUB_AREA_KM2','SUB_PERC']) as cursor:
        for i in cursor:
            i[1]=i[0]/sub_area_km2[0]
            cursor.updateRow(i)

    # get value and percent data
    sub_list=[]
    fips_list=[]
    tract_perc_list=[]
    sub_perc_list=[]
    with arcpy.da.SearchCursor(in_table=output_filename,field_names=['FIPS','TRACT_PERC','SUB_PERC']) as cursor:
        for i in cursor:
            sub_list.append(sub)
            fips_list.append(i[0])
            tract_perc_list.append(i[1])
            sub_perc_list.append(i[2])

    # output
    output_temp_df=pandas.DataFrame.from_items([('SUB',sub_list),('fips',fips_list),('tract_perc',tract_perc_list),('sub_perc',sub_perc_list)])

    # append output to all reasults dataframe
    output_df=pandas.concat([output_df,output_temp_df])
    output_df.reset_index(inplace=True, drop=True) # reset index

    # delete subbasin mask and svi boundary files to save space
    arcpy.management.Delete(in_data=mask_filename)
    arcpy.management.Delete(in_data=output_filename)

# export to csv file
outputdf_filename='...\paper-yadkin-swat-svi-study\swat_svi_r_analysis\data\tabular\svibd_2014_scaling_allsubs.csv'
output_df.to_csv(outputdf_filename,sep=',')

# check in extensions
arcpy.CheckInExtension('Spatial')
