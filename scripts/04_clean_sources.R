# 04_clean_sources.R
# Purpose: Clean each source and create standardized join keys.

source("scripts/00_setup.R")

make_school_key <- function(x) {
  x %>%
    as.character() %>%
    str_to_lower() %>%
    str_replace_all("&", "and") %>%
    str_replace_all("university of ", "") %>%
    str_replace_all("the university of ", "") %>%
    str_replace_all("state university", "state") %>%
    str_replace_all("[^a-z0-9]", "") %>%
    str_squish()
}

clean_school_name <- function(x) {
  x %>%
    as.character() %>%
    str_remove_all("\\*") %>%
    str_remove_all("\\s+\\(.*?\\)") %>%
    str_squish()
}

get_col <- function(df, candidates, default = NA) {
  nm <- candidates[candidates %in% names(df)][1]
  if (is.na(nm)) rep(default, nrow(df)) else df[[nm]]
}

# ESPN records ------------------------------------------------------------------

if (file.exists("data/raw/espn_records.csv")) {
  records <- readr::read_csv("data/raw/espn_records.csv", show_col_types = FALSE) %>%
    janitor::clean_names() %>%
    transmute(
      season = as.integer(season),
      school = clean_school_name(school),
      school_key = make_school_key(school),
      total_games = as.numeric(total_games),
      wins = as.numeric(wins),
      losses = as.numeric(losses),
      win_pct = as.numeric(win_pct),
      record_source = "ESPN public scoreboard JSON"
    ) %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  records <- tibble()
}

# Sports Reference ratings -------------------------------------------------------

if (file.exists("data/raw/sportsref_ratings.csv")) {
  ratings_raw <- readr::read_csv("data/raw/sportsref_ratings.csv", show_col_types = FALSE) %>%
    janitor::clean_names()

  ratings <- ratings_raw %>%
    filter(!is.na(get_col(., c("school", "team")))) %>%
    transmute(
      season = as.integer(season),
      school = clean_school_name(get_col(., c("school", "team"))),
      school_key = make_school_key(school),
      conference = as.character(get_col(., c("conf", "conference"))),
      wins_sr = suppressWarnings(as.numeric(get_col(., c("w", "wins")))),
      losses_sr = suppressWarnings(as.numeric(get_col(., c("l", "losses")))),
      srs_rating = suppressWarnings(as.numeric(get_col(., c("srs")))),
      sos = suppressWarnings(as.numeric(get_col(., c("sos")))),
      ap_pre = suppressWarnings(as.numeric(get_col(., c("ap_pre", "preseason_ap")))),
      ap_high = suppressWarnings(as.numeric(get_col(., c("ap_high", "highest_ap")))),
      ap_post = suppressWarnings(as.numeric(get_col(., c("ap_post", "final_ap"))))
    ) %>%
    filter(!is.na(school), school != "School", school != "") %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  ratings <- tibble()
}

# If ESPN records are empty or incomplete, use Sports Reference W/L as fallback.
if (nrow(records) == 0 && nrow(ratings) > 0) {
  records <- ratings %>%
    transmute(
      season,
      school,
      school_key,
      total_games = wins_sr + losses_sr,
      wins = wins_sr,
      losses = losses_sr,
      win_pct = if_else(total_games > 0, wins / total_games, NA_real_),
      record_source = "Sports Reference ratings fallback"
    )
}

if (nrow(records) > 0 && nrow(ratings) > 0) {
  records <- records %>%
    left_join(ratings %>% select(season, school_key, conference, wins_sr, losses_sr), by = c("season", "school_key")) %>%
    mutate(
      conference = coalesce(conference, "Unknown"),
      wins = coalesce(wins, wins_sr),
      losses = coalesce(losses, losses_sr),
      total_games = coalesce(total_games, wins + losses),
      win_pct = coalesce(win_pct, if_else(total_games > 0, wins / total_games, NA_real_))
    ) %>%
    select(-wins_sr, -losses_sr)
}

# Sports Reference offense/defense ----------------------------------------------

if (file.exists("data/raw/sportsref_offense.csv")) {
  offense_raw <- readr::read_csv("data/raw/sportsref_offense.csv", show_col_types = FALSE) %>%
    janitor::clean_names()

  offense <- offense_raw %>%
    transmute(
      season = as.integer(season),
      school = clean_school_name(get_col(., c("school", "team"))),
      school_key = make_school_key(school),
      offense_games = suppressWarnings(as.numeric(get_col(., c("g", "games")))),
      points_for = suppressWarnings(as.numeric(get_col(., c("pts", "points")))),
      total_yards = suppressWarnings(as.numeric(get_col(., c("yds", "total_yds", "total_yards")))),
      pass_yards = suppressWarnings(as.numeric(get_col(., c("pass_yds", "passing_yds", "pass_yards")))),
      rush_yards = suppressWarnings(as.numeric(get_col(., c("rush_yds", "rushing_yds", "rush_yards")))),
      turnovers = suppressWarnings(as.numeric(get_col(., c("to", "turnovers"))))
    ) %>%
    filter(!is.na(school), school != "School", school != "") %>%
    mutate(
      points_per_game = if_else(offense_games > 0, points_for / offense_games, NA_real_),
      yards_per_game = if_else(offense_games > 0, total_yards / offense_games, NA_real_)
    ) %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  offense <- tibble()
}

if (file.exists("data/raw/sportsref_defense.csv")) {
  defense_raw <- readr::read_csv("data/raw/sportsref_defense.csv", show_col_types = FALSE) %>%
    janitor::clean_names()

  defense <- defense_raw %>%
    transmute(
      season = as.integer(season),
      school = clean_school_name(get_col(., c("school", "team"))),
      school_key = make_school_key(school),
      defense_games = suppressWarnings(as.numeric(get_col(., c("g", "games")))),
      points_allowed = suppressWarnings(as.numeric(get_col(., c("pts", "points")))),
      yards_allowed = suppressWarnings(as.numeric(get_col(., c("yds", "total_yds", "total_yards"))))
    ) %>%
    filter(!is.na(school), school != "School", school != "") %>%
    mutate(
      points_allowed_per_game = if_else(defense_games > 0, points_allowed / defense_games, NA_real_),
      yards_allowed_per_game = if_else(defense_games > 0, yards_allowed / defense_games, NA_real_)
    ) %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  defense <- tibble()
}

# On3 NIL team summary -----------------------------------------------------------

if (file.exists("data/raw/on3_nil_team_summary.csv")) {
  nil_team <- readr::read_csv("data/raw/on3_nil_team_summary.csv", show_col_types = FALSE) %>%
    janitor::clean_names() %>%
    mutate(
      season = as.integer(season),
      school = str_squish(as.character(school)),
      school_key = make_school_key(school)
    ) %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  nil_team <- tibble()
}

# Finance -----------------------------------------------------------------------

if (file.exists("data/cleaned/finance_clean.csv")) {
  finance <- readr::read_csv("data/cleaned/finance_clean.csv", show_col_types = FALSE) %>%
    janitor::clean_names() %>%
    mutate(
      season = as.integer(season),
      school_key = make_school_key(school)
    ) %>%
    distinct(season, school_key, .keep_all = TRUE)
} else {
  finance <- tibble()
}

readr::write_csv(records, "data/cleaned/records_clean.csv")
readr::write_csv(ratings, "data/cleaned/ratings_clean.csv")
readr::write_csv(offense, "data/cleaned/offense_clean.csv")
readr::write_csv(defense, "data/cleaned/defense_clean.csv")
readr::write_csv(nil_team, "data/cleaned/nil_team_clean.csv")
readr::write_csv(finance, "data/cleaned/finance_clean.csv")

message("Cleaned source files saved to data/cleaned/.")
