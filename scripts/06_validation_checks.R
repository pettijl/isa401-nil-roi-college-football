# 06_validation_checks.R
# Purpose: Create the required validation table for the final merged dataset.

source("scripts/00_setup.R")

final_data <- readr::read_csv("data/final/nil_roi_team_season_final.csv", show_col_types = FALSE)

validation_table <- bind_rows(
  final_data %>%
    filter(is.na(school) | school == "") %>%
    transmute(season, school, issue_type = "Missing school name", issue_detail = "School name is missing"),

  final_data %>%
    add_count(season, school_key, name = "duplicate_count") %>%
    filter(duplicate_count > 1) %>%
    transmute(season, school, issue_type = "Duplicate team-season row", issue_detail = paste("Duplicate count:", duplicate_count)),

  final_data %>%
    filter(!is.na(win_pct) & (win_pct < 0 | win_pct > 1)) %>%
    transmute(season, school, issue_type = "Invalid win percentage", issue_detail = paste("win_pct =", win_pct)),

  final_data %>%
    filter(!is.na(wins) & wins < 0) %>%
    transmute(season, school, issue_type = "Invalid wins", issue_detail = paste("wins =", wins)),

  final_data %>%
    filter(!is.na(losses) & losses < 0) %>%
    transmute(season, school, issue_type = "Invalid losses", issue_detail = paste("losses =", losses)),

  final_data %>%
    filter(is.na(team_talent_score)) %>%
    transmute(season, school, issue_type = "Missing team talent", issue_detail = "No matching team talent score after join"),

  final_data %>%
    filter(is.na(srs_rating)) %>%
    transmute(season, school, issue_type = "Missing SRS rating", issue_detail = "No matching SRS rating after join"),

  final_data %>%
    filter(total_public_nil_value == 0) %>%
    transmute(season, school, issue_type = "No public NIL valuation matched", issue_detail = "No On3 player valuation connected to this school"),

  final_data %>%
    filter(!is.na(total_public_nil_value) & total_public_nil_value < 0) %>%
    transmute(season, school, issue_type = "Invalid NIL value", issue_detail = paste("total_public_nil_value =", total_public_nil_value))
)

if (nrow(validation_table) == 0) {
  validation_table <- tibble(
    season = NA_integer_,
    school = NA_character_,
    issue_type = "No validation issues found",
    issue_detail = "All core validation checks passed"
  )
}

readr::write_csv(validation_table, "outputs/validation_table.csv")
message("Validation table saved to outputs/validation_table.csv")
