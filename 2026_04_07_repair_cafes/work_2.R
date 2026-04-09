tuesdata <- tidytuesdayR::tt_load('2026-04-07')

# load libraries
library(tidyverse)
library(conflicted)
library(admiral)
library(polyglotr)
library(countrycode)
library(rnaturalearth)
library(rnaturalearthdata)
library(plotly)

# conflicts
conflicts_prefer(dplyr::filter)

repairs <- as_tibble(tuesdata$repairs) |> convert_blanks_to_na()
repairs_text <- as_tibble(tuesdata$repairs_text) |> convert_blanks_to_na()

# Mutate part ( adding cols)
repairs <- repairs |>
  mutate(
    repair_year = as.factor(year(repair_date)),
    repaired = if_else(repaired == "ja", "yes", repaired),
    # Get country , continent , country flags with countrycode package
    country_name = countrycode(
      country,
      origin = "iso2c",
      destination = "country.name"
    ),
    country_flag = countrycode(
      country,
      origin = "iso2c",
      destination = "unicode.symbol"
    ),
    continent = countrycode(
      country,
      origin = "iso2c",
      destination = "continent"
    )
  ) |>
  select(repair_id, repair_date, repair_year, everything())

# Update N/A to NA values to be analysed correctly
repairs_text <- repairs_text |>
  mutate(model = if_else(model == "N/A", NA_character_, model))

#No of cafes growth each year ------------------------------------------------------
repairs |>
  group_by(repair_year) |>
  summarise(N_cafes = n_distinct(repair_cafe_name)) |>
  # mutate(repair_year = as.factor(repair_year)) |>
  ggplot(
    mapping = aes(x = repair_year, y = N_cafes)
  ) +
  geom_bar(stat = "identity")

# Create a map to mark where all the cafes are located
# --- Step 1: Count cafes per country from your data ---
cafe_counts <- repairs |>
  group_by(country_name) |>
  summarise(num_cafes = n_distinct(repair_cafe_name), .groups = "drop") |>
  arrange(desc(num_cafes))

cafe_counts <- cafe_counts |>
  mutate(
    country_name = case_when(
      country_name == "United States" ~ "United States of America",
      country_name == "French Guiana" ~ "French Guiana", # part of France in rnaturalearth, may stay unmatched
      country_name == "Hong Kong SAR China" ~ "Hong Kong",
      TRUE ~ country_name
    )
  )

# --- Step 2: Get world map polygons ---
world <- ne_countries(scale = "medium", returnclass = "sf")

# --- Step 3: Join your cafe counts to the map data ---
world_cafes <- world |>
  left_join(cafe_counts, by = c("name" = "country_name"))

# --- Step 4: Plot ---
ggplot(world_cafes) +
  geom_sf(aes(fill = num_cafes), color = "white", linewidth = 0.2) +
  geom_sf_text(
    data = world_cafes |> filter(!is.na(num_cafes)), # only countries with cafes
    aes(label = iso_a2),
    size = 2.5,
    color = "white",
    fontface = "bold"
  ) +
  scale_fill_viridis_c(
    option = "plasma",
    na.value = "grey85", # countries with no cafes appear grey
    name = "Number of Cafes"
  ) +
  labs(
    title = "Cafe Locations Around the World",
    subtitle = "By country"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "bottom"
  )

## Plotly ----------------------------------------------------------------------------

# --- Step 1: Add a text column for the tooltip BEFORE plotting ---
world_cafes_plotly <- world_cafes
world_cafes_plotly <- world_cafes_plotly |>
  mutate(
    tooltip_text = case_when(
      !is.na(num_cafes) ~ paste0(name, "\nCafes: ", num_cafes),
      TRUE ~ paste0(name, "\nNo cafes in data")
    )
  )

# --- Step 2: Build ggplot with aes(text = ...) for tooltip ---
p <- ggplot(world_cafes_plotly) +
  geom_sf(aes(fill = num_cafes), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(
    option = "plasma",
    na.value = "grey85",
    name = "Number of Cafes"
  ) +
  labs(
    title = "Cafe Locations Around the World",
    subtitle = "By country",
    caption = "Source: Your dataset"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "bottom"
  )

# Pass tooltip separately in ggplotly
ggplotly(p, tooltip = "fill") |>
  style(
    hovertemplate = paste0(
      world_cafes_plotly$country_name,
      "<br>",
      "Cafes: ",
      ifelse(
        is.na(world_cafes_plotly$num_cafes),
        "No data",
        world_cafes_plotly$num_cafes
      ),
      "<extra></extra>" # hides the trace name box
    )
  )

# Which category was repaired the most ----

repaired_count_long <- repairs |>
  # drop any rows with missing category
  filter_out(is.na(category) | is.na(repaired)) |>
  group_by(repair_year, category, repaired) |>
  summarise(repaired_status = n(), .groups = "drop") |>
  mutate(repaired = factor(repaired, levels = c("yes", "half", "no")))

repaired_count_wide <- repaired_count_long |>
  pivot_wider(
    id_cols = c(repair_year, category),
    names_from = repaired,
    values_from = repaired_status
  )

electric_non_electric <- repaired_count_long |>
  filter(grepl("electric", category))

# check each electric and non one by one

plot_rep_st_category <- function(data, title) {
  p <- ggplot(
    data,
    aes(x = factor(repair_year), y = repaired_status, fill = repaired)
  ) +
    geom_col(position = "dodge") + # side-by-side bars, not stacked
    scale_fill_manual(
      values = c("yes" = "#2ecc71", "half" = "#f39c12", "no" = "#e74c3c"),
      name = "Repair Status"
    ) +
    facet_wrap(~category, ncol = 2) +
    labs(
      title = title,
      x = "Year",
      y = "Number of Products"
    ) +
    theme_minimal() +
    theme(
      strip.text = element_text(face = "bold", size = 8),
      axis.text.x = element_text(angle = 90, hjust = 1, size = 6),
      legend.position = "bottom",
      panel.spacing = unit(0.8, "lines")
    )

  return(p)
}

plot_rep_st_household <- plot_rep_st_category(
  data = electric_non_electric |> filter(grepl("Household", category)),
  title = "Status for household appliances by electric/non over years"
)

plot_rep_st_tools <- plot_rep_st_category(
  data = electric_non_electric |> filter(grepl("Tools", category)),
  title = "Status for tools by electric/non over years"
)

plot_rep_st_toys <- plot_rep_st_category(
  data = electric_non_electric |> filter(grepl("Toys", category)),
  title = "Status for toys by electric/non over years"
)

# Categories without considering years ----
category_repair_long <- repairs |>
  # drop any rows with missing category
  filter_out(is.na(category) | is.na(repaired)) |>
  group_by(category, repaired) |>
  summarise(status_count = n(), .groups = "drop") |>
  mutate(repaired = factor(repaired, levels = c("yes", "half", "no")))

# update category labels ( shorten it , much better)
# use dplyr new function recode_values
category_lookup <- tibble(
  category = repairs |>
    filter_out(is.na(category)) |>
    distinct(category) |>
    arrange(category) |>
    pull(),
  short_cat = c(
    "Bicycles",
    "Clocks",
    "Comp equi/phones",
    "Dis/sound",
    "Furn",
    "HA_elec",
    "HA_non",
    "Jew",
    "Oth",
    "Textile",
    "Tools_elec",
    "Tools_non",
    "Toys_elec",
    "Toys_non"
  )
)

# Update the categories using the above lookup table
category_repair_long <- category_repair_long |>
  mutate(
    short_cat = recode_values(
      category_repair_long$category,
      from = category_lookup$category,
      to = category_lookup$short_cat
    )
  )

plot_category_count <- ggplot(
  category_repair_long,
  aes(x = short_cat, y = status_count, fill = repaired)
) +
  geom_col(position = "dodge") + # side-by-side bars, not stacked
  scale_fill_manual(
    values = c("yes" = "#2ecc71", "half" = "#f39c12", "no" = "#e74c3c"),
    name = "Repair Status"
  ) +
  labs(
    title = "",
    x = "Category",
    y = "Number of Products"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold", size = 8),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    legend.position = "right",
    panel.spacing = unit(0.8, "lines")
  )


# repairs |>
#   group_by(continent) |>
#   summarise(N_cafes_in_continent = n_distinct(repair_cafe_name), .groups = "drop") |>
#   arrange(desc(N_cafes_in_continent))

# repairs |>
#   group_by(continent, country_name) |>
#   summarise(N_cafes_in_country = n_distinct(repair_cafe_name), .groups = "drop") |>
#   arrange(continent, desc(N_cafes_in_country))

# AI approach ----------------
# Columns to skip - IDs, URLs, and categorical/flag fields
skip_cols <- c(
  "repair_id",
  "repair_info_url",
  "used_repair_info",
  "failure_reasons"
)

# Cleaning and exploring

repairs |> distinct(repair_year) |> arrange(repair_year)

repairs |> distinct(category)
repairs |> distinct(repaired)


repairs |> filter(repaired == "half") |> View()
