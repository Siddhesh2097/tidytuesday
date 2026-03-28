# Agents.md — Ocean Temperature Dataset Explorer

## Project Overview
Datasets: `ocean_temperature.csv` and `ocean_temperature_deployments.csv` from TidyTuesday 2026 Week 13.  
Source: Centre for Marine Applied Research (CMAR) Coastal Monitoring Program, Nova Scotia, Canada.  
Station: **Birchy Head** — fixed location (lat 44.6, lon -64.0), sensors at 7 depths, Feb 2018 – Dec 2025.  
Goal: Explore, find insights, and create visualisations from ocean temperature data.

---

## Instructions
- Use tidyverse syntax
- Add comments only where necessary
- Focus more on data analysis, finding insights, statistical part and only then move to visualisations
- Skip activating MCP extensions
- Go one question at a time — do not combine multiple questions in a single response
- Load data using `readr::read_csv()` directly from GitHub URLs (no `tt_load`, no local files)
- Always work with the session variables `ocean_temperature` and `ocean_temperature_deployments`

---

## Analysis Questions (work through in order)
s
1. **How are temperatures changing over time?**
   - Long-term annual trend (all depths combined)
   - Is the change seasonal? (month × year)
   - Is the change depth-dependent? (annual mean per depth)

2. **How does temperature change with depth?**
   - Mean temperature profile across depths
   - Does the depth–temperature relationship change over time or by season?
---

## Token Rules only when using Opus model
- Keep each response under 300 tokens
- Answer one question at a time
- Summarise before showing full code
- Warn me before any token-heavy operation
- Use sample/head of data before full dataset ops

---

❌ Avoid: "Explore everything in my dataset"
❌ Avoid: "Visualise all columns at once"
❌ Avoid: Combining 3+ questions in one prompt

---

## Data Dictionary

### `ocean_temperature`

| Variable | Type | Description |
|---|---|---|
| `date` | date | Date the temperature observations were recorded |
| `sensor_depth_at_low_tide_m` | integer | Estimated depth of the temperature sensor at low tide in metres |
| `mean_temperature_degree_c` | double | Average of the temperature observations recorded at the corresponding date and depth (°C) |
| `sd_temperature_degree_c` | double | Standard deviation of the temperature observations at the corresponding date and depth (°C) |
| `n_obs` | integer | Number of temperature observations recorded at the corresponding date and depth |

### `ocean_temperature_deployments`

| Variable | Type | Description |
|---|---|---|
| `deployment_id` | character | Unique identifier for each deployment (a set of sensors recording at one location for a given time) |
| `start_date` | date | The day the sensors were deployed |
| `end_date` | date | The day the sensors were retrieved |
| `latitude` | double | Deployment latitude (decimal degrees) |
| `longitude` | double | Deployment longitude (decimal degrees) |

### Depth levels available
`2, 5, 10, 15, 20, 30, 40` metres at low tide.

### Date range
2018-02-20 → 2025-12-06 (2,847 unique observation days, 8 years).
