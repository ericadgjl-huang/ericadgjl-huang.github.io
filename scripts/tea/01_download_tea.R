# 01_download_tea.R
# Download TEA "Discipline Action Group Summary" files (report 01: counts of
# students and actions by action group) for every district, 2018-19 to 2023-24.
#
# TEA only offers the district files one education service region at a time,
# so this loops over 6 school years x 20 regions = 120 small CSV files.
# Source page:
#   https://tea.texas.gov/data-reports/student-data/discipline-data-products/discipline-action-group-summary-reports
#   ("Districts for a Selected Region", Comma-delimited File)
#
# The TEA report server is old and sometimes goes down (often at night).
# The script waits between requests, retries failed downloads, and skips files
# it already has, so you can simply run it again if it stops part way.
#
# Output: data-raw/tea/dag_<yy>_rgn<rr>.csv  (data-raw/ is in .gitignore)

library(here)

out_dir <- here("data-raw", "tea")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

base_url <- paste0(
  "https://rptsvr1.tea.texas.gov/cgi/sas/broker",
  "?_service=marykay&_program=adhoc.download_static_DAG_summary.sas",
  "&agg_level=DISTRICT&district=&referrer=Download_DAG_Region_Districts.html",
  "&test_flag=&_debug=0&report=01&report_type=csv",
  "&Download_District_Summaries_Regn=Next"
)

# school_yr code used by TEA: "19" = 2018-19, ..., "24" = 2023-24
years   <- c("19", "20", "21", "22", "23", "24")
regions <- sprintf("%02d", 1:20)

is_good_file <- function(path) {
  file.exists(path) && file.size(path) > 2000 &&
    any(grepl('^"YEAR"', readLines(path, n = 20, warn = FALSE)))
}

download_one <- function(yy, rr, tries = 5) {
  dest <- file.path(out_dir, sprintf("dag_%s_rgn%s.csv", yy, rr))
  if (is_good_file(dest)) return("already had it")
  url <- paste0(base_url, "&school_yr=", yy, "&region=", rr)
  for (i in seq_len(tries)) {
    ok <- tryCatch({
      download.file(url, dest, mode = "wb", quiet = TRUE)
      is_good_file(dest)
    }, error = function(e) FALSE)
    if (ok) return("downloaded")
    Sys.sleep(5 * i)              # wait longer after each failure
  }
  if (file.exists(dest)) file.remove(dest)
  "FAILED"
}

log <- expand.grid(region = regions, year = years, stringsAsFactors = FALSE)
log$status <- NA_character_
for (k in seq_len(nrow(log))) {
  log$status[k] <- download_one(log$year[k], log$region[k])
  message(sprintf("20%s, region %s: %s", log$year[k], log$region[k], log$status[k]))
  Sys.sleep(1.5)                  # be polite to the server
}

print(table(log$status))
if (any(log$status == "FAILED")) {
  message("Some files failed (the TEA server may be down). ",
          "Run this script again later; it will only fetch the missing files.")
} else {
  message("All 120 files are in ", out_dir)
}
