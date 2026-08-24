# Compact codebook

## Aggregate primary input

`data/derived/analysis_input_936.csv` has one row per country, year, age group and sex.

| Variable | Definition |
|---|---|
| `country` | `US` or `BR`; national release system |
| `year` | Calendar year of death, 2012-2024 |
| `age_group` | WHO18 five-year group from `0-4` through `85+` |
| `sex` | Recorded binary sex, `F` or `M` |
| `population` | Official population denominator |
| `ucd` | K80-K83 underlying-cause deaths |
| `any_common` | Country-specific source representation: US UCD/entity-axis; Brazil UCD/saved certificate line |
| `alternative` | US UCD/record-axis structural sensitivity; equals `any_common` in Brazil |

## Component input

`data/derived/subcode_analysis_input_3744.csv` adds `subcode` (`K80`, `K81`, `K82`, `K83`) and contains aggregate `ucd` and `any_common` counts. Subcode mentions are non-mutually exclusive; summing across K80-K83 is not a unique death count.

Full dictionaries and the field-level crosswalk are in `data/metadata/`.
