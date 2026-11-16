# 03_boundaries.R
# Texas school district boundaries, 2023-24, with the TEA district number.
#
# Source: NCES EDGE, "School District Characteristics 2023-24"
#   https://data-nces.opendata.arcgis.com/datasets/nces::school-district-characteristics-2023-24
#   Boundaries come from the Census TIGER/Line 2024 school district file;
#   the attributes come from the 2023-24 Common Core of Data (CCD).
# Why this file: its ST_LEAID field holds the TEA district number
# ("TX-057905" -> "057905"), so it joins to the TEA discipline data directly,
# with no separate crosswalk. It also has the NCES urban/rural locale.
# Charter networks have no boundary, so they are not in this file.
#
# Output:
#   data/tea/tx_districts.gpkg        full detail, EPSG:4326 (for static maps)
#   data/tea/tx_districts_web.rds     simplified, EPSG:4326 (for the Leaflet map)

library(tidyverse)
library(sf)
library(here)

out_dir <- here("data", "tea")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

query <- paste0(
  "https://nces.ed.gov/opengis/rest/services/School_District_Boundaries/",
  "EDGE_ADMINDATA_SCHOOLDISTRICTS_SY2324/MapServer/1/query",
  "?where=", URLencode("LEAID LIKE '48%'", reserved = TRUE),
  "&outFields=LEAID,ST_LEAID,LEA_NAME,LOCALE_TEXT,CONAME",
  "&outSR=4326&f=geojson"
)

tx <- st_read(query, quiet = TRUE) |>
  transmute(
    district   = str_remove(ST_LEAID, "^TX-"),    # TEA 6-digit district number
    nces_id    = LEAID,
    nces_name  = LEA_NAME,
    county     = CONAME,
    locale     = str_remove(LOCALE_TEXT, "^\\d+-"),
    locale_type = str_extract(locale, "^[A-Za-z]+")  # City / Suburb / Town / Rural
  ) |>
  st_make_valid()

stopifnot("Expected about 1,000 Texas districts" = nrow(tx) > 900,
          "TEA district numbers should be 6 digits" = all(str_detect(tx$district, "^\\d{6}$")))
message(nrow(tx), " Texas school districts downloaded.")

st_write(tx, file.path(out_dir, "tx_districts.gpkg"), delete_dsn = TRUE, quiet = TRUE)

# Lighter copy for the web map: simplify in Texas Centric Albers (metres),
# keeping detail down to about 300 m, then go back to longitude/latitude.
tx_web <- tx |>
  st_transform(3083) |>
  st_simplify(dTolerance = 300, preserveTopology = TRUE) |>
  st_make_valid() |>
  st_transform(4326)
saveRDS(tx_web, file.path(out_dir, "tx_districts_web.rds"))

message(sprintf("Saved. Full file %.1f MB; web file %.1f MB.",
                file.size(file.path(out_dir, "tx_districts.gpkg")) / 1e6,
                file.size(file.path(out_dir, "tx_districts_web.rds")) / 1e6))
