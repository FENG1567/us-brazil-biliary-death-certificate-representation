# Reproduction report

Verification date: 2026-08-24 (Asia/Shanghai)

## Tested route

```sh
Rscript run_all.R all
```

Local verification used R 4.3.1 with the package versions locked in `renv.lock`. The run completed the aggregate analysis, 2,000-draw bootstrap, component analysis, annual direct rates, four figure builds and the final comparison gate.

## Result

All 14 verification checks passed. Maximum absolute differences were zero for:

- primary standardized rates;
- primary representation contrasts;
- K80-K83 component contrasts;
- cluster multiplier bootstrap results;
- flexible mean-structure sensitivity;
- target-population sensitivity; and
- conditional UCD-fraction support sensitivity.

The 52 annual direct rate point estimates and Poisson counting log interval limits also matched the frozen final Figure 2 source data within `1e-8`.

Generated Figure 1 and Supplementary Figure S1 were visually inspected for readable labels, complete panels and non-empty outputs. Exact raster or PDF hashes are not used as a cross-platform gate because installed fonts and graphics devices can change binary output without changing numerical content.

The Windows host emitted locale-setting warnings for `C.UTF-8`; these did not alter UTF-8 file reads, model results or verification status.

## Reproduction level

Status: **PASS from de-identified analysis-ready aggregate inputs**.

The package does not claim a fully automated raw-record download and parser route. Record-level mortality files and deterministic interruption caches are deliberately excluded; official acquisition and reconstruction steps are documented in `docs/RAW_DATA_REBUILD.md`.

Machine-readable verification evidence is stored in `results/reference/reproduction_verification_20260824.csv` and `results/reference/sessionInfo_verified_20260824.txt`.
