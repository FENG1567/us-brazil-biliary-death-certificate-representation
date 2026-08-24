# Raw-data acquisition and aggregate reconstruction

## United States

1. Obtain annual Mortality Multiple Cause-of-Death public-use files and their record layouts from CDC/NCHS for 2012-2024.
2. Restrict to US resident deaths using the annual record-layout definition.
3. Harmonize age into 18 groups (`0-4` through `85+`) and recorded sex into `F` and `M`; exclude records without an eligible age-sex value.
4. Define UCD as an underlying cause beginning with K80, K81, K82 or K83.
5. Define the primary US `any_common` representation as UCD or an entity-axis K80-K83 mention.
6. Define the US structural sensitivity as UCD or a record-axis K80-K83 mention.
7. Validate available national UCD aggregates against CDC WONDER without using WONDER to claim entity-axis equivalence.

Official routes:

- NCHS mortality public-use files: <http[local file not redistributed]
- NCHS FTP mortality directory: <http[local file not redistributed]
- CDC WONDER Multiple Cause of Death: <http[local file not redistributed]
- CDC WONDER Underlying Cause of Death: <http[local file not redistributed]

## Brazil

1. Obtain annual SIM mortality files for 2012-2024 through OpenDataSUS/DATASUS.
2. Apply the frozen death-type and residency definitions from the SIM data dictionary. Preserve the 2011/2012 form break as a design boundary; the primary window begins in 2012.
3. Harmonize age and sex to the same 18 age groups and two recorded-sex categories.
4. Define UCD from `CAUSABAS` beginning with K80-K83.
5. Define Brazil `any_common` as UCD or K80-K83 appearing in saved certificate lines `LINHAA`-`LINHAD` or `LINHAII`.
6. Do not equate a saved Brazilian certificate line with NCHS entity-axis processing.
7. Validate bounded annual UCD totals against DATASUS TabNet; this does not validate semantic equivalence of released mention layers.

Official routes:

- OpenDataSUS SIM: <http[local file not redistributed]
- DATASUS file transfer: <http[local file not redistributed]
- DATASUS TabNet mortality: <http[local file not redistributed]

## Denominators and standardization

- US denominators: official Census intercensal/postcensal national age-sex estimates.
- Brazil denominators: official IBGE 2024 population projection table by five-year age group.
- Standard population: WHO 2000-2025 adjusted 18-age distribution as reproduced by SEER.
- Primary target: WHO18 age weights, sex weights 0.5/0.5 and equal weights for each year from 2012 through 2024.

## Required closure gates

- exactly 936 unique country-year-age-sex rows;
- exactly 3,744 unique subcode-country-year-age-sex rows;
- positive denominators and non-negative integer counts;
- `UCD <= any_common` and `UCD <= alternative` in every stratum;
- WHO18 weights sum to one;
- K80-K83 record-level union reproduces the frozen 936-row UCD and `any_common` counts exactly;
- source file, parser and generated-input SHA256 values recorded before analysis.

Do not commit raw files, record-level caches or credentials. Put local raw files under ignored `data/raw/` paths.
