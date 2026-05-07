# 02_scrape_on3_nil.R
# Purpose: Scrape public On3 college football NIL valuation pages.
# Note: These are public valuation proxies, not verified NIL payments.

source("scripts/00_setup.R")

base_url <- "https://www.on3.com/nil/rankings/player/college/football/"
positions <- c("overall", "qb", "rb", "wr", "te", "ot", "iol", "edge", "dl", "lb", "cb", "s", "ath", "k", "p", "ls")

position_urls <- tibble(
  position_filter = positions,
  url = if_else(
    position_filter == "overall",
    base_url,
    paste0(base_url, "?position=", position_filter)
  )
)

value_to_number <- function(x) {
  x <- str_remove_all(x, "\\$|,")
  case_when(
    str_detect(x, "M$") ~ as.numeric(str_remove(x, "M$")) * 1000000,
    str_detect(x, "K$") ~ as.numeric(str_remove(x, "K$")) * 1000,
    TRUE ~ suppressWarnings(as.numeric(x))
  )
}

team_alt_to_school <- function(x) {
  x %>%
    str_remove("^Image:\\s*") %>%
    str_remove("\\s+Avatar$") %>%
    str_to_title() %>%
    str_replace_all("Crimson Tide", "Alabama") %>%
    str_replace_all("Longhorns", "Texas") %>%
    str_replace_all("Buckeyes", "Ohio State") %>%
    str_replace_all("Tigers", "LSU") %>%
    str_replace_all("Red Raiders", "Texas Tech") %>%
    str_replace_all("Ducks", "Oregon") %>%
    str_replace_all("Wolverines", "Michigan") %>%
    str_replace_all("Gamecocks", "South Carolina") %>%
    str_replace_all("Cowboys", "Oklahoma State") %>%
    str_replace_all("Panthers", "Pittsburgh") %>%
    str_replace_all("Hoosiers", "Indiana") %>%
    str_replace_all("Hurricanes", "Miami") %>%
    str_replace_all("Trojans", "USC") %>%
    str_replace_all("Golden Bears", "California") %>%
    str_replace_all("Sooners", "Oklahoma") %>%
    str_replace_all("Wolfpack", "NC State") %>%
    str_replace_all("Terrapins", "Maryland") %>%
    str_replace_all("Gators", "Florida") %>%
    str_replace_all("Bears", "Baylor") %>%
    str_replace_all("Commodores", "Vanderbilt") %>%
    str_replace_all("Rebels", "Ole Miss") %>%
    str_replace_all("Bearcats", "Cincinnati") %>%
    str_replace_all("Cyclones", "Iowa State") %>%
    str_replace_all("Hawkeyes", "Iowa") %>%
    str_replace_all("Nittany Lions", "Penn State") %>%
    str_replace_all("Aggies", "Texas A&M") %>%
    str_replace_all("Volunteers", "Tennessee") %>%
    str_replace_all("Bulldogs", "Georgia") %>%
    str_replace_all("Cardinal", "Stanford") %>%
    str_squish()
}

parse_on3_page <- function(url, position_filter) {
  message("Scraping: ", url)

  page <- tryCatch(
    rvest::read_html(url),
    error = function(e) {
      message("Could not read On3 page: ", conditionMessage(e))
      return(NULL)
    }
  )

  if (is.null(page)) {
    return(tibble())
  }

  raw_text <- rvest::html_text2(page)
  writeLines(raw_text, paste0("data/raw/on3_raw_text_", position_filter, ".txt"))

  lines <- raw_text %>%
    str_split("\\n") %>%
    .[[1]] %>%
    str_squish()

  lines <- lines[lines != ""]

  # On3 public pages usually display player entries beginning with text like "1. 1".
  rank_idx <- which(str_detect(lines, "^\\d+\\.\\s+\\d+$"))

  if (length(rank_idx) == 0) {
    rank_idx <- which(str_detect(lines, "^\\d+$"))
  }

  if (length(rank_idx) == 0) {
    message("No rank blocks found for ", position_filter, ". Saving raw text only.")
    return(tibble())
  }

  rank_idx <- rank_idx[rank_idx < length(lines)]
  end_idx <- c(rank_idx[-1] - 1, length(lines))

  position_codes <- c("QB", "RB", "WR", "TE", "OT", "IOL", "EDGE", "DL", "LB", "CB", "S", "ATH", "K", "P", "LS")

  parsed <- map2_dfr(rank_idx, end_idx, function(start_i, end_i) {
    block <- lines[start_i:end_i]

    rank <- str_extract(block[1], "^\\d+") %>% as.integer()
    pos <- block[str_detect(block, paste0("^(", paste(position_codes, collapse = "|"), ")$"))][1]
    nil_value <- block[str_detect(block, "^\\$[0-9]+(\\.[0-9]+)?[MK]?$|^\\$[0-9,]+$")][1]
    rating <- suppressWarnings(as.numeric(block[str_detect(block, "^[0-9]{2}\\.[0-9]{2}$")][1]))

    # Player name heuristic: first clean line after position that is not height/weight, school city, rating, image text, value, or social count.
    pos_line <- which(block == pos)[1]
    candidate_lines <- if (!is.na(pos_line)) block[(pos_line + 1):length(block)] else block

    player <- candidate_lines[
      !str_detect(candidate_lines, "Default Avatar|Avatar|^SR/|^JR/|^SO/|^FR/|^RS-|\\(|^\\d{2}\\.[0-9]{2}$|^\\$|^[0-9]+(\\.[0-9]+)?K$|^[0-9]+(\\.[0-9]+)?M$|^Elite$|^Commit$")
    ][1]

    # Team is hard to guarantee from raw text because On3 uses image alt text. This script creates the player-level file first;
    # school can be manually corrected in data/manual/on3_school_crosswalk.csv when needed.
    team_line <- block[str_detect(str_to_lower(block), "avatar") & !str_detect(str_to_lower(block), "default")][1]
    school_guess <- ifelse(is.na(team_line), NA_character_, team_alt_to_school(team_line))

    tibble(
      scrape_date = Sys.Date(),
      position_filter = position_filter,
      on3_rank = rank,
      player = player,
      position = pos,
      school_guess = school_guess,
      rating = rating,
      public_nil_value_text = nil_value,
      public_nil_value = value_to_number(nil_value),
      source_url = url
    )
  })

  parsed
}

on3_players <- position_urls %>%
  mutate(data = map2(url, position_filter, parse_on3_page)) %>%
  select(data) %>%
  unnest(data) %>%
  distinct(position_filter, player, position, public_nil_value, .keep_all = TRUE)

# Fallback: if school_guess is missing for many players, use manual school crosswalk.
crosswalk_path <- "data/manual/on3_school_crosswalk.csv"

if (!file.exists(crosswalk_path)) {
  on3_players %>%
    select(player, position, school_guess) %>%
    distinct() %>%
    arrange(player) %>%
    mutate(school_manual = school_guess) %>%
    readr::write_csv(crosswalk_path)

  message("Created data/manual/on3_school_crosswalk.csv. Review school_manual if school_guess is missing.")
}

school_crosswalk <- readr::read_csv(crosswalk_path, show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  mutate(school = coalesce(school_manual, school_guess))

on3_players_clean <- on3_players %>%
  left_join(school_crosswalk %>% select(player, school), by = "player") %>%
  mutate(
    school = coalesce(school, school_guess),
    season = 2025,
    source = "On3 public NIL valuation page"
  ) %>%
  filter(!is.na(player), !is.na(public_nil_value)) %>%
  distinct(player, position, school, public_nil_value, .keep_all = TRUE)

readr::write_csv(on3_players_clean, "data/raw/on3_nil_players.csv")

on3_team_summary <- on3_players_clean %>%
  filter(!is.na(school)) %>%
  group_by(season, school) %>%
  summarise(
    total_public_nil_value = sum(public_nil_value, na.rm = TRUE),
    avg_public_nil_value = mean(public_nil_value, na.rm = TRUE),
    median_public_nil_value = median(public_nil_value, na.rm = TRUE),
    top_player_nil_value = max(public_nil_value, na.rm = TRUE),
    top3_nil_value = sum(sort(public_nil_value, decreasing = TRUE)[1:min(3, n())], na.rm = TRUE),
    qb_nil_value = sum(if_else(position == "QB", public_nil_value, 0), na.rm = TRUE),
    skill_position_nil_value = sum(if_else(position %in% c("QB", "RB", "WR", "TE"), public_nil_value, 0), na.rm = TRUE),
    nil_players_counted = n_distinct(player),
    .groups = "drop"
  ) %>%
  mutate(
    qb_nil_share = if_else(total_public_nil_value > 0, qb_nil_value / total_public_nil_value, NA_real_),
    skill_position_nil_share = if_else(total_public_nil_value > 0, skill_position_nil_value / total_public_nil_value, NA_real_),
    nil_concentration = if_else(total_public_nil_value > 0, top3_nil_value / total_public_nil_value, NA_real_)
  )

readr::write_csv(on3_team_summary, "data/raw/on3_nil_team_summary.csv")

message("On3 NIL data saved to data/raw/on3_nil_players.csv and data/raw/on3_nil_team_summary.csv.")
