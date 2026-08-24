# Figure 2 metadata

Core conclusion: annual UCD and country-specific any_common rates, and the system-specific conditional UCD fraction, show distinct trajectories under one specified WHO18 age and sex target.
Archetype: quantitative grid with one country-specific conditional-fraction panel.
Backend: R only (ggplot2, patchwork, svglite, cairo_pdf and ragg).
Final size: 183 mm width x 112 mm height; vector text is retained in SVG/PDF; TIFF and PNG are 600 dpi.
Panels a-b numerator: annual analytic K80-K83 records under UCD or country-specific any_common. Denominator: population within specified age-sex strata. Estimator: direct WHO18 18-age standardization with sex weights 0.5/0.5; rate unit per 100,000 population.
Panels a-b intervals: 95% Poisson counting log intervals computed from specified country-year-age-sex counts.
Panel c estimand: country-year marginal P(UCD K80-K83 | country-specific any_common K80-K83), standardized to the same WHO18 age and sex target. Intervals are 95% model-conditional delta intervals scaled by Pearson dispersion.
Boundary: US any_common = UCD or entity-axis mention; Brazil any_common = UCD or saved certificate-line mention. These are not semantically equivalent. Panel c is not a clinical disease probability, certificate-quality score, coding-accuracy measure or causal estimand.
Confidence intervals exclude certification, coding, registration and release-system measurement error.
Input mapping: Fig2_source.csv (52 rows; SHA256 41A0C694C17F10C823CD4D98D4CEBA92BB3FADA083B3B310F412F82B2C6097ED); specified conditional-fraction source (26 rows; SHA256 368E363F21D0DA6742E2B31C16A8756B1BCAA0226E617FAE63695E992F45C359).
Output source rows: 78.
Image integrity: vector lines, points and uncertainty ribbons only; no raster source image, crop, contrast adjustment or reuse.
