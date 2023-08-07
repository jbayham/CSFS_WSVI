#This script incorporates the CO EnviroScreen definition of Disporportionately Impacted Communities HB 23-1223.


wfsvi <- readRDS('Build/Output/wfsvi.rds') 

#The CO EnviroScreen tool was built using 5 year ACS data from 2015-2019. The older vintage uses historical boundaries from the 2010 census that have since been updated.  This analysis uses the 5 year ACS 2017-2021, which is based on post 2020 block group definitions. We use crosswalks built to harmonize data across the two boundary vintages (Manson et al., 2021). We use population and housing weights based on the CO EnviroScreen component.
# Steven Manson, Jonathan Schroeder, David Van Riper, Tracy Kugler, and Steven Ruggles.
# IPUMS National Historical Geographic Information System: Version 16.0 [dataset].
# Minneapolis, MN: IPUMS. 2021. http://doi.org/10.18128/D050.V16.0
xwalk <- read_csv("Build/Data/nhgis_bg2020_bg2010_08.csv") %>%
  select(bg2020ge,bg2010ge,wt_pop,wt_hh)

#CO EnviroScreen data (https://teeo-cdphe.shinyapps.io/COEnviroScreen_English/)
co_enviro_screen <- read_csv("Build/Data/Colorado_EnviroScreen_v1_BlockGroup.csv") %>%
  dplyr::select(GEOID, D_I_C,ES_S_,Prcnt_lw_,Hsn__,Prc___,Prcnt_ln_,May23_DIType,Jst40) %>%
  mutate(Jst40 = as.numeric(ifelse(is.na(Jst40),FALSE,TRUE))) %>%
  left_join(xwalk,by=c("GEOID"="bg2010ge"))

summary(co_enviro_screen$D_I_C)

#Collapse on 2020 block groups
coes_collapsed <- co_enviro_screen %>%
  group_by(bg2020ge) %>%
  summarize(low_income = stats::weighted.mean(Prcnt_lw_,w=wt_pop),
            housing_burden = stats::weighted.mean(Hsn__,w=wt_hh),
            poc = stats::weighted.mean(Prc___,w=wt_pop),
            ling_isolate = stats::weighted.mean(Prcnt_ln_,w=wt_hh),
            es_score = stats::weighted.mean(ES_S_,w=wt_pop),
            j40 = stats::weighted.mean(Jst40,w=wt_pop),
            old_dic_avg = stats::weighted.mean(D_I_C,w=wt_pop)) %>%
  mutate(new_dic=0,
         new_dic = case_when(
    low_income > 0.40 ~ 1,
    housing_burden > 0.50 ~ 1,
    poc > 0.40 ~ 1,
    ling_isolate > 0.20 ~ 1,
    es_score/100 > 0.80 ~ 1,
    new_dic==0 ~ 0
  ),
  new_dic = ifelse(is.na(low_income),NA,new_dic)) %>%
  filter(str_sub(bg2020ge,1,2)=="08") 

summary(coes_collapsed$new_dic)
#39.8% of cbgs are DIC vs 41.7% of the 2010 vintage



## merge the CO Enviro Screen disadvantaged communities with CBG data and determine qualifying CBG
## All CBGs in the J40 tracts will automatically qualify regardless of their SVI
wfsvi_coes <- inner_join(wfsvi, 
                         select(coes_collapsed,bg2020ge,coes_DIC=new_dic), 
                         by= c("GEOID"="bg2020ge")) %>%
  mutate(qualifying_cbg = if_else(wfsvi_qualify==1 | coes_DIC==1, 1, 0))

summary(wfsvi_coes$qualifying_cbg)

saveRDS(wfsvi_coes, file='Build/Output/wfsvi_coes.rds')
rm(j40_tracts, wfsvi, wfsvi_coes, xwalk, co_enviro_screen, coes_collapsed)

print('COMPLETE')




# Updated May 2023: 1 = Yes 0 = No.This field refers to areas that meet the definition of “Disproportionately Impacted Community” under Colorado law. House Bill 23-1233 adopted a definition that applies to all state agencies, including CDPHE. The definition includes census block groups where more than 40% of the population are low-income (meaning that median household income is at or below 200% of the federal poverty line), 50% of the households are housing cost-burdened (meaning that a household spends more than 30% of its income on housing costs like rent or a mortgage), 40% of the population are people of color (including all people who do not identify as non-Hispanic white), or 20% of households are linguistically isolated (meaning that all members of a household that are 14 years old or older have difficulty with speaking English). Also included in this definition are mobile home communities, the Ute Mountain Ute and Southern Ute Indian Reservations, and all areas that qualify as disadvantaged in the federal Climate and Economic Justice Screening Tool. The definition also includes census block groups that experience higher rates of cumulative impacts, which is represented by an EnviroScreen Score (Percentile) above 80. This definition is not part of the EnviroScreen components or score, and does not influence the results presented in the map, charts or table. Both areas that meet the current definition of of disproportionately impacted community that was adopted in May 2023 by HB23-1233, and the prior definition from HB21-1266 that was in effect from 2021 until May 2023 (which only included the race, income, housing cost burden, and EnviroScreen score above the 80th percentile) are shown in Colorado EnviroScreen.
