# Using R
# Option 1: tidytuesdayR R package
## install.packages("tidytuesdayR")

tuesdata <- tidytuesdayR::tt_load('2026-04-07')
## OR
tuesdata <- tidytuesdayR::tt_load(2026, week = 14)

repairs <- tuesdata$repairs
repairs_text <- tuesdata$repairs_text

class(repairs)
?write.table(repairs, file = here::here("2026_04_07_repair_cafes/data"))

# Option 2: Read directly from GitHub

repairs <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-04-07/repairs.csv'
)
repairs_text <- readr::read_csv(
  'https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2026/2026-04-07/repairs_text.csv'
)


repairs_text <- repairs_text |>
  # Converting one entry in german to english
  rows_update(
    repairs_text |>
      filter(repair_id == "0016_2017_0304_294") |>
      mutate(across(
        .cols = c(problem_description, repair_method),
        .fns = google_translate
      )),
    by = "repair_id"
  )

repairs_text |>
  mutate(across(.cols = everything(), .fns = google_translate)) |>
  View(title = "new_text")
