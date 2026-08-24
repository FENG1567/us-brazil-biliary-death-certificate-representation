# US-Brazil biliary death-certificate representation study

This repository is the public reproducibility package for:

> **How released death-certificate representations change US-Brazil contrasts in recorded biliary conditions: a two-system measurement study, 2012-2024**

It reproduces the main aggregate analyses of ICD-10 K80-K83 records in the United States and Brazil from de-identified country-year-age-sex counts. It also contains the frozen source data used for the final v9 tables and figures.

## What can be reproduced

The default route starts from the 936-row aggregate input and reproduces:

- the stacked Poisson model with HC1 covariance clustered by original country-year-age-sex stratum;
- WHO 2000-2025 age-, equal-sex- and equal-year-standardized rates;
- Brazil/US representation rate ratios and ratios of rate ratios;
- target-population and flexible mean-structure sensitivity analyses;
- the 2,000-draw Rademacher cluster multiplier bootstrap;
- conditional UCD-fraction support analyses;
- K80, K81, K82 and K83 component models from the 3,744-row aggregate component input;
- annual direct standardized rates with the paper's Poisson counting log intervals;
- publication figures from their frozen source-data tables; and
- numerical comparison of the reproduced primary and component estimates with the frozen reference results.

The repository does **not** redistribute US or Brazilian record-level death files, the approximately 10.8 GB interruption-recovery caches, or local audit and peer-review materials. See [raw-data reconstruction](docs/RAW_DATA_REBUILD.md) for the official acquisition routes and definitions.

## Code availability

The public repository is [FENG1567/us-brazil-biliary-death-certificate-representation](https://github.com/FENG1567/us-brazil-biliary-death-certificate-representation). It contains the analysis code, de-identified aggregate country-year-age-sex inputs, dictionaries, frozen figure and table source data, `renv.lock`, SHA-256 checksums and the reproduction report. The primary reproducibility route starts from the aggregate inputs. Record-level US and Brazilian mortality files are not redistributed, and suppressed 1–9 cells are not reconstructed or back-calculated. See [the manuscript-ready Code Availability statement](docs/CODE_AVAILABILITY.md) for the acquisition routes, redistribution boundaries and DOI status.

## Quick start

The locked analysis environment used R 4.3.1. From a fresh checkout:

```r
install.packages("renv")
renv::restore()
```

Then run:

```sh
Rscript run_all.R all
```

Individual routes are also available:

```sh
Rscript run_all.R analysis
Rscript run_all.R figures
Rscript run_all.R verify
```

Generated files are written only to `results/generated/`, `figures/generated/` and `logs/`. Frozen inputs and reference results are never overwritten.

## Repository map

| Path | Purpose |
|---|---|
| `R/` | Portable aggregate-analysis, figure and verification scripts |
| `data/derived/` | De-identified aggregate analysis inputs |
| `data/metadata/` | Dictionaries, WHO weights, crosswalk and source ledgers |
| `data/source_data/` | Frozen supplementary/source-data CSV files |
| `results/reference/` | Frozen reference results used for numerical verification |
| `figures/reference/` | Final v9 figure previews, PDFs, legends, metadata and source CSVs |
| `tables/source/` | Source-precision and display CSV files for Tables 1-2 |
| `docs/` | Reproduction scope, data availability and raw-data instructions |
| `config/source_registry.csv` | Public source URLs, coverage and redistribution status |

## Verification standard

`R/03_verify_reproduction.R` compares the regenerated primary standardized rates, primary contrasts and three-character component contrasts with frozen reference outputs at an absolute tolerance of `1e-8`. It also checks required outputs and hard gates. Device- and font-dependent figure binaries are not hash-compared; their aggregate source tables are frozen and supplied.

## Data and interpretation boundaries

`any_common` is a study label for the closest available country-specific certificate-source representation: UCD or entity-axis mention in the US, and UCD or a saved certificate-line mention in Brazil. It is not a claim of semantic equivalence, disease burden, causal attribution or certificate quality. Model and bootstrap intervals are conditional on released counts and do not include national certification, coding, registration or release-system measurement error.

No suppressed cell of 1-9 was reverse engineered. The public aggregate inputs contain no direct identifiers or certificate text.

## Licensing and citation

Original repository code is offered under the MIT License; source agencies retain all rights in their data and documentation. See [DATA_LICENSE.md](DATA_LICENSE.md) before redistributing data files. Citation metadata are in [CITATION.cff](CITATION.cff).

The repository is publicly available at <https://github.com/FENG1567/us-brazil-biliary-death-certificate-representation>. No Zenodo DOI has been assigned. See [docs/CODE_AVAILABILITY.md](docs/CODE_AVAILABILITY.md) for the manuscript-ready statement.
