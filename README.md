# Coastal Ocean Temperature by Depth — TidyTuesday 2026 Week 13

Exploring over 7 years of daily coastal ocean temperatures at 7 depths from a
fixed monitoring station at **Birchy Head, Nova Scotia, Canada**.

Data collected through the Centre for Marine Applied Research's
[Coastal Monitoring Program](https://cmar.ca/coastal-monitoring-program/).
Related datasets can be downloaded from the
[Nova Scotia Open Data Portal](https://data.novascotia.ca/browse?tags=coastal+monitoring+program&sortBy=last_modified&pageSize=20).

> The Province of Nova Scotia recognizes the importance of coastal waters,
> which are critical to the prosperity and sustainability of rural and coastal
> communities. To bridge the gap between science and decision making, the Nova
> Scotia Department of Fisheries and Aquaculture (NSDFA) partners with the
> Centre for Marine Applied Research (CMAR) to measure the environmental
> conditions of Nova Scotia's coastal waters.

---

## Files

| File | Description |
|---|---|
| `2026_03_31_tidy_tuesday.Rmd` | Main analysis — data loading, exploration, visualisations |
| `Agents.md` | Project instructions and data dictionary |
| `curating_data.R` | Raw data cleaning script |

---

## Load the Data

```r
# Option 1: tidytuesdayR
tuesdata <- tidytuesdayR::tt_load(2026, week = 13)
ocean_temperature             <- tuesdata$ocean_temperature
ocean_temperature_deployments <- tuesdata$ocean_temperature_deployments

# Option 2: Read directly from GitHub
ocean_temperature <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-03-31/ocean_temperature.csv"
)
ocean_temperature_deployments <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-03-31/ocean_temperature_deployments.csv"
)
```

---

## Analysis Questions Explored

- How are temperatures changing over time? Is the change more pronounced at a
  different time of year or a specific depth?
- How does temperature change with depth? Does the relationship change over time?
- Are there gaps in the data, and what causes them?

---

## Data Dictionary

### `ocean_temperature`

| Variable | Type | Description |
|---|---|---|
| `date` | date | Date the temperature observations were recorded |
| `sensor_depth_at_low_tide_m` | integer | Estimated depth of the temperature sensor at low tide in metres |
| `mean_temperature_degree_c` | double | Average temperature at the corresponding date and depth (°C) |
| `sd_temperature_degree_c` | double | Standard deviation of temperature at the corresponding date and depth (°C) |
| `n_obs` | integer | Number of temperature observations recorded at the corresponding date and depth |

### `ocean_temperature_deployments`

| Variable | Type | Description |
|---|---|---|
| `deployment_id` | character | Unique identifier for each deployment |
| `start_date` | date | The day the sensors were deployed |
| `end_date` | date | The day the sensors were retrieved |
| `latitude` | double | Deployment latitude (decimal degrees) |
| `longitude` | double | Deployment longitude (decimal degrees) |

**Depth levels:** `2, 5, 10, 15, 20, 30, 40` metres at low tide  
**Date range:** 2018-02-20 → 2025-12-06 (2,847 unique observation days)

---

## Key Findings

- **No consistent long-term warming trend** — annual means oscillate between ~5.9°C and ~7.7°C over 2018–2025
- **Seasonal signal is strong** — water column is fully mixed in winter (~3–4°C at all depths), stratified in summer (surface up to 21°C, 40 m capped at ~16°C)
- **Thermal stratification peaks in autumn**, not summer — surface retains heat while deep water has already cooled
- **40 m depth is the most variable year-to-year** — likely influenced by cold bottom-water intrusions from the Gulf of St. Lawrence, not just surface forcing
- **Data gaps are deployment-driven** — 764 missing depth-days across 2019, 2022, 2023, 2024, and 2025; all gaps map exactly to named deployment periods where specific sensors were not re-deployed (`depl_02`, `depl_09`, `depl_10`, `depl_12`, `depl_14`)
- **2024 anomaly caveat** — the apparent cooling signal at depth in 2024 coincides with `depl_12` gaps at 2 m, 5 m, and 40 m simultaneously and should be interpreted with caution

---

## Acknowledgements

Thank you to [Danielle Dempsey and Rachel Woodside, Centre for Marine Applied
Research](https://github.com/dempsey-CMAR) for curating this dataset.