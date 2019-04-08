# python script to calculate percent land cover class percentages for each subbasin
# USFS Forest Futures cornerstone D (= Hadley 4.5)
# last updated: 20170928

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

# define yadkin lc data
yadluD2060_ras=r'...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\yadluD_2060'

# save number of subs
num_subs=len(subs_list)

# create empty data frame for output
output_df=pandas.DataFrame(columns=['SUB','VALUE','AREA_PERC'])

# run for loop for each subbasin
for sub in subs_list:
    # make mask for one subbasin
    raster_calc_str='SetNull("subs_30m"!='+str(sub)+',1)'
    mask_filename='...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\scratch\rastercalc'+str(sub)
    arcpy.gp.RasterCalculator_sa(raster_calc_str,mask_filename)

    # extract land use data for one subbasin
    outputlu_filename='...\paper-yadkin-swat-svi-study\swat_svi_python_analysis\data\spatial\scratch\lusub'+str(sub)
    arcpy.gp.ExtractByMask_sa(yadluD2060_ras,mask_filename,outputlu_filename)

    # check if fields already exist (to avoid errors later)
    lusub_fields=[]
    for i in arcpy.ListFields(outputlu_filename):
        field_name=i.name
        lusub_fields.append(field_name)

    # delete field if so or will get errors when try to add it later
    if 'AREA_KM2' in lusub_fields:
        arcpy.management.DeleteField(outputlu_filename,'AREA_KM2')

    if 'AREA_PERC' in lusub_fields:
        arcpy.management.DeleteField(outputlu_filename,'AREA_PERC')

    # add fields
    arcpy.management.AddField(in_table=outputlu_filename,field_name='AREA_KM2',field_type='FLOAT')
    arcpy.management.AddField(in_table=outputlu_filename,field_name='AREA_PERC',field_type='FLOAT')

    # calculate percent area for each cover type for that one basin
    with arcpy.da.UpdateCursor(in_table=outputlu_filename,field_names=['COUNT','AREA_KM2']) as cursor:
        for i in cursor:
            i[1]=i[0]*0.0009
            cursor.updateRow(i)

    # get sum of cells in subbasin
    cell_count_list=[]
    with arcpy.da.SearchCursor(in_table=outputlu_filename,field_names=['COUNT']) as cursor:
        for i in cursor:
            cell_count_list.append(i[0])
    sum_cells=sum(cell_count_list)

    # calculate percent cover
    with arcpy.da.UpdateCursor(in_table=outputlu_filename,field_names=['AREA_KM2','AREA_PERC']) as cursor:
        for i in cursor:
            i[1]=(i[0]/(sum_cells*0.0009))*100
            cursor.updateRow(i)

    # get value and percent data
    sub_list=[]
    val_list=[]
    perc_list=[]
    with arcpy.da.SearchCursor(in_table=outputlu_filename,field_names=['VALUE','AREA_PERC']) as cursor:
        for i in cursor:
            sub_list.append(sub)
            val_list.append(i[0])
            perc_list.append(i[1])

    # output
    output_temp_df=pandas.DataFrame.from_items([('SUB',sub_list),('VALUE',val_list),('AREA_PERC',perc_list)])

    # append output to all reasults dataframe
    output_df=pandas.concat([output_df,output_temp_df])
    output_df.reset_index(inplace=True, drop=True) # reset index

    # delete subbasin mask and lu raster files to save space
    arcpy.management.Delete(in_data=mask_filename)
    arcpy.management.Delete(in_data=outputlu_filename)

# export to csv file
outputdf_filename='...\paper-yadkin-swat-svi-study\swat_svi_r_analysis\data\tabular\lu_hadley4_5_2060_allsubs.csv'
output_df.to_csv(outputdf_filename,sep=',')

# check in extensions
arcpy.CheckInExtension('Spatial')
