# Project Plan: Unequal Discipline

**Team:** Nedret Sen-Cavus · Anugraha Samuel Gloria · Eric Huang
**Course:** EPPS 6356 Data Visualization, Fall 2026 · Assignment 8, Part A

## 1. Question

**What do we want the audience to learn?** How much more often Black and Hispanic students receive discretionary discipline (in-school suspension, out-of-school suspension, and DAEP placement) than White students in the same Texas public school district, after accounting for economic disadvantage; where these gaps are largest; and how they changed before, during, and after COVID.

**Audience:** Texas education policymakers, district administrators, journalists, and parents. They are not statisticians, so every chart shows rates per enrolled student, not raw counts, and gives one clear message.

## 2. Data

| | |
|---|---|
| **Main source** | Texas Education Agency (TEA), district-level discipline data reports, school years 2018–19 to 2023–24 |
| **Spatial source** | U.S. Census Bureau, TIGER/Line Shapefiles: Texas school district boundaries (loaded in R with `tigris`, handled with `sf`) |
| **Join** | District ID crosswalk (TEA district number ↔ NCES ID) |
| **Unit of observation** | District × school year × student group × action type |
| **Time span** | Six school years: 2018–19 to 2023–24 (pre-COVID, COVID disruption 2019–21, post-COVID) |
| **Key variables** | Discipline counts (ISS, OSS, DAEP, expulsion) by race/ethnicity; enrollment by group; % economically disadvantaged; urban/rural locale; computed **discipline rate** (actions ÷ enrolled students in the group) and **relative risk ratio** (RRR = group rate ÷ White rate) |
| **Variable over time** | School year: rates and RRR for each of the six years |

Citations: Texas Education Agency, PEIMS district discipline data reports, school years 2018–19 to 2023–24; U.S. Census Bureau, TIGER/Line Shapefiles: School Districts (Texas). Exact file names and access dates will be added when the team finalizes the downloads.

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

Plan for Assignment 9: add Shiny inputs and deploy **serverless with Shinylive** on the same GitHub Pages site. Why: all our data are public, so it does not matter that Shinylive makes code and data visible; hosting is free and handles many viewers; the district-level data are small enough to bundle with the app. If a package we need is not available for webR, the fallback is Posit Connect Cloud.
