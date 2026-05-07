# 07_summary_outputs.R
# Purpose: Create summary tables for Tableau and presentation talking points.

source("scripts/00_setup.R")

final_data <- readr::read_csv("data/final/nil_roi_team_season_final.csv", show_col_types = FALSE)

latest_season <- max(final_data$season, na.rm = TRUE)

top_roi <- final_data %>%
  filter(season == latest_season, !is.na(nil_roi_score)) %>%
  arrange(desc(nil_roi_score)) %>%
  slice_head(n = 20)

low_roi <- final_data %>%
  filter(season == latest_season, !is.na(nil_roi_score)) %>%
  arrange(nil_roi_score) %>%
  slice_head(n = 20)

nil_market_leaders <- final_data %>%
  filter(season == latest_season) %>%
  arrange(desc(total_public_nil_value)) %>%
  slice_head(n = 25)

conference_summary <- final_data %>%
  group_by(season, conference) %>%
  summarise(
    teams = n_distinct(school),
    avg_win_pct = mean(win_pct, na.rm = TRUE),
    avg_team_talent_score = mean(team_talent_score, na.rm = TRUE),
    avg_public_nil_value = mean(total_public_nil_value, na.rm = TRUE),
    total_public_nil_value = sum(total_public_nil_value, na.rm = TRUE),
    avg_nil_roi_score = mean(nil_roi_score, na.rm = TRUE),
    .groups = "drop"
  )

team_trends <- final_data %>%
  select(season, school, conference, wins, losses, win_pct, team_talent_score, total_public_nil_value, nil_roi_score, roi_group)

readr::write_csv(top_roi, "outputs/summary_tables/top_roi_programs.csv")
readr::write_csv(low_roi, "outputs/summary_tables/low_roi_programs.csv")
readr::write_csv(nil_market_leaders, "outputs/summary_tables/nil_market_leaders.csv")
readr::write_csv(conference_summary, "outputs/summary_tables/conference_summary.csv")
readr::write_csv(team_trends, "outputs/summary_tables/team_trends.csv")

message("Summary outputs saved to outputs/summary_tables/.")
