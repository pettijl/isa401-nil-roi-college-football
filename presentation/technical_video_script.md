# Technical Video Script

## 1. Project Overview

> This project studies whether college football programs are converting player investment into on-field success in the NIL era.

## 2. Research Question

> The main question is: which college football programs are generating the best on-field return from player investment, and does success appear to come more from star-player value, quarterback value, or broader roster talent?

## 3. Why the Question Matters

> NIL has changed college football by making roster construction more financially driven. Because actual NIL payments are private, there is no perfect public source showing exactly how much each program spends. Our project uses public proxies to evaluate the connection between player value, program resources, and team performance.

## 4. Data Sources

Explain:

1. On3 public NIL valuation pages
2. CollegeFootballData through cfbfastR
3. Knight-Newhouse or EADA athletics finance data

## 5. Acquisition Methods

Explain:

- API access using `cfbfastR`
- Web scraping using `rvest`
- Public data download / import for finance data

## 6. R Workflow

Walk through these scripts:

```text
00_setup.R
01_get_cfbd_data.R
02_scrape_on3_nil.R
03_import_finance_data.R
04_clean_sources.R
05_merge_final_dataset.R
06_validation_checks.R
07_summary_outputs.R
99_run_all.R
```

## 7. Cleaning

Explain:

- school names were standardized
- `school_key` was created for joining
- NIL valuation text was converted into numeric dollar values
- team-season duplicates were removed
- missing values were checked

## 8. Merging

> The final dataset has one row per team-season. The main join key is season plus standardized school name.

## 9. Validation

Show the validation table and explain:

- duplicate checks
- invalid win percentage checks
- failed join checks
- missing NIL valuation checks

## 10. Final Dataset

Show the final dataset and explain the major variable groups:

- team information
- performance metrics
- talent/recruiting metrics
- NIL valuation proxy metrics
- finance proxy metrics
- ROI metrics

## 11. Novelty

> The novelty of this project is that we did not just download one complete dataset. We combined NIL valuation data, football performance data, recruiting data, and athletics finance data into a new dataset designed to answer a current business problem in college football.

## 12. Limitations

Say:

> The biggest limitation is that actual NIL payments are private. On3 valuation is a proxy, not a confirmed payment amount. Also, football performance is affected by many factors, so the model shows relationships rather than proving causation.
