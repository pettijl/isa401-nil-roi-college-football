# 03_import_finance_data.R
# Purpose: Import athletics finance data from a manual download.
# Recommended source: Knight-Newhouse College Athletics Database or EADA.

source("scripts/00_setup.R")

finance_path <- "data/manual/athletics_finance_manual.csv"

if (!file.exists(finance_path)) {
  message("No finance file found. Creating a finance template at data/manual/athletics_finance_manual.csv")

  schools <- tibble()

  if (file.exists("data/raw/cfbd_records.csv")) {
    schools <- readr::read_csv("data/raw/cfbd_records.csv", show_col_types = FALSE) %>%
      janitor::clean_names() %>%
      transmute(
        season = year,
        school = team
      ) %>%
      distinct()
  }

  if (nrow(schools) == 0) {
    schools <- expand_grid(
      season = 2021:2025,
      school = c("Alabama", "Georgia", "Ohio State", "Texas", "Oregon", "Michigan", "LSU", "USC", "Miami", "Tennessee", "Texas A&M")
    )
  }

  finance_template <- schools %>%
    mutate(
      total_athletic_revenue = NA_real_,
      total_athletic_expenses = NA_real_,
      football_spending = NA_real_,
      football_coaching_salaries = NA_real_,
      donor_contributions = NA_real_,
      source = "Manual Knight-Newhouse/EADA download"
    )

  readr::write_csv(finance_template, finance_path)

  message("Fill in or replace the template with downloaded finance data, then rerun this script.")
}

finance_raw <- readr::read_csv(finance_path, show_col_types = FALSE) %>%
  janitor::clean_names()

required_cols <- c("season", "school")
missing_cols <- setdiff(required_cols, names(finance_raw))

if (length(missing_cols) > 0) {
  stop("Finance data is missing these required columns: ", paste(missing_cols, collapse = ", "))
}

finance_clean <- finance_raw %>%
  mutate(
    season = as.integer(season),
    school = str_squish(as.character(school)),
    school_key = str_to_lower(school) %>% str_replace_all("[^a-z0-9]", "")
  ) %>%
  distinct(season, school_key, .keep_all = TRUE)

readr::write_csv(finance_clean, "data/cleaned/finance_clean.csv")

message("Finance data saved to data/cleaned/finance_clean.csv")
