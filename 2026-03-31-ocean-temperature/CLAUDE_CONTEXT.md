# CLAUDE_CONTEXT.md — Ocean Temperature Explorer
<!-- Birchy Head · Nova Scotia · TidyTuesday 2026 W13 -->
<!-- Paste this at the start of every Positron session -->

## Who I Am
Learning data analysis and visualisation using R. Intermediate level — comfortable with tidyverse but still building skills. Explain code where helpful, don't just give it.

## Project
Exploring ocean temperature data from the Centre for Marine Applied Research (CMAR) Coastal Monitoring Program, Nova Scotia, Canada.

### Datasets
- ocean_temperature             — daily temperature readings by depth
- ocean_temperature_deployments — sensor deployment metadata

### Station details
- Location  : Birchy Head (lat 44.6, lon -64.0)
- Depths    : 2, 5, 10, 15, 20, 30, 40 metres at low tide
- Date range: 2018-02-20 → 2025-12-06 (8 years, 2,847 observation days)

---

## How I Want Claude to Behave
- Use tidyverse syntax throughout
- Go one question at a time — never combine multiple steps
- Focus on analysis and statistics first, visualisations last
- Add code comments only where genuinely useful
- Do not use MCP extensions
- Always use session variables: ocean_temperature and ocean_temperature_deployments
- When using Opus: keep responses under 300 tokens and warn before heavy operations
- Give a nice bullet point explanation about the analysis for 2026_03_31_tidy_tuesday.Rmd file

## Data Dictionary

### ocean_temperature
| Variable | Type | Description |
|---|---|---|
| date | date | Date of temperature observation |
| sensor_depth_at_low_tide_m | integer | Sensor depth at low tide (metres) |
| mean_temperature_degree_c | double | Daily mean temperature (°C) |
| sd_temperature_degree_c | double | Standard deviation of observations |
| n_obs | integer | Number of observations that day |

### ocean_temperature_deployments
| Variable | Type | Description |
|---|---|---|
| deployment_id | character | Unique deployment identifier |
| start_date | date | Day sensors were deployed |
| end_date | date | Day sensors were retrieved |
| latitude | double | Decimal degrees |
| longitude | double | Decimal degrees |


## Avoid
❌ "Explore everything in my dataset"
❌ "Visualise all columns at once"
❌ Combining 3+ questions in one prompt
❌ Skipping the analysis phase and going straight to plots


