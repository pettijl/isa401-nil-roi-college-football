# Technical Process

## 1. Data Acquisition

The project uses three main sources and multiple acquisition methods.

1. CollegeFootballData is accessed through the `cfbfastR` package in R.
2. On3 NIL valuation pages are scraped with `rvest`.
3. Athletics finance data is imported from a public download from Knight-Newhouse or EADA.

## 2. Cleaning

All sources are cleaned in R using tidyverse workflows. Main cleaning steps include:

- standardizing school names
- creating `school_key` join variables
- converting ranks and valuations to numeric variables
- removing duplicate team-season rows
- converting missing values to usable flags where appropriate
- checking whether NIL values represent exact payments or public valuation proxies

## 3. Merging

The final dataset is one row per school per season. Main joins use:

```text
season + school_key
```

## 4. Main Metric

The main metric is `nil_roi_score`.

```text
nil_roi_score = actual win percentage - expected win percentage
```

Expected win percentage is estimated using a linear model based on available predictors such as roster talent, SRS, recruiting points, and public NIL value.

## 5. Validation

The validation table checks:

- missing school names
- duplicate school-season rows
- invalid win percentage
- negative wins or losses
- missing team talent data
- missing SRS data
- NIL values that did not match to a school
- invalid NIL values

## 6. Tableau Export

The final Tableau-ready dataset is exported to:

```text
outputs/tableau_exports/nil_roi_team_season_final.csv
```
