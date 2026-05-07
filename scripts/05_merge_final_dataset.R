
# 05_merge_final_dataset.R
# Purpose: Merge all cleaned sources and calculate NIL ROI metrics.

source("scripts/00_setup.R")

records <- readr::read_csv("data/cleaned/records_clean.csv", show_col_types = FALSE)

ratings <- if (file.exists("data/cleaned/ratings_clean.csv")) {
  readr::read_csv("data/cleaned/ratings_clean.csv", show_col_types = FALSE)
} else {
  tibble(season = integer(), school_key = character())
}

offense <- if (file.exists("data/cleaned/offense_clean.csv")) {
  readr::read_csv("data/cleaned/offense_clean.csv", show_col_types = FALSE)
} else {
  tibble(season = integer(), school_key = character())
}

defense <- if (file.exists("data/cleaned/defense_clean.csv")) {
  readr::read_csv("data/cleaned/defense_clean.csv", show_col_types = FALSE)
} else {
  tibble(season = integer(), school_key = character())
}

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

fix_join_keys <- function(df) {
  if (!"season" %in% names(df)) df$season <- NA_integer_
  if (!"school_key" %in% names(df)) df$school_key <- NA_character_

  df %>%
    mutate(
      season = suppressWarnings(as.integer(as.character(season))),
      school_key = as.character(school_key)
    )
}

add_missing_numeric <- function(df, cols) {
  for (col in cols) {
    if (!col %in% names(df)) df[[col]] <- NA_real_
  }
  df
}

add_missing_character <- function(df, cols) {
  for (col in cols) {
    if (!col %in% names(df)) df[[col]] <- NA_character_
  }
  df
}

records <- fix_join_keys(records)
ratings <- fix_join_keys(ratings)
offense <- fix_join_keys(offense)
defense <- fix_join_keys(defense)
nil_team <- fix_join_keys(nil_team)
finance <- fix_join_keys(finance)

records <- add_missing_character(records, c("school", "conference", "record_source"))
records <- add_missing_numeric(records, c("total_games", "wins", "losses", "win_pct"))

ratings <- add_missing_character(ratings, c("conference"))
ratings <- add_missing_numeric(ratings, c("srs_rating", "sos", "ap_pre", "ap_high", "ap_post"))

offense <- add_missing_numeric(offense, c(
  "points_per_game", "yards_per_game", "pass_yards", "rush_yards", "turnovers"
))

defense <- add_missing_numeric(defense, c(
  "points_allowed_per_game", "yards_allowed_per_game"
))

nil_team <- add_missing_numeric(nil_team, c(
  "total_public_nil_value",
  "avg_public_nil_value",
  "median_public_nil_value",
  "top_player_nil_value",
  "top3_nil_value",
  "qb_nil_value",
  "skill_position_nil_value",
  "nil_players_counted",
  "qb_nil_share",
  "skill_position_nil_share",
  "nil_concentration"
))

finance <- add_missing_numeric(finance, c(
  "total_athletic_revenue",
  "total_athletic_expenses",
  "football_spending",
  "football_coaching_salaries",
  "donor_contributions"
))

finance <- add_missing_character(finance, c("source"))

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
  left_join(
    ratings %>%
      select(any_of(c("season", "school_key", "conference", "srs_rating", "sos", "ap_pre", "ap_high", "ap_post"))),
    by = c("season", "school_key"),
    suffix = c("", "_ratings")
  ) %>%
  left_join(
    offense %>%
      select(any_of(c("season", "school_key", "points_per_game", "yards_per_game", "pass_yards", "rush_yards", "turnovers"))),
    by = c("season", "school_key")
  ) %>%
  left_join(
    defense %>%
      select(any_of(c("season", "school_key", "points_allowed_per_game", "yards_allowed_per_game"))),
    by = c("season", "school_key")
  ) %>%
  left_join(
    nil_team %>%
      select(any_of(nil_cols)),
    by = c("season", "school_key")
  ) %>%
  left_join(
    finance %>%
      select(any_of(finance_cols)),
    by = c("season", "school_key")
  )

if (!"conference" %in% names(final_data)) {
  final_data$conference <- "Unknown"
}


# Force numeric columns to numeric after all joins.
# This fixes character money fields like "$1,200,000" or text-based NIL values.
numeric_cols <- c(
  "total_games",
  "wins",
  "losses",
  "win_pct",
  "srs_rating",
  "sos",
  "ap_pre",
  "ap_high",
  "ap_post",
  "points_per_game",
  "yards_per_game",
  "pass_yards",
  "rush_yards",
  "turnovers",
  "points_allowed_per_game",
  "yards_allowed_per_game",
  "total_public_nil_value",
  "avg_public_nil_value",
  "median_public_nil_value",
  "top_player_nil_value",
  "top3_nil_value",
  "qb_nil_value",
  "skill_position_nil_value",
  "nil_players_counted",
  "qb_nil_share",
  "skill_position_nil_share",
  "nil_concentration",
  "total_athletic_revenue",
  "total_athletic_expenses",
  "football_spending",
  "football_coaching_salaries",
  "donor_contributions"
)

final_data <- final_data %>%
  mutate(
    across(
      any_of(numeric_cols),
      ~ readr::parse_number(as.character(.x))
    )
  )


final_data <- final_data %>%
  mutate(
    conference = dplyr::coalesce(as.character(conference), "Unknown"),
    total_public_nil_value = replace_na(total_public_nil_value, 0),
    avg_public_nil_value = replace_na(avg_public_nil_value, 0),
    median_public_nil_value = replace_na(median_public_nil_value, 0),
    top_player_nil_value = replace_na(top_player_nil_value, 0),
    top3_nil_value = replace_na(top3_nil_value, 0),
    qb_nil_value = replace_na(qb_nil_value, 0),
    skill_position_nil_value = replace_na(skill_position_nil_value, 0),
    nil_players_counted = replace_na(nil_players_counted, 0),
    football_spending = replace_na(football_spending, 0),
    nil_value_millions = total_public_nil_value / 1000000,
    wins_per_million_nil = if_else(nil_value_millions > 0, wins / nil_value_millions, NA_real_),
    nil_percentile = percent_rank(total_public_nil_value),
    spending_percentile = percent_rank(football_spending),
    power_conference = if_else(
      conference %in% c("ACC", "Big 12", "Big Ten", "SEC", "Pac-12"),
      "Power Conference",
      "Other FBS"
    )
  )

model_data <- final_data %>%
  filter(!is.na(win_pct))

predictor_candidates <- c(
  "srs_rating",
  "sos",
  "points_per_game",
  "points_allowed_per_game",
  "total_public_nil_value",
  "football_spending"
)

usable_predictors <- predictor_candidates[predictor_candidates %in% names(model_data)]

usable_predictors <- usable_predictors[
  map_lgl(model_data[usable_predictors], function(x) {
    x <- suppressWarnings(as.numeric(x))
    non_missing_count <- sum(!is.na(x))
    x_sd <- sd(x, na.rm = TRUE)
    non_missing_count >= 20 && !is.na(x_sd) && x_sd > 0
  })
]

if (nrow(model_data) >= 20 && length(usable_predictors) >= 1) {
  model_formula <- as.formula(paste("win_pct ~", paste(usable_predictors, collapse = " + ")))
  roi_model <- lm(model_formula, data = model_data)

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
message("Tableau-ready dataset saved to outputs/tableau_exports/nil_roi_team_season_final.csv")
