# TEA discipline data: Texas school districts, 2018-19 to 2023-24

Prepared by Eric Huang for the *Unequal Discipline* team project (EPPS 6356).

## How to rebuild the data

Run the three scripts in `scripts/tea/` in order from the project root:

| Script | What it does | Output |
|---|---|---|
| `01_download_tea.R` | Downloads 120 TEA files (6 school years x 20 regions). The TEA server is sometimes down, often at night. If some files fail, run it again; it fetches only the missing ones. | `data-raw/tea/*.csv` (not in Git) |
| `02_clean_tea.R` | Combines the files, turns masked cells into `NA`, and computes rates and risk ratios | `data/tea/tea_discipline_long.csv.gz`, `data/tea/tea_district_year.csv` |
| `03_boundaries.R` | Downloads the 2023-24 district boundaries with the TEA district number | `data/tea/tx_districts.gpkg`, `data/tea/tx_districts_web.rds` |

## Sources

- **Discipline:** Texas Education Agency, *Discipline Action Group Summary Reports*, report 01 "Counts of Students and Disciplinary Actions by Disciplinary Action Groups", district level, school years 2018-19 to 2023-24. <https://tea.texas.gov/data-reports/student-data/discipline-data-products/discipline-action-group-summary-reports>
- **Boundaries:** National Center for Education Statistics (NCES), EDGE *School District Characteristics 2023-24*. The boundaries come from the Census TIGER/Line 2024 file. The `ST_LEAID` field holds the TEA district number, so we can join without a crosswalk. <https://data-nces.opendata.arcgis.com/datasets/nces::school-district-characteristics-2023-24>

## The two tables

**`tea_discipline_long.csv.gz`** (compressed; `readr::read_csv()` opens it directly): one row per district x school year x student group x action type.

| Column | Meaning |
|---|---|
| `district` | TEA 6-digit district number (text; keep the leading zeros) |
| `school_year`, `year_start` | for example `2023-24` and `2023` |
| `charter` | `Traditional ISD` or `Charter` |
| `group` | All students, Black, Hispanic, White, Asian, American Indian, Pacific Islander, Two or more races, Female, Male, Special education, Economically disadvantaged, At risk |
| `action` | `ISS`, `OSS`, `DAEP`, `JJAEP`, `EXPUL` |
| `enrolled` | students in the group that year (the denominator) |
| `students` | students in the group with at least one action of this type |
| `actions` | number of actions (one student can have several) |
| `risk_pct` | `students / enrolled x 100`: the percentage of the group that received this action |
| `actions_per_100` | `actions / enrolled x 100` |
| `enrolled_masked`, `count_masked` | `TRUE` where TEA masked the number |

**`tea_district_year.csv`**: one row per district x school year x action (ISS, OSS, DAEP), ready for maps and charts.

| Column | Meaning |
|---|---|
| `enrolled_all`, `pct_econ_dis`, `pct_black`, `pct_hispanic`, `pct_white` | district size and composition |
| `risk_all`, `risk_black`, `risk_hispanic`, `risk_white` | `risk_pct` for each group |
| `rrr_black`, `rrr_hispanic` | **relative risk ratio** = group risk / White risk (1 = parity, 2 = twice as likely) |
| `rrr_black_reliable`, `rrr_hispanic_reliable` | `TRUE` only if both groups have at least 30 students and no number is masked |
| `covid_period` | Pre-COVID (2018-19), COVID disruption (2019-20, 2020-21), Post-COVID (2021-22 on) |

## Decisions the team should confirm

1. **Risk ratio uses students, not actions.** Our PLAN.md defines the rate as actions / enrolled. I computed the RRR from *students with at least one action*, because that is the usual definition of disproportionality risk (a student suspended five times counts once). `actions_per_100` is also in the long table if we prefer the PLAN version.
2. **Discretionary vs. mandatory.** Report 01 counts *all* ISS, OSS and DAEP actions; it does not split them by reason. TEA's report 04 gives actions by reason. If we need the discretionary-only numbers for H1, that is a next step.
3. **Reliability rule.** RRRs are flagged unreliable below 30 students in either group. Small districts swing a lot, so maps should grey out unreliable values rather than colour them.

## Known limitations

- **Masking:** TEA masks small counts (`-999`) under FERPA. They are `NA` here, never zero. Many small districts therefore have no RRR, especially for Black students in rural districts.
- **Charters:** charter networks (`charter == "Charter"`) have no geographic boundary. They stay in the tables but cannot be mapped.
- **Boundaries are from 2023-24.** A few districts that merged or closed earlier in the period may not match. `maps.qmd` lists the unmatched districts.
- **2019-20** ended early because of COVID school closures, so its counts cover only part of the year.
