# 05_merge_final_dataset.R
# Purpose: Merge all cleaned sources and calculate NIL ROI metrics.

source("scripts/00_setup.R")

records <- readr::read_csv("data/cleaned/records_clean.csv", show_col_types = FALSE)
talent <- readr::read_csv("data/cleaned/talent_clean.csv", show_col_types = FALSE)
recruiting <- readr::read_csv("data/cleaned/recruiting_clean.csv", show_col_types = FALSE)
srs <- readr::read_csv("data/cleaned/srs_clean.csv", show_col_types = FALSE)
team_stats <- readr::read_csv("data/cleaned/team_stats_clean.csv", show_col_types = FALSE)

nil_team <- if (file.exists("data/cleaned/nil_team_clean.csv")) {
  readr::read_csv("data/cleaned/nil_team_clean.csv", show_col_types = FALSE)
} else {
  tibble(season = integer(), school_key = character())
}

finance <- if (file.exists("data/cleaned/finance_clean.csv")) {
  readr::read_csv("data/cleaned/finance_clean.csv", show_col_types = FALSE)
} else {
  tibble(season = integer(), school_key = character())
}

nil_cols <- c(
  "season", "school_key", "total_public_nil_value", "avg_public_nil_value", "median_public_nil_value",
  "top_player_nil_value", "top3_nil_value", "qb_nil_value", "skill_position_nil_value",
  "nil_players_counted", "qb_nil_share", "skill_position_nil_share", "nil_concentration"
)

finance_cols <- c(
  "season", "school_key", "total_athletic_revenue", "total_athletic_expenses", "football_spending",
  "football_coaching_salaries", "donor_contributions", "source"
)

final_data <- records %>%
  left_join(talent %>% select(season, school_key, team_talent_score), by = c("season", "school_key")) %>%
  left_join(recruiting %>% select(season, school_key, recruiting_rank, recruiting_points), by = c("season", "school_key")) %>%
  left_join(srs %>% select(season, school_key, srs_rating, srs_ranking), by = c("season", "school_key")) %>%
  left_join(team_stats %>% select(season, school_key, stat_games, pass_ypa, rush_ypc, total_yds, turnovers, turnovers_pg, third_conv_rate, penalties_pg), by = c("season", "school_key")) %>%
  left_join(nil_team %>% select(any_of(nil_cols)), by = c("season", "school_key")) %>%
  left_join(finance %>% select(any_of(finance_cols)), by = c("season", "school_key")) %>%
  mutate(
    total_public_nil_value = replace_na(total_public_nil_value, 0),
    avg_public_nil_value = replace_na(avg_public_nil_value, 0),
    median_public_nil_value = replace_na(median_public_nil_value, 0),
    top_player_nil_value = replace_na(top_player_nil_value, 0),
    top3_nil_value = replace_na(top3_nil_value, 0),
    qb_nil_value = replace_na(qb_nil_value, 0),
    skill_position_nil_value = replace_na(skill_position_nil_value, 0),
    nil_players_counted = replace_na(nil_players_counted, 0),
    nil_value_millions = total_public_nil_value / 1000000,
    wins_per_million_nil = if_else(nil_value_millions > 0, wins / nil_value_millions, NA_real_),
    talent_percentile = percent_rank(team_talent_score),
    nil_percentile = percent_rank(total_public_nil_value),
    spending_percentile = percent_rank(football_spending),
    power_conference = if_else(conference %in% c("ACC", "Big 12", "Big Ten", "SEC", "Pac-12"), "Power Conference", "Other FBS")
  )

model_data <- final_data %>%
  filter(!is.na(win_pct), !is.na(team_talent_score), !is.na(srs_rating))

if (nrow(model_data) >= 20) {
  roi_model <- lm(win_pct ~ team_talent_score + srs_rating + total_public_nil_value + recruiting_points, data = model_data)
  model_summary <- broom::tidy(roi_model)
  readr::write_csv(model_summary, "outputs/roi_model_summary.csv")

  final_data <- final_data %>%
    mutate(
      expected_win_pct = predict(roi_model, newdata = final_data),
      expected_win_pct = pmin(pmax(expected_win_pct, 0), 1),
      nil_roi_score = win_pct - expected_win_pct,
      roi_group = case_when(
        nil_roi_score >= 0.10 ~ "High ROI / Overperformer",
        nil_roi_score <= -0.10 ~ "Low ROI / Underperformer",
        TRUE ~ "Expected Range"
      )
    )
} else {
  final_data <- final_data %>%
    mutate(
      expected_win_pct = NA_real_,
      nil_roi_score = NA_real_,
      roi_group = "Not enough model data"
    )
}

final_data <- final_data %>%
  arrange(desc(season), desc(nil_roi_score), school)

readr::write_csv(final_data, "data/final/nil_roi_team_season_final.csv")
readr::write_csv(final_data, "outputs/tableau_exports/nil_roi_team_season_final.csv")

message("Final merged dataset saved to data/final/nil_roi_team_season_final.csv")
