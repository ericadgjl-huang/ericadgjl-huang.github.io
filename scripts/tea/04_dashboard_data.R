# 04_dashboard_data.R
# Copy the two data files the dashboard needs into dashboard/data/.
# Connect Cloud deploys only the dashboard/ folder, so its data must live there.
# Run this again whenever 02_clean_tea.R or 03_boundaries.R changes the data.

library(here)

dir.create(here("dashboard", "data"), recursive = TRUE, showWarnings = FALSE)
ok <- file.copy(
  from = here("data", "tea", c("tea_district_year.csv", "tx_districts_web.rds")),
  to   = here("dashboard", "data"),
  overwrite = TRUE
)
stopifnot("Run 02_clean_tea.R and 03_boundaries.R first" = all(ok))
message("Copied the dashboard data to ", here("dashboard", "data"))
