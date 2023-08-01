---
title: "Defining and Providing Fewer Economic Resources"
output:
  html_document:
    df_print: paged
    keep_md: yes
---




## Problem statement 

The Colorado State Forest Service (CSFS) encourages wildfire mitigation through the Forest Restoration & Wildfire Risk Mitigation (FRWRM) Grant Program.  The legislation authorizing funding for the program seeks to encourage funding to areas with “fewer economic resources”.  The CSFS needs to define “fewer economic resources”, and provide this information to applicants, preferably through the existing Colorado Forest Atlas.

Defining "fewer economic resources" is challenging because resources refer to everything at a community’s disposal.  In this work, we will draw from the literature to define an index that captures populations’ vulnerability to natural disasters such as wildland fire.  We tailor the index, the Wildland Fire Social Vulnerability Index (WFSVI),  to the wildland urban interface (WUI) in Colorado.  The WFSVI allows us to identify the areas of the state that are the most vulnerable.  We assign the top quartile as eligible for increased match as part of the FRWRM program. 



## Methods

The objective of this project is to construct a measure of *fewer economic resources* for the WUI in Colorado.  The layer is intended to highlight areas that are eligible for a reduced match via the Colorado State Forest service grants for wildfire risk mitigation. The Index is calculated only for areas that contain WUI. 




#### Map Details

The map above shows the CBGs in Colorado.  All inhabited CBGs colored by their eligibility for increased match. CBGS that are colored red are eligible for increased match.  This means that they have a WFSVI score of 75 or greater. If you click on a CBG a table will pop up and display the information that was used to calculate the SVI as well as the WFSVI ranking. On the map, areas without an WFSVI ranking due to their non-WUI status are marked Non-WUI, but the information is available.


## Introduction to Index

We adapt the Social Vulnerability Index (SVI) (Flanagan et al., 2011) to the wildland fire context in Colorado.  The SVI was created in response to Hurricane Katrina to capture the social (rather than biophysical) features of a community that make it vulnerable.  The SVI ranges from 0 (not vulnerable) to 100 (highly vulnerable).  It acknowledges that those who are socially vulnerable are more likely to experience loss and less likely to recover.  Its original intent was to help state and federal level disaster responders identify the most affected areas post-event.  The authors also recognize its potential for use in other stages of the disaster cycle, such as mitigation.  Allocating funding for mitigation activities represents a forward-looking approach to equitable planning for wildfire incidents.

The projects funded by FRWRM fall into the mitigation and preparedness portions of the disaster cycle, but many of the post-event considerations apply to mitigation and preparedness.  The SVI addresses four main categories of vulnerability: socioeconomic status, household composition/ disability, minority status/ language, and housing/transportation.  These characteristics are important during all phases of the disaster cycle but especially mitigation.  Those with little purchasing power, high burden of care, or who experience difficulty interacting with the community for cultural or physical reasons will be less able to participate in mitigation activity.  Communities who have high overall levels of vulnerability may require additional assistance to complete migitation activities. 

### Data

We construct the Colorado SVI using data from the 2016 American Community Survey (5-year average).  The original SVI was calculated at the census tract, but the data are now available at the census block group (smaller geographic unit) to better identify community demographics.  We then crop the spatial layers to the boundary of the WUI as defined by the boundaries used in the grant process. The ACS data can be downloaded at https://www.safegraph.com/open-census-data.  The zip file should be placed into the Data folder and unzipped.  To replicate the WFSVI the WUI layer will also need to be obtained fronm the CSFS and placed in the Data folder as well.  

ACS data is an excellent source of demographic data between decennial censuses, and it includes data at very fine scales, such as CBG.  It is important to keep in mind however that not all census collected data is a raw count or estimate.  The Census Bureau does hold the responsibility to furnish useful information for resource allocation and research, but it also has a responsibility to protect individual identity.  That means that for CBGs that have small populations not all information is available.  There are a handful of CBGs in Colorado with no population, or one so small that most variables of interest were not reported.  These are left out of analysis and assigned a rank of zero.  We also identify CBGS that are missing only one variable, this is predominantly income.  We impute this to be the mean of all Colorado CBGs and include them in the ranking described below.   

We conduct all data analysis and geoprocessing in the R Statistical Computing Language.  The code is made available on GitHub.

### Methods


In constructing the WFSVI we aknowledge several possible limitations to the SVI. First, average measures within a community may obscure the variation in vulnerability within the community.  For example, a census defined geography may contain households that qualify as highly vulnerable and households that qualify as minimally vulnerable.  Average characteristics reported in this community may indicate moderate vulnerability.  We account for these heterogeneities by adding two measures to the WFSVI: income GINI and an education GINI.  The GINI coefficient measures inequality, another measure of heterogeneity. Using the example of income, if everyone had the same income, the income GINI would equal zero.  Conversely, if one household earned all the income in a CBG and the rest of the community received none, the income GINI would equal one.  Additionally we note that by not weighting variables contributions to the SVI they all recieve equal weighting.  This implies that some categories recieve more weight than others.  These differential weightings are not justified by the literature, but rather arise from the number of variables identified in a category.  As a result we reweight varaibles to reflect concerns in the Colorado WUI.

We construct the WFSVI based on Flanagan et al (2011).  The SVI and WFSVI are bounded between 0 and 1 with 0 being the least vulnerable.  The following steps outline the construction of the WFSVI. We make a few minor changes to the original index variables to reflect modern ideas on measures of central tendency as well as data limitations.  These changes are italicized.

1. We percent rank the variables independently across all Census Block Groups (CBGs) in Colorado. *We add the GINI variables to account for mixing of high and low levels of resources.*
2. *We set weights of non-wildland fire pertinent variables such variable 13 in the list below.  We also reweight other variables to emphasize resources that limit the ability to engage in mitigation.  The reweights used are given below as percent contributions to the overall WFSVI.*

3. Finally we add them together, and percent rank them again.  We place more weight on income and housing characteristics that are more relevant to wildfire risk.  This percent rank is the  WFSVI score.

4.We can now assign the status of "fewer economic resources" with the WFSVI.   *We assign a qualifying status to any CBG with a rank above .75.  CBGs that rank in the top quartile in the WFSVI are eligible for an increased match.*





### Variables

We describe the variables used to construct the Index below. We express the relative importance of the variables in the percentages in parentheses.  The percentages represent the relative weight of the variable in the SVI ranking.  The individual variable weights can be summed to represent the relative weight of the categories.  The category weights are shown for reference. 

#### Socioeconomic Status Variables (39 %)
1.  Percent of individuals below the poverty line (12.20 %)
2.  Percent of the Civilian labor force which is unemployed (7.31 %)
3.  Median household income (12.20 %)
4.  Percent of adults over 25 without a High School Diploma(7.31 %)

#### Household Composition/Disability (12.2 %)
5.  Percent of people over the age of 65 (2.44 %)
6.  Percent of people under the age of 18 (2.44 %)
7.  Percent of the poverty status determined population above 18 with a disability (2.44 %)
(The original index included those over 5, but this data is not included in the ACS)
8.  Percent of households with a male or female householder, no spouse present, with children under 18 (2.44 %)

#### Minority Status/Language (17.1 %)
9.  Percent of the population that are of minority status (Non-white or Hispanic) (12.20 %)
10. Percent of the population that speaks English less than "well" (4.88 %)

#### Housing/Transportation (7.32 %)
11. Percent of housing structures that have 10 or more units (0%)
12. Percent of housing units that are mobile homes (4.88 %)
13. Percent of households that live in a housing unit with more people than rooms (0%)
14. Percent of households with no vehicle (2.44%)
15. Percent of people who live in group housing such as nursing homes (0%)

#### New Equity Variables (24.4 %)
16. Income GINI (12.20 %)
17. Years of schooling/ Education GINI (12.20 %)


## References
Flanagan, Barry E., Edward W. Gregory, Elaine J Hallisey, Janet L. Heitgerd, and Brian Lewis. 2011. “A Social Vulnerability Index for Disaster Management.” Journal of Homeland Security and Emergency Management 8 (1). https://doi.org/10.2202/1547-7355.1792.

Gaither, Cassandra Johnson, Neelam C. Poudyal, Scott Goodrick, J. M. Bowker, Sparkle Malone, and Jianbang Gan. 2011. “Wildland Fire Risk and Social Vulnerability in the Southeastern United States: An Exploratory Spatial Data Analysis Approach.” Forest Policy and Economics 13 (1): 24–36. https://doi.org/10.1016/j.forpol.2010.07.009.

Palaiologou, Palaiologos, Alan A. Ager, Max Nielsen-Pincus, Cody R. Evers, and Michelle A. Day. 2019. “Social Vulnerability to Large Wildfires in the Western USA.” Landscape and Urban Planning 189 (September): 99–116. https://doi.org/10.1016/j.landurbplan.2019.04.006.

