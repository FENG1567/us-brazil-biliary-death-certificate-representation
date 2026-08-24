# Supplementary Figure S1 metadata

Core conclusion: the released-representation contrasts remain similar under the prespecified time-form, leave-one-year, target, mean-structure and bootstrap sensitivity analyses.
Archetype: quantitative sensitivity grid.
Panel a: any_common BR/US RR time-form and leave-one-year results (19 rows). Panel b: system-specific conditional UCD fraction BR/US RR results (19 rows). Panel c: primary RRR sensitivity: Table S5 targets (5 rows) and Table S6 model/bootstrap comparisons (3 rows).
Panel b estimand: P(UCD | country-specific any_common), a system-specific conditional UCD fraction. It is neither a disease probability nor a certificate-quality score.
Intervals: panel a/b 95% model-conditional pointwise delta intervals; panel c uses the confidence or bootstrap intervals named in the source files. No interval includes national-system measurement error.
Input mapping and row guards: FigS1_source.csv (38 rows), representation_sex_year_weight_sensitivity.csv (25 rows; five RRR target rows retained), representation_flexible_structure_sensitivity.csv (5 rows; one RRR row retained), representation_multiplier_bootstrap_2000.csv (5 rows; one RRR row retained), and Fig3_source.csv (5 rows; one primary RRR row retained). Output has 46 rows.
Input SHA256: FigS1_source.csv=45d29fc0cb5083610d92d79a5f081f9a36112ffb2bd2823c6ffa6c7b6a0affd1; target=f3cb153f04bcc188f2f34127b0d8c6435fa12f4616428e1ee9bf8b0e48e6d82d; flexible=dd8c8c9647abfc08ba8edd2f9e0704ee0907fc1aba966b47fb7a333290c17521; bootstrap=cae16d8a6d09b1a7dfdf3ff6042e52ba3f28f3a6731f7375389036fc3accd875; primary Fig3=ba9a21e88bc6a27693a1e99cceece9ddf051c20f4de0ac28768d6a3310b3c6f2.
Administrative boundary: country-specific any_common uses US UCD/entity-axis versus Brazil UCD/saved-certificate-line representation; no common biological endpoint is implied.
Image integrity: all marks are vector-generated in R from aggregate sources; no data exclusion, image adjustment, or reused raster panel.
