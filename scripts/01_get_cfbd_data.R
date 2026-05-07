# 01_get_cfbd_data.R
# Purpose: Pull team performance, recruiting, team talent, SRS, and team stats from CollegeFootballData.

source("scripts/00_setup.R")

seasons <- 2021:2025

if (!cfbfastR::has_cfbd_key()) {
  stop("No CFBD API key found. Run usethis::edit_r_environ() and add CFBD_API_KEY=your_key_here, then restart RStudio.")
}

safe_pull <- function(fun, ...) {
  tryCatch(
    fun(...),
    error = function(e) {
      message("Pull failed: ", conditionMessage(e))
      tibble()
    }
  )
}

message("Pulling CollegeFootballData records...")
cfbd_records <- map_dfr(seasons, ~ safe_pull(cfbfastR::cfbd_game_records, year = .x)) %>%
  janitor::clean_names()

message("Pulling team talent data...")
cfbd_talent <- map_dfr(seasons, ~ safe_pull(cfbfastR::cfbd_team_talent, year = .x)) %>%
  janitor::clean_names()

message("Pulling recruiting team rankings...")
cfbd_recruiting <- map_dfr(seasons, ~ safe_pull(cfbfastR::cfbd_recruiting_team, year = .x)) %>%
  janitor::clean_names()

message("Pulling SRS ratings...")
cfbd_srs <- map_dfr(seasons, ~ safe_pull(cfbfastR::cfbd_ratings_srs, year = .x)) %>%
  janitor::clean_names()

message("Pulling season team stats...")
cfbd_team_stats <- map_dfr(seasons, ~ safe_pull(cfbfastR::cfbd_stats_season_team, year = .x)) %>%
  janitor::clean_names()

readr::write_csv(cfbd_records, "data/raw/cfbd_records.csv")
readr::write_csv(cfbd_talent, "data/raw/cfbd_team_talent.csv")
readr::write_csv(cfbd_recruiting, "data/raw/cfbd_recruiting.csv")
readr::write_csv(cfbd_srs, "data/raw/cfbd_srs.csv")
readr::write_csv(cfbd_team_stats, "data/raw/cfbd_team_stats.csv")

message("CFBD data saved to data/raw/.")
