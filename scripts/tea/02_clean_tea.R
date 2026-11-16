# 02_clean_tea.R
# Read the 120 TEA files from 01_download_tea.R and build two tidy tables.
#
#   data/tea/tea_discipline_long.csv
#       one row = district x school year x student group x action type
#   data/tea/tea_district_year.csv
#       one row = district x school year, with the rates and risk ratios we map
#
# Definitions (see data/tea/README.md for the full notes):
#   enrolled  = TEA "NUMBER OF STUDENTS": students in the group during the year
#   students  = students in the group with at least one action of that type
#   actions   = number of actions (one student can have several)
#   risk_pct  = students / enrolled x 100   (share of the group disciplined)
#   rrr       = risk_pct of Black (or Hispanic) students / risk_pct of White students
#   -999 in TEA files = masked for privacy (FERPA) -> NA here, never zero.

library(tidyverse)
library(here)

raw_dir <- here("data-raw", "tea")
out_dir <- here("data", "tea")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- 1. Read one TEA file ------------------------------------------------------
# Each file has a short title block, a header line starting with "YEAR",
# the data rows, then a blank line and footnotes.
read_tea_file <- function(path) {
  lines <- readLines(path, warn = FALSE, encoding = "latin1")
  hi    <- grep('^"YEAR"', lines)[1]
  end   <- which(lines[(hi + 1):length(lines)] == "")[1]
  body  <- lines[hi:(hi + end - 1)]
  read_csv(I(body), col_types = cols(.default = col_double(),
                                     YEAR = col_character(),
                                     DISTRICT = col_character(),
                                     DISTNAME = col_character(),
                                     CHARTER_STATUS = col_character(),
                                     `STUDENT GROUP` = col_character()),
           na = character()) |>
    mutate(school_yr = str_extract(basename(path), "(?<=dag_)\\d{2}"))
}

files <- list.files(raw_dir, pattern = "^dag_\\d{2}_rgn\\d{2}\\.csv$", full.names = TRUE)
stopifnot("Run 01_download_tea.R first: no files in data-raw/tea" = length(files) > 0)
if (length(files) < 120) warning(length(files), " of 120 files found; some years or regions are missing.")

raw <- map(files, read_tea_file) |> list_rbind()

# ---- 2. Tidy: one row per district x year x group x action ---------------------
group_labels <- c(
  "ALL STUDENTS"                  = "All students",
  "AMERICAN INDIAN OR ALASKA NAT" = "American Indian",
  "ASIAN"                         = "Asian",
  "BLACK OR AFRICAN AMERICAN"     = "Black",
  "HISPANIC/LATINO"               = "Hispanic",
  "NATIVE HAWAIIAN/OTHER PACIFIC" = "Pacific Islander",
  "TWO OR MORE RACES"             = "Two or more races",
  "WHITE"                         = "White",
  "FEMALE"                        = "Female",
  "MALE"                          = "Male",
  "SPECIAL ED."                   = "Special education",
  "ECON. DIS."                    = "Economically disadvantaged",
  "AT RISK"                       = "At risk"
)

long <- raw |>
  transmute(
    year_start = 2000L + as.integer(school_yr) - 1L,
    school_year = sprintf("%d-%02d", year_start, (year_start + 1) %% 100),
    region = as.integer(REGION),
    district = str_pad(DISTRICT, 6, pad = "0"),
    distname_raw = DISTNAME,
    charter = if_else(str_detect(CHARTER_STATUS, "CHARTER"), "Charter", "Traditional ISD"),
    group = unname(group_labels[`STUDENT GROUP`]),
    enrolled = `NUMBER OF STUDENTS`,
    across(matches("^(ISS|OSS|DAEP|JJAEP|EXPUL) (ACTIONS|STUDENTS)$"))
  ) |>
  pivot_longer(matches("^(ISS|OSS|DAEP|JJAEP|EXPUL) "),
               names_to = c("action", ".value"), names_sep = " ") |>
  rename(actions = ACTIONS, students = STUDENTS) |>
  mutate(
    enrolled_masked = enrolled == -999,
    count_masked    = students == -999 | actions == -999,
    across(c(enrolled, actions, students), \(x) na_if(x, -999)),
    risk_pct        = if_else(enrolled > 0, 100 * students / enrolled, NA_real_),
    actions_per_100 = if_else(enrolled > 0, 100 * actions / enrolled, NA_real_)
  )

if (anyNA(long$group)) stop("Unknown student group label in TEA files: ",
                            paste(unique(raw$`STUDENT GROUP`[!raw$`STUDENT GROUP` %in% names(group_labels)]), collapse = ", "))

# Older files cut district names at 34 characters; use each district's latest name
latest_names <- long |>
  slice_max(year_start, by = district, with_ties = FALSE) |>
  select(district, distname = distname_raw)
long <- long |> left_join(latest_names, by = "district") |> select(-distname_raw) |>
  relocate(distname, .after = district)

# Compressed, rounded to 3 decimals: about 5 MB instead of 44 MB.
# read_csv("data/tea/tea_discipline_long.csv.gz") reads it directly.
long <- long |> mutate(across(c(risk_pct, actions_per_100), \(x) round(x, 3)))
write_csv(long, file.path(out_dir, "tea_discipline_long.csv.gz"))
old_csv <- file.path(out_dir, "tea_discipline_long.csv")   # earlier uncompressed version
if (file.exists(old_csv)) file.remove(old_csv)

# ---- 3. District x year table with risk ratios --------------------------------
min_n <- 30   # a risk ratio is flagged unreliable if either group has < 30 students

enrol <- long |>
  filter(action == "OSS") |>                       # enrolment repeats for every action
  select(district, year_start, group, enrolled) |>
  pivot_wider(names_from = group, values_from = enrolled) |>
  transmute(district, year_start,
            enrolled_all     = `All students`,
            pct_econ_dis     = 100 * `Economically disadvantaged` / `All students`,
            pct_black        = 100 * Black    / `All students`,
            pct_hispanic     = 100 * Hispanic / `All students`,
            pct_white        = 100 * White    / `All students`,
            n_black = Black, n_hispanic = Hispanic, n_white = White)

risk <- long |>
  filter(action %in% c("ISS", "OSS", "DAEP"),
         group %in% c("All students", "Black", "Hispanic", "White")) |>
  mutate(group = recode(group, "All students" = "all", Black = "black",
                        Hispanic = "hispanic", White = "white")) |>
  select(district, year_start, action, group, risk_pct) |>
  pivot_wider(names_from = group, values_from = risk_pct, names_prefix = "risk_")

district_year <- long |>
  distinct(district, distname, region, charter, year_start, school_year) |>
  left_join(enrol, by = c("district", "year_start")) |>
  left_join(risk,  by = c("district", "year_start"), relationship = "one-to-many") |>
  mutate(
    rrr_black    = if_else(risk_white > 0, risk_black    / risk_white, NA_real_),
    rrr_hispanic = if_else(risk_white > 0, risk_hispanic / risk_white, NA_real_),
    rrr_black_reliable    = coalesce(!is.na(rrr_black)    & n_black    >= min_n & n_white >= min_n, FALSE),
    rrr_hispanic_reliable = coalesce(!is.na(rrr_hispanic) & n_hispanic >= min_n & n_white >= min_n, FALSE),
    covid_period = case_when(year_start <= 2018 ~ "Pre-COVID",
                             year_start <= 2020 ~ "COVID disruption",
                             TRUE               ~ "Post-COVID")
  ) |>
  arrange(district, year_start, action) |>
  mutate(across(where(is.double) & !c(year_start, region, enrolled_all, n_black, n_hispanic, n_white),
                \(x) round(x, 3)))

write_csv(district_year, file.path(out_dir, "tea_district_year.csv"))

# ---- 4. Quick checks to report to the team ------------------------------------
cat("\nRows in long table:", nrow(long),
    "\nDistricts per school year:\n")
print(count(distinct(long, district, school_year, charter), school_year, charter) |>
        pivot_wider(names_from = charter, values_from = n))

cat("\nShare of district-years with a usable Black/White OSS risk ratio:\n")
district_year |>
  filter(action == "OSS") |>
  summarise(any_value = mean(!is.na(rrr_black)),
            reliable  = mean(rrr_black_reliable), .by = school_year) |>
  print()

cat("\nMedian Black/White and Hispanic/White OSS risk ratio (reliable districts only):\n")
district_year |>
  filter(action == "OSS") |>
  summarise(median_rrr_black    = median(rrr_black[rrr_black_reliable]),
            median_rrr_hispanic = median(rrr_hispanic[rrr_hispanic_reliable]),
            .by = school_year) |>
  print()
