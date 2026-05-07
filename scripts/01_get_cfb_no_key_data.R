# 01_get_cfb_no_key_data.R
# Purpose: Pull no-key college football performance data.
# Sources:
#   1. ESPN public scoreboard JSON endpoint (no API key)
#   2. Sports Reference college football ratings/offense/defense pages

source("scripts/00_setup.R")

seasons <- 2021:2025
weeks <- 1:16

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || all(is.na(x))) y else x
}

safe_get_json <- function(url) {
  tryCatch({
    resp <- httr::GET(url, httr::user_agent("Mozilla/5.0 ISA401 student analytics project"))
    httr::stop_for_status(resp)
    txt <- httr::content(resp, as = "text", encoding = "UTF-8")
    jsonlite::fromJSON(txt, simplifyVector = FALSE)
  }, error = function(e) {
    message("JSON pull failed: ", conditionMessage(e))
    NULL
  })
}

parse_espn_event <- function(event, season, week, seasontype) {
  completed <- event$status$type$completed %||% FALSE
  competition <- event$competitions[[1]] %||% NULL

  if (is.null(competition) || length(competition$competitors) < 2) {
    return(tibble())
  }

  map_dfr(competition$competitors, function(comp) {
    tibble(
      season = season,
      week = week,
      seasontype = seasontype,
      event_id = event$id %||% NA_character_,
      game_date = event$date %||% NA_character_,
      completed = completed,
      school = comp$team$displayName %||% comp$team$shortDisplayName %||% NA_character_,
      school_abbrev = comp$team$abbreviation %||% NA_character_,
      home_away = comp$homeAway %||% NA_character_,
      score = suppressWarnings(as.numeric(comp$score %||% NA_character_)),
      winner = as.logical(comp$winner %||% FALSE)
    )
  })
}

pull_espn_week <- function(season, week, seasontype = 2) {
  url <- glue::glue(
    "https://site.api.espn.com/apis/site/v2/sports/football/college-football/scoreboard?dates={season}&week={week}&seasontype={seasontype}&groups=80&limit=1000"
  )
  message("Pulling ESPN scoreboard: season ", season, ", week ", week)

  dat <- safe_get_json(url)
  if (is.null(dat) || is.null(dat$events) || length(dat$events) == 0) {
    return(tibble())
  }

  map_dfr(dat$events, parse_espn_event, season = season, week = week, seasontype = seasontype)
}

espn_games <- crossing(season = seasons, week = weeks) %>%
  mutate(data = map2(season, week, pull_espn_week)) %>%
  select(data) %>%
  unnest(data) %>%
  distinct(season, week, event_id, school, .keep_all = TRUE)

espn_records <- espn_games %>%
  filter(completed == TRUE, !is.na(school)) %>%
  group_by(season, school) %>%
  summarise(
    total_games = n_distinct(event_id),
    wins = sum(winner == TRUE, na.rm = TRUE),
    losses = total_games - wins,
    win_pct = if_else(total_games > 0, wins / total_games, NA_real_),
    .groups = "drop"
  )

readr::write_csv(espn_games, "data/raw/espn_team_games.csv")
readr::write_csv(espn_records, "data/raw/espn_records.csv")

message("ESPN no-key scoreboard data saved.")

# Sports Reference scrape helpers ------------------------------------------------

read_sr_tables <- function(url) {
  tryCatch({
    page <- rvest::read_html(url)

    # Sports Reference often places tables in HTML comments. This removes comment wrappers if needed.
    page_text <- as.character(page) %>%
      str_replace_all("<!--", "") %>%
      str_replace_all("-->", "")

    page2 <- rvest::read_html(page_text)
    tables <- page2 %>%
      rvest::html_elements("table") %>%
      rvest::html_table(fill = TRUE)

    if (length(tables) == 0) tibble() else tables[[1]] %>% as_tibble()
  }, error = function(e) {
    message("Sports Reference scrape failed for ", url, ": ", conditionMessage(e))
    tibble()
  })
}

pull_sr_page <- function(season, page_name) {
  url <- glue::glue("https://www.sports-reference.com/cfb/years/{season}-{page_name}.html")
  message("Scraping Sports Reference: ", url)

  read_sr_tables(url) %>%
    janitor::clean_names() %>%
    mutate(season = season, source_url = as.character(url))
}

sportsref_ratings <- map_dfr(seasons, pull_sr_page, page_name = "ratings")
sportsref_offense <- map_dfr(seasons, pull_sr_page, page_name = "team-offense")
sportsref_defense <- map_dfr(seasons, pull_sr_page, page_name = "team-defense")

readr::write_csv(sportsref_ratings, "data/raw/sportsref_ratings.csv")
readr::write_csv(sportsref_offense, "data/raw/sportsref_offense.csv")
readr::write_csv(sportsref_defense, "data/raw/sportsref_defense.csv")

message("Sports Reference data saved to data/raw/.")
message("No CFBD API key needed for this version.")
