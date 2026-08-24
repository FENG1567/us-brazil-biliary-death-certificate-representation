# Code availability

## Manuscript-ready statement

> Code, de-identified aggregate inputs, variable dictionaries, frozen figure and table source data, the `renv.lock` environment specification, SHA-256 checksums, and the reproduction report are publicly available at <https://github.com/FENG1567/us-brazil-biliary-death-certificate-representation>. Record-level US and Brazilian mortality data are not redistributed. Users who need to rebuild the aggregates must obtain the source data from CDC/NCHS and CDC WONDER for the United States, SIM/OpenDataSUS/DATASUS for Brazil, and population denominators from the US Census Bureau and IBGE, subject to the agencies' current access terms. The primary reproducibility route begins with de-identified country-year-age-sex aggregates. It does not reconstruct or back-calculate suppressed 1–9 cells. No Zenodo DOI has been assigned.

## Public contents

The repository makes the following reproducibility materials available:

- R scripts for aggregate analysis, figure construction and verification;
- de-identified country-year-age-sex aggregate inputs, including the 936-row primary input and the 3,744-row component input;
- variable dictionaries, field crosswalks, source ledgers and WHO standardization weights;
- frozen figure and table source data and reference results;
- the locked R environment in `renv.lock`;
- `SHA256SUMS.csv` and `FILE_MANIFEST.csv`; and
- `REPRODUCTION_REPORT.md` and the documentation in `docs/`.

## Reproduction boundary

The supported public route begins with the aggregate inputs in `data/derived/` and can be run after restoring the locked environment:

```r
renv::restore()
```

```sh
Rscript run_all.R all
```

The repository does not contain US or Brazilian record-level mortality files, raw-download caches, certificate text, credentials or other local audit material. No suppressed 1–9 cell is reconstructed or back-calculated. The record-level-to-aggregate reconstruction is documented in [`RAW_DATA_REBUILD.md`](RAW_DATA_REBUILD.md), and source routes, coverage and redistribution status are recorded in [`config/source_registry.csv`](../config/source_registry.csv).

The repository does not assign or claim a Zenodo DOI. A DOI should be added only if a versioned archive is deposited later.
