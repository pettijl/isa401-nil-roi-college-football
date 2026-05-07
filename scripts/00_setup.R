# 00_setup.R
# Purpose: install/load packages and create required folders.

packages <- c(
  "tidyverse",
  "janitor",
  "lubridate",
  "glue",
  "purrr",
  "readr",
  "stringr",
  "rvest",
  "httr",
  "cfbfastR",
  "usethis",
  "scales",
  "broom"
)

if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}

pacman::p_load(char = packages)

folders <- c(
  "data/raw",
  "data/cleaned",
  "data/final",
  "data/manual",
  "outputs",
  "outputs/summary_tables",
  "outputs/tableau_exports",
  "docs",
  "presentation",
  "tableau"
)

walk(folders, ~ dir.create(.x, recursive = TRUE, showWarnings = FALSE))

message("Setup complete. Packages loaded and folders created.")
