# Reproduction scope

## Fully supported route

The portable, tested route begins with `data/derived/analysis_input_936.csv` and `data/derived/subcode_analysis_input_3744.csv`. These are de-identified aggregate inputs. `Rscript run_all.R all` regenerates the core model results, sensitivity analyses, annual standardized rates and figures, then compares key estimates with frozen references.

This is the appropriate public GitHub route because it exposes the scientific transformations and inferential calculations without redistributing record-level mortality files.

## Source-data figure route

Publication figures are regenerated from the frozen v9 `Figure*_source.csv` tables. Image binaries are not expected to be byte-identical across operating systems because fonts, Cairo and raster devices differ. Numerical source data, panel membership and labels are the reproducible objects.

## Raw-to-aggregate route

The original project also parsed official NCHS and Brazil SIM record-level files and used deterministic country-year caches. Those caches total approximately 10.8 GB and are excluded. Rebuilding the aggregate input requires downloading the official files, applying the frozen residency, age, sex and representation definitions, and validating the 936-stratum closure. Source routes and required checks are documented in `RAW_DATA_REBUILD.md`.

The current public package is therefore **one-command reproducible from analysis-ready aggregate inputs**, but not a one-command downloader/parser for every raw national file. This boundary should be stated in the manuscript Data and Code Availability section.
