# APPROX-CR (A Passable Proxy of Residual-like Outcomes via Xgboost for Cognitive Reserve)

## Compiling Data

To generate predicted scores, download the data template [here](https://www.dropbox.com/s/yu1jwxxrfsan7mk/datatemplate.csv?dl=1).

This file has 20 columns of data, described below. *Caution should be used when applying this model to data that fall outside of the ranges used in the training sample.*

- **id**: participant ID # (site-specific)
- **label**: site-specific label (if necessary)
- **age**: Age in years. Range in training sample was 49 - 97.
- **education**: years of education. Range in training sample was 0 - 20.
- **male**: Male sex (0 = female; 1 = male)
- **bpsys**: Systolic blood pressure (mm Hg). Range in training sample was 83 - 230.
- **bpdias**: Diastolic blood pressure (mm Hg). Range in training sample was 33 - 110.
- **hrate**: Heart rate. Range in training sample was 35 - 111.
- **height_m**: Height in meters. Range in training sample was 1.32 - 1.96.
- **weight_kg**: Weight in kilograms. Range in training sample was 38.56 - 151.00.
- **waist_cm**: Waist circumference in centimeters. Range in training sample was 40.00 - 140.50.
- **hip_cm**: Hip circumference in centimeters. Range in training sample was 81.00 - 152.10.
- **memcncrn**: ECog Self-report question "Are you concerned that you have a memory or other thinking problem?" (0 = no; 1 = yes)
- **amnart45**: AMNART score (45-item version). Range in training sample was 0 - 45.
- **adj_mmse**: MMSE or MoCA score. If MoCA, convert to MMSE equivalent using this [crosswalk paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4704083/) (Saczynski et al., 2015). Range in training sample was 5 - 30.
- **gds**: Geratric Depression Scale (15-item) score. Range in training sample was 0 - 14.
- **cdrsum**: Clinical Dementia Rating Sum of Boxes score. Range in training sample was 0 - 17.
- **memory**: Clinical Dementia Rating Memory Box score. Range in training sample was 0 - 3.
- **ecogmem**: ECog (informant-report) Memory domain score (average). Range in training sample was 1 - 4.
- **ecog_avg**: ECog (informant-report) Total score (average). Range in training sample was 1 - 4.

Values for some of the derived variables (e.g., pulse pressure, BMI) will be calculated from the data provided.

Missing values are allowed - leave missing cells blank or provide a missing data code (code must be the same for all variables).

## Prerequisites

R and RStudio are needed to generate scores. 

- R can be downloaded from https://cran.r-project.org/.
- RStudio can be downloaded from https://posit.co/download/rstudio-desktop/

## Generating Scores

1. Download the `app.R` file from this Github repository. Open `app.R` in RStudio and click the "Run App" button.
2. A new window will open ("Generate APPROX-CR Scores to Estimate Cognitive Reserve"). You may wish to click "Open in Browser," but this is not necessary (either option will work).
3. If your file has missing data that are coded with values other than <blank> or NA (recommended), provide the code for missingness in the box.
4. Click on the "Browse..." button and select the .csv file that contains your data.
5. When you see the "Upload complete" message, click the "Generate Scores" button.
6. A preview of the scores will be shown on the screen. To download the scores, click the "Download APPROX-CR Scores" button.