# Project Plan: Unequal Discipline

**Team:** Nedret Sen-Cavus · Anugraha Samuel Gloria · Eric Huang
**Course:** EPPS 6356 Data Visualization, Fall 2026 · Assignment 8, Part A (updated for Assignment 9, Part A: see the last section)

## 1. Question

**What do we want the audience to learn?** How much more often Black and Hispanic students receive discretionary discipline (in-school suspension, out-of-school suspension, and DAEP placement) than White students in the same Texas public school district, after accounting for economic disadvantage; where these gaps are largest; and how they changed before, during, and after COVID.

**Audience:** Texas education policymakers, district administrators, journalists, and parents. They are not statisticians, so every chart shows rates per enrolled student, not raw counts, and gives one clear message.

## 2. Data

| | |
|---|---|
| **Main source** | Texas Education Agency (TEA), district-level discipline data reports, school years 2018–19 to 2023–24 |
| **Spatial source** | NCES EDGE, *School District Characteristics 2023–24*: Texas school district boundaries built from the Census TIGER/Line 2024 file (read in R with `sf`) |
| **Join** | TEA 6-digit district number. The NCES file stores it in `ST_LEAID` (`TX-057905` → `057905`), so no separate crosswalk is needed |
| **Unit of observation** | District × school year × student group × action type |
| **Time span** | Six school years: 2018–19 to 2023–24 (pre-COVID, COVID disruption 2019–21, post-COVID) |
| **Key variables** | Discipline counts (ISS, OSS, DAEP, expulsion) by race/ethnicity; enrollment by group; % economically disadvantaged; urban/rural locale; computed **discipline risk** (students with at least one action ÷ enrolled students in the group; actions per 100 students are also kept) and **relative risk ratio** (RRR = group risk ÷ White risk) |
| **Variable over time** | School year: rates and RRR for each of the six years |

Citations: Texas Education Agency, *Discipline Action Group Summary Reports*, report 01 “Counts of Students and Disciplinary Actions by Disciplinary Action Groups”, district level, school years 2018–19 to 2023–24, <https://tea.texas.gov/data-reports/student-data/discipline-data-products/discipline-action-group-summary-reports>, accessed November 16, 2026. National Center for Education Statistics, EDGE *School District Characteristics 2023–24* (boundaries from Census TIGER/Line 2024), <https://data-nces.opendata.arcgis.com/datasets/nces::school-district-characteristics-2023-24>, accessed November 16, 2026. Download and cleaning code: `scripts/tea/`; data notes: `data/tea/README.md`.

Known issues: small counts are masked by TEA for privacy (they are flagged, never treated as zero); charter networks have no map boundary (kept in tables, left off the map).

## 3. Charts

Numbers refer to Abela's *Chart Suggestions—A Thought-Starter* as numbered in the course handouts.

| # | Chart | Abela # | Why it fits |
|---|---|---|---|
| A | **Risk-ratio dot plot:** RRR by student group and action type, with interval bars, on a log scale with a line at parity (1.0) | #3 Bar chart (Comparison, among many items), drawn as dots | Position on a common scale is the most accurate way to compare groups (Cleveland & McGill), and the log scale makes 0.5× and 2× equally far from parity. |
| B | **District choropleth:** RRR across Texas districts with a perceptually uniform diverging palette | — (maps are not in the Thought-Starter) | Shows where the gaps are concentrated and whether neighboring districts look alike (spatial dependency). |
| C | **Trend chart:** discipline rate by student group, 2018–19 to 2023–24, with the COVID years shaded | #6 Line chart (Comparison, over time) | Several student groups over six school years: one line per group shows the pre/post-COVID change and keeps the groups comparable. |
| D | **Model counterfactuals:** predicted probability of discipline by group with simulated uncertainty intervals | #4 Column chart (Comparison, among few items), drawn as points with intervals | A few groups compared on one scale; showing the adjusted gap as intervals instead of a regression table (King et al.). |
| E | **District table:** searchable table of every district, including charter networks, with a small trend line per row | #2 Table with embedded charts (Comparison, many categories) | About 1,200 districts are too many for one chart; a table lets readers find their own district. |

## 4. Interaction

Users can:

- **Select** a district (search box), a school year, a student group, and an action type (ISS, OSS, or DAEP).
- **Hover** over a district, dot, or point to see the rate, the RRR, the raw count, the enrollment (the denominator), and whether the value is masked.
- **Compare** one district against the statewide rate, and pre-COVID years against post-COVID years.
- **Sort and search** a table of all districts, including charter networks that are not on the map.

## 5. Deployment

**Quarto dashboard on the GitHub Pages website** for Assignment 8 (static page; interactivity from htmlwidgets: `plotly`, `leaflet`, `DT`).

~~Plan for Assignment 9: deploy serverless with Shinylive.~~ **Changed for Assignment 9:** the dashboard stays a Quarto dashboard and becomes reactive with `server: shiny`, so it is deployed to **Posit Connect Cloud** and embedded in the website with an `<iframe>`. Why: Assignment 9 accepts Shinylive only for a bslib app (route 2) whose packages, `sf` included, all load in webR; a Quarto dashboard with `server: shiny` needs a real R server. Connect Cloud is free for public apps and redeploys from our GitHub repository.

## Assignment 9. Spatial plan

### 1. Units and boundaries

One row of the map is **one Texas school district** (a traditional independent school district, ISD), 1,018 districts in 2023–24. The boundaries come from the **NCES EDGE file *School District Characteristics 2023–24***, whose polygons are the Census TIGER/Line 2024 school district boundaries (`scripts/tea/03_boundaries.R`). The **join key is the TEA 6-digit district number**: TEA reports it as `DISTRICT`, and the NCES file stores it in `ST_LEAID` (`TX-057905` → `057905`).

All 1,018 boundaries match a TEA district. Three TEA districts and every charter network (about 185 a year) have no boundary, so they stay in the tables and are left off the map: South Texas ISD (a regional magnet district that overlaps other districts), Texas Tech University K-12 and University of Texas at Austin High School (both online schools).

### 2. Variables

| Variable | Map type | Kind | Units |
|---|---|---|---|
| **Black/White relative risk ratio** for out-of-school suspension (OSS), 2023–24 | Choropleth (diverging, centred on 1) | Index: ratio of two risks | “times as likely”; 1 = parity, 2 = Black students twice as likely as White students |
| Hispanic/White relative risk ratio (OSS, ISS or DAEP) | Choropleth (dashboard option) | Index | “times as likely” |
| **Risk for all students**: share of students with at least one OSS (or ISS, DAEP) | Choropleth (sequential) | Rate | % of enrolled students |
| **Students who received OSS**, 2023–24 | Proportional symbols | Count | students |

A risk ratio is shown only where both groups have at least 30 students and TEA did not mask a number. Districts without a reliable value are drawn in neutral grey with their own legend entry (“No reliable ratio”). This leaves about 230 districts with a Black/White OSS ratio, but they enroll 85% of the Black students in Texas.

### 3. Coordinate reference systems

| Use | CRS | Why |
|---|---|---|
| Storage | **EPSG:4326** (WGS 84, longitude/latitude) | The boundaries arrive in it, and it is what Leaflet expects as input. |
| Static maps | **EPSG:3083** (NAD83 / Texas Centric Albers Equal Area) | An equal-area projection centred on Texas, so large West Texas districts are not exaggerated and area comparisons are fair. |
| Interactive map | **EPSG:3857** (Web Mercator) | Leaflet draws its tiles in Web Mercator and reprojects our EPSG:4326 polygons itself. |

### 4. Interaction

Inputs that change the reactive map:

- **Measure:** Black/White risk ratio, Hispanic/White risk ratio, or risk for all students
- **Action type:** OSS, ISS or DAEP
- **School year:** 2018–19 to 2023–24 (slider)
- **Locale:** all districts, or only city, suburban, town or rural districts

One shared `reactive()` holds the filtered `sf` data. It feeds the Leaflet map and these other outputs:

- **Value boxes:** districts with a reliable value (out of the districts shown); the median of the selected measure; the share of the group's students who live in districts with a reliable value
- **Companion chart:** the 10 districts with the highest value of the selected measure, with their enrollment, so readers can see whether the extremes are large or small districts
- **Popups:** district name, the selected value, both group risks and both enrollments (the denominators)
