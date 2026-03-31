# Coastal Ocean Temperature by Depth — TidyTuesday 2026 Week 13

Exploring over 7 years of daily coastal ocean temperatures at 7 depths from a
fixed monitoring station at **Nova Scotia, Canada**.

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

## Load the Data

```r
tuesdata <- tidytuesdayR::tt_load(2026, week = 13)
ocean_temperature             <- tuesdata$ocean_temperature
ocean_temperature_deployments <- tuesdata$ocean_temperature_deployments
```

---

For more details:
https://github.com/rfordatascience/tidytuesday/blob/main/data/2026/2026-03-31/readme.md