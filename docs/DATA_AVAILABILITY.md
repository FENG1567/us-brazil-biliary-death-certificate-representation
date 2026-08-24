# Data and code availability statement

The public code and aggregate reproducibility package are available at <https://github.com/FENG1567/us-brazil-biliary-death-certificate-representation>. The repository contains the analysis code, de-identified country-year-age-sex aggregate inputs, variable dictionaries, frozen figure and table source data, the `renv.lock` environment specification, SHA-256 checksums and the reproduction report.

Record-level US and Brazilian mortality files are not redistributed. Users who need to rebuild the aggregate inputs must obtain the relevant source data from CDC/NCHS and CDC WONDER for the United States, SIM/OpenDataSUS/DATASUS for Brazil, and population denominators from the US Census Bureau and IBGE, under the agencies' current access terms. The primary reproducibility route begins with de-identified country-year-age-sex aggregates. No suppressed 1–9 cell is reconstructed or back-calculated.

Acquisition routes, coverage, definitions and redistribution status are documented in [`RAW_DATA_REBUILD.md`](RAW_DATA_REBUILD.md) and [`config/source_registry.csv`](../config/source_registry.csv). The manuscript-ready wording and the full boundary statement are in [`CODE_AVAILABILITY.md`](CODE_AVAILABILITY.md). No Zenodo DOI has been assigned.
