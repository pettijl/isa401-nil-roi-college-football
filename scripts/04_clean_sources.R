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

records <- readr::read_csv("data/raw/cfbd_records.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  transmute(
    season = year,
    school = team,
    school_key = make_school_key(team),
    conference,
    classification,
    total_games,
    wins = total_wins,
    losses = total_losses,
    expected_wins_cfbd = expected_wins,
    win_pct = if_else(total_games > 0, total_wins / total_games, NA_real_)
  ) %>%
  filter(classification == "fbs" | is.na(classification)) %>%
  distinct(season, school_key, .keep_all = TRUE)

talent <- readr::read_csv("data/raw/cfbd_team_talent.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  transmute(
    season = year,
    school = school,
    school_key = make_school_key(school),
    team_talent_score = talent
  ) %>%
  distinct(season, school_key, .keep_all = TRUE)

recruiting <- readr::read_csv("data/raw/cfbd_recruiting.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  transmute(
    season = year,
    school = team,
    school_key = make_school_key(team),
    recruiting_rank = rank,
    recruiting_points = as.numeric(points)
  ) %>%
  distinct(season, school_key, .keep_all = TRUE)

srs <- readr::read_csv("data/raw/cfbd_srs.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  transmute(
    season = year,
    school = team,
    school_key = make_school_key(team),
    srs_rating = rating,
    srs_ranking = ranking
  ) %>%
  distinct(season, school_key, .keep_all = TRUE)

team_stats <- readr::read_csv("data/raw/cfbd_team_stats.csv", show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  transmute(
    season,
    school = team,
    school_key = make_school_key(team),
    stat_games = games,
    pass_ypa,
    rush_ypc,
    total_yds,
    turnovers,
    turnovers_pg,
    third_conv_rate,
    penalties_pg
  ) %>%
  distinct(season, school_key, .keep_all = TRUE)

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
readr::write_csv(talent, "data/cleaned/talent_clean.csv")
readr::write_csv(recruiting, "data/cleaned/recruiting_clean.csv")
readr::write_csv(srs, "data/cleaned/srs_clean.csv")
readr::write_csv(team_stats, "data/cleaned/team_stats_clean.csv")
readr::write_csv(nil_team, "data/cleaned/nil_team_clean.csv")
readr::write_csv(finance, "data/cleaned/finance_clean.csv")

message("Cleaned source files saved to data/cleaned/.")
