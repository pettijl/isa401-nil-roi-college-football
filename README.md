# NIL ROI in College Football: Are Programs Converting Player Investment Into Wins?

## Project Overview

This project studies whether college football programs are converting player investment into on-field success in the NIL era.

Actual NIL payments are private and incomplete, so this project does **not** claim to measure exact NIL spending. Instead, it uses public NIL valuation data, athletic department spending data, recruiting/team talent data, and performance metrics as proxies for player investment and program resources.

## Business Problem

NIL has changed college football by making roster construction more financially driven. Donors, collectives, and athletic departments now have to decide where player-related money should go: star players, quarterbacks, skill positions, overall roster depth, coaching, or broader program investment. This project helps evaluate which programs appear to generate the strongest football return from those resources.

## Research Question

**In the NIL era, which college football programs are generating the best on-field return from player investment, and does success appear to come more from star-player value, quarterback value, or broader roster talent?**

## Data Sources

| Source | What it provides | Acquisition method |
|---|---|---|
| On3 NIL Valuations | Public NIL valuation proxy by player, school, and position | Web scraping / structured extraction |
| CollegeFootballData via cfbfastR | Team records, talent scores, recruiting ranks, SRS, team stats | API |
| Knight-Newhouse / EADA athletics finance | Football spending and athletic department resources | Public download / import |

## Technical Workflow

All core data work is done in R.

1. Pull football performance, recruiting, and talent data from CollegeFootballData.
2. Scrape or structure public NIL valuation data from On3.
3. Import athletics finance data from Knight-Newhouse/EADA.
4. Clean school names and standardize join keys.
5. Merge sources into one team-season dataset.
6. Create NIL investment and ROI metrics.
7. Build validation checks for duplicates, missing values, impossible values, and failed joins.
8. Export final CSVs for Tableau.

## Important Methodology Note

The NIL variables in this project are **public valuation proxies**, not verified payments. On3's deal tracker states that financial deal terms are private, so the project uses NIL valuation as a proxy for market/player value rather than exact NIL spending.

## Folder Structure

```text
isa401-nil-roi-college-football/
├── README.md
├── .gitignore
├── isa401-nil-roi-college-football.Rproj
├── scripts/
│   ├── 00_setup.R
│   ├── 01_get_cfbd_data.R
│   ├── 02_scrape_on3_nil.R
│   ├── 03_import_finance_data.R
│   ├── 04_clean_sources.R
│   ├── 05_merge_final_dataset.R
│   ├── 06_validation_checks.R
│   ├── 07_summary_outputs.R
│   └── 99_run_all.R
├── data/
│   ├── raw/
│   ├── cleaned/
│   ├── final/
│   └── manual/
├── outputs/
│   ├── summary_tables/
│   └── tableau_exports/
├── docs/
│   ├── data_dictionary.md
│   ├── source_notes.md
│   ├── technical_process.md
│   └── limitations.md
├── presentation/
│   ├── in_class_presentation_script.md
│   └── technical_video_script.md
└── tableau/
    └── storyboard_layout.md
```

## How to Run

### Step 1: Install packages

Open the R project, then run:

```r
source("scripts/00_setup.R")
```

### Step 2: Add your ESPN public scoreboard JSON + Sports Reference key

Run this once in RStudio:

```r
usethis::edit_r_environ()
```

Add this line, replacing the placeholder:

```r
CFBD_API_KEY=your_key_here
```

Save the file, then restart RStudio.

### Step 3: Run the full project pipeline

```r
source("scripts/99_run_all.R")
```

## Final Outputs

The main Tableau file is:

```text
data/final/nil_roi_team_season_final.csv
```

The validation table is:

```text
outputs/validation_table.csv
```

Summary tables for Tableau are saved in:

```text
outputs/summary_tables/
```

## Main Dashboard Metrics

| Metric | Meaning |
|---|---|
| `total_public_nil_value` | Sum of public NIL valuations by team |
| `top_player_nil_value` | Highest public NIL valuation on a team |
| `top3_nil_value` | Sum of the top 3 NIL valuations on a team |
| `qb_nil_value` | Total public NIL value tied to quarterbacks |
| `qb_nil_share` | Quarterback NIL value divided by total team NIL value |
| `nil_concentration` | Top 3 NIL value divided by total team NIL value |
| `wins_per_million_nil` | Wins divided by public NIL value in millions |
| `expected_win_pct` | Model-predicted win percentage |
| `nil_roi_score` | Actual win percentage minus expected win percentage |
| `roi_group` | High ROI, Expected ROI, or Low ROI |



