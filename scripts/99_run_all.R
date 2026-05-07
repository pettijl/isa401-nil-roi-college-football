# 99_run_all.R
# Purpose: Run the full project pipeline in order.

source("scripts/00_setup.R")
source("scripts/01_get_cfbd_data.R")
source("scripts/02_scrape_on3_nil.R")
source("scripts/03_import_finance_data.R")
source("scripts/04_clean_sources.R")
source("scripts/05_merge_final_dataset.R")
source("scripts/06_validation_checks.R")
source("scripts/07_summary_outputs.R")

message("Full NIL ROI pipeline complete.")
