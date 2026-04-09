tuesdata <- tidytuesdayR::tt_load('2026-04-07')

# load libraries
library(tidyverse)
library(conflicted)
library(admiral)
library(polyglotr)

# conflicts
conflicts_prefer(dplyr::filter)

repairs <- as.tibble(tuesdata$repairs)
repairs_text <- as.tibble(tuesdata$repairs_text)

# Mutate part ( adding cols)
repairs <- repairs |>
  mutate(
    repair_year = year(repair_date),
    repaired = if_else(repaired == "ja", "yes", repaired)
  ) |>
  select(repair_id, repair_date, repair_year, everything())

# Update N/A to NA values to be analysed correctly
repairs_text <- repairs_text |>
  mutate(model = if_else(model == "N/A", NA_character_, model))

translate_column <- function(x, target_lang = "en") {
  non_na <- !is.na(x)
  x[non_na] <- {
    collapsed <- paste(x[non_na], collapse = " ||| ") # only collapse non-NA values
    translated <- google_translate(collapsed, target_lang)
    strsplit(translated, " \\|\\|\\| ")[[1]]
  }
  x # NAs remain as NA
}

repairs_text_new <- repairs_text |>
  mutate(across(
    .cols = where(is.character) & !c(repair_id), # only text columns and exclude repair id
    .fns = ~ translate_column(.x)
  ))


# AI approach ----------------
# Columns to skip - IDs, URLs, and categorical/flag fields
skip_cols <- c(
  "repair_id",
  "repair_info_url",
  "used_repair_info",
  "failure_reasons"
)

# Chunked translate: splits non-NA values into batches to avoid hitting
# Google Translate's character/request limits
translate_column_chunked <- function(
  x,
  target_lang = "en",
  chunk_size = 100,
  delay = 1
) {
  idx_non_na <- which(!is.na(x))

  if (length(idx_non_na) == 0) {
    return(x)
  }

  chunks <- split(idx_non_na, ceiling(seq_along(idx_non_na) / chunk_size))

  for (chunk_idx in seq_along(chunks)) {
    idx <- chunks[[chunk_idx]]
    vals <- x[idx]

    collapsed <- paste(vals, collapse = " ||| ")
    translated <- tryCatch(
      google_translate(collapsed, target_lang),
      error = function(e) {
        message(
          "Chunk ",
          chunk_idx,
          " failed: ",
          conditionMessage(e),
          " — retrying once..."
        )
        Sys.sleep(delay * 3)
        tryCatch(
          google_translate(collapsed, target_lang),
          error = function(e2) collapsed
        )
      }
    )

    parts <- strsplit(translated, " \\|\\|\\| ")[[1]]

    # Guard: if split count doesn't match, keep originals for this chunk
    if (length(parts) == length(idx)) {
      x[idx] <- parts
    } else {
      message(
        "Split mismatch in chunk ",
        chunk_idx,
        " — keeping originals for this chunk"
      )
    }

    Sys.sleep(delay)
  }

  x
}

# Identify text columns to translate
text_cols <- repairs_text |>
  select(where(is.character) & !all_of(skip_cols)) |>
  names()

message("Translating columns: ", paste(text_cols, collapse = ", "))

# Translate column by column
repairs_text_en <- repairs_text

for (col in text_cols) {
  message("\nTranslating: ", col, " ...")
  repairs_text_en[[col]] <- translate_column_chunked(repairs_text_en[[col]])
  message("Done: ", col)
}

# Verification: count remaining non-english-looking entries
# A rough check — flag entries with common non-ASCII characters
non_ascii_check <- repairs_text_en |>
  select(all_of(text_cols)) |>
  summarise(across(
    everything(),
    ~ sum(grepl("[^\x01-\x7F]", .x, perl = TRUE), na.rm = TRUE),
    .names = "non_ascii_{.col}"
  ))

non_ascii_check


# Cleaning and exploring

repairs |> distinct(repair_year) |> arrange(repair_year)

repairs |> distinct(category)
repairs |> distinct(repaired)


repairs |> filter(repaired == "half") |> View()
