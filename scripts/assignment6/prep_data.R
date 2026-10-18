# =============================================================
# prep_data.R — turn the HPI 2026 Excel file into a tidy CSV for the app
# Run once from the course project folder (where HPI.xlsx is):
#   source("assignment/assignment6/app_own/prep_data.R")
# The app itself only reads hpi_panel.csv, so it does not need readxl
# and the Excel file does not have to be deployed.
# =============================================================

library(readxl)

xlsx_path <- if (file.exists("HPI.xlsx")) "HPI.xlsx" else "../../../HPI.xlsx"
out_path  <- if (dir.exists("assignment/assignment6/app_own"))
  "assignment/assignment6/app_own/hpi_panel.csv" else "hpi_panel.csv"

# "All Data" sheet: one row per country and year; row 1 holds source notes
raw <- suppressWarnings(read_excel(xlsx_path, sheet = "All Data", skip = 1))

# Continent codes 1–8, in the order used by the "Cont data" sheet
regions <- c("Latin America", "N America & Oceania", "Western Europe",
             "Middle East & N. Africa", "Africa", "South Asia",
             "Eastern Europe & Central Asia", "East Asia")

num <- function(x) suppressWarnings(as.numeric(x))

hpi <- data.frame(
  country    = raw$Country,
  iso        = raw$ISO,
  region     = regions[num(raw$Continent)],
  year       = as.integer(num(raw$Year)),
  population = num(raw$Population),             # thousands
  life_exp   = num(raw$`Life Expectancy`),      # years
  life_sat   = num(raw$`Life Satisfaction`),    # 0–10 ladder
  footprint  = num(raw$`Ecological Footprint`), # global hectares per person
  # PPP, constant 2021 $; the "cleaned" column carries 2024 GDP into 2025
  gdp_pc     = num(raw$`GDP per capita (cleaned) - 2024 used for 2025`),
  hpi        = num(raw$HPI)
)

# Keep country-years that have an HPI score
hpi <- hpi[!is.na(hpi$hpi) & !is.na(hpi$country) & !is.na(hpi$region), ]
hpi <- hpi[order(hpi$country, hpi$year), ]

write.csv(hpi, out_path, row.names = FALSE)
message("Wrote ", nrow(hpi), " rows (", length(unique(hpi$country)),
        " countries, ", min(hpi$year), "–", max(hpi$year), ") to ", out_path)
