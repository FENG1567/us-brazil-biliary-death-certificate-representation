options(stringsAsFactors = FALSE, scipen = 999, digits = 17, warn = 1)
required <- c("data.table", "sandwich", "digest")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing R packages: ", paste(missing, collapse = ", "), ". Run renv::restore().")
suppressPackageStartupMessages({library(data.table); library(sandwich)})

root <- getOption("usbr.repo_root")
out <- file.path(root, "results", "generated")
dir.create(out, recursive = TRUE, showWarnings = FALSE)
write_csv <- function(x, name) fwrite(as.data.table(x), file.path(out, name), na = "")

input_path <- file.path(root, "data", "derived", "analysis_input_936.csv")
subcode_path <- file.path(root, "data", "derived", "subcode_analysis_input_3744.csv")
weight_path <- file.path(root, "data", "metadata", "who_2000_2025_18_group_weights_correct.csv")
for (p in c(input_path, subcode_path, weight_path)) if (!file.exists(p)) stop("Missing input: ", p)

ages <- c("0-4","5-9","10-14","15-19","20-24","25-29","30-34","35-39","40-44","45-49","50-54","55-59","60-64","65-69","70-74","75-79","80-84","85+")
sexes <- c("F", "M"); countries <- c("US", "BR"); years <- 2012:2024
reps <- c("ucd", "any_common", "alternative")

d <- fread(input_path)
w <- fread(weight_path)[, .(age_group, population = as.numeric(population), ww = as.numeric(weight))]
w[, age_group := factor(age_group, levels = ages)]
w[, ww := ww / sum(ww)]
need <- c("country","year","age_group","sex","population","ucd","any_common","alternative")
if (!all(need %in% names(d))) stop("Unexpected aggregate-input schema")
if (nrow(d) != 936L || uniqueN(d[, .(country, year, age_group, sex)]) != 936L) stop("936-stratum key gate failed")
if (nrow(w) != 18L || abs(sum(w$ww) - 1) > 1e-12) stop("WHO18 weight gate failed")
if (any(d$population <= 0) || any(d$ucd < 0) || any(d$ucd > d$any_common) || any(d$ucd > d$alternative)) stop("Count/denominator gate failed")
d[, `:=`(country = factor(country, levels = countries), year = as.integer(year), age_group = factor(age_group, levels = ages), sex = factor(sex, levels = sexes), cluster_id = interaction(country, year, age_group, sex, drop = TRUE, lex.order = TRUE))]

align_x <- function(fit, nd) {
  x <- model.matrix(delete.response(terms(fit)), nd, contrasts.arg = fit$contrasts, xlev = fit$xlevels)
  b <- coef(fit); if (anyNA(b)) stop("Aliased coefficient")
  z <- matrix(0, nrow(x), length(b), dimnames = list(NULL, names(b)))
  common <- intersect(colnames(x), names(b)); z[, common] <- x[, common, drop = FALSE]; z
}
safe_se <- function(g, v) {
  q <- drop(t(g) %*% v %*% g)
  if (!is.finite(q) || q < -1e-8) stop("Invalid variance")
  sqrt(max(q, 0))
}
target_grid <- function(ages_use = ages, sex_w = c(F = .5, M = .5), year_w = setNames(rep(1 / length(years), length(years)), years), supported = NULL, include_rep = FALSE, reps_use = reps) {
  g <- CJ(country = factor(countries, levels = countries), year = as.integer(names(year_w)), age_group = factor(ages_use, levels = ages_use), sex = factor(names(sex_w), levels = sexes), unique = TRUE)
  if (include_rep) g <- g[, .(representation = factor(reps_use, levels = reps_use)), by = .(country, year, age_group, sex)]
  g <- merge(g, w[as.character(age_group) %in% ages_use, .(age_group, ww)], by = "age_group", all.x = TRUE, sort = FALSE)
  g[, std_weight := ww * unname(sex_w[as.character(sex)]) * unname(year_w[as.character(year)])]
  if (!is.null(supported)) g <- merge(g, supported[, .(year, age_group, sex)], by = c("year", "age_group", "sex"))
  groups <- if (include_rep) c("country", "representation") else "country"
  g[, std_weight := std_weight / sum(std_weight), by = groups]
  if (any(abs(g[, .(z = sum(std_weight)), by = groups]$z - 1) > 1e-10)) stop("Target-weight gate failed")
  g[, population := 1]; g
}
fit_stack <- function(dd, reps_use = reps, flex = FALSE) {
  l <- melt(copy(dd), id.vars = c("country","year","age_group","sex","population","cluster_id"), measure.vars = reps_use, variable.name = "representation", value.name = "count")
  l[, representation := factor(representation, levels = reps_use)]; setorder(l, cluster_id, representation)
  f <- if (flex) count ~ representation * country * factor(year) + representation * country * age_group * sex + offset(log(population)) else count ~ representation * country * factor(year) + representation * country * age_group + representation * country * sex + offset(log(population))
  fit <- glm(f, data = l, family = poisson(), x = TRUE, y = TRUE, model = TRUE)
  if (!fit$converged || anyNA(coef(fit))) stop("Stacked Poisson model failed")
  v <- sandwich::vcovCL(fit, cluster = l$cluster_id, type = "HC1")
  if (any(!is.finite(v))) stop("HC1 covariance failed")
  list(fit = fit, V = v, long = l)
}
std_stack <- function(fit, v, ages_use = ages, sex_w = c(F = .5, M = .5), year_w = setNames(rep(1 / 13, 13), years), reps_use = reps) {
  g <- target_grid(ages_use, sex_w, year_w, include_rep = TRUE, reps_use = reps_use)
  x <- align_x(fit, g); mu <- exp(drop(x %*% coef(fit))); g[, mu := mu]
  ans <- list(); grads <- list(); k <- 1L
  for (ct in countries) for (rp in reps_use) {
    ix <- g$country == ct & g$representation == rp
    rate <- sum(g$std_weight[ix] * mu[ix])
    glog <- colSums(x[ix, , drop = FALSE] * (g$std_weight[ix] * mu[ix])) / rate
    se <- safe_se(glog, v)
    ans[[k]] <- data.table(country = ct, representation = rp, rate = rate * 1e5, rate_lower = exp(log(rate * 1e5) - 1.96 * se), rate_upper = exp(log(rate * 1e5) + 1.96 * se), se_log = se)
    grads[[paste(ct, rp, sep = "|")]] <- glog; k <- k + 1L
  }
  list(table = rbindlist(ans), grads = grads, grid = g, X = x)
}
contrast_table <- function(std, v, reps_use = reps, label = "primary") {
  tab <- std$table; getg <- function(ct, rp) std$grads[[paste(ct, rp, sep = "|")]]
  ans <- list(); k <- 1L
  for (rp in reps_use) {
    gu <- getg("US", rp); gb <- getg("BR", rp)
    e <- tab[country == "BR" & representation == rp]$rate / tab[country == "US" & representation == rp]$rate
    se <- safe_se(gb - gu, v)
    ans[[k]] <- data.table(analysis = label, contrast = paste0("BR_US_RR_", rp), estimate = e, lower = exp(log(e) - 1.96 * se), upper = exp(log(e) + 1.96 * se), se_log = se); k <- k + 1L
  }
  if (all(c("ucd", "any_common") %in% reps_use)) {
    g <- getg("BR","any_common") - getg("US","any_common") - getg("BR","ucd") + getg("US","ucd")
    e <- (tab[country == "BR" & representation == "any_common"]$rate / tab[country == "US" & representation == "any_common"]$rate) / (tab[country == "BR" & representation == "ucd"]$rate / tab[country == "US" & representation == "ucd"]$rate)
    se <- safe_se(g, v); ans[[k]] <- data.table(analysis = label, contrast = "RRR_any_common_vs_ucd", estimate = e, lower = exp(log(e) - 1.96 * se), upper = exp(log(e) + 1.96 * se), se_log = se); k <- k + 1L
  }
  if (all(c("alternative", "any_common") %in% reps_use)) {
    g <- getg("BR","alternative") - getg("US","alternative") - getg("BR","any_common") + getg("US","any_common")
    e <- (tab[country == "BR" & representation == "alternative"]$rate / tab[country == "US" & representation == "alternative"]$rate) / (tab[country == "BR" & representation == "any_common"]$rate / tab[country == "US" & representation == "any_common"]$rate)
    se <- safe_se(g, v); ans[[k]] <- data.table(analysis = label, contrast = "RRR_alternative_vs_any_common", estimate = e, lower = exp(log(e) - 1.96 * se), upper = exp(log(e) + 1.96 * se), se_log = se)
  }
  rbindlist(ans)
}

# Primary stacked model and prespecified target/model sensitivities.
primary <- fit_stack(d); primary_std <- std_stack(primary$fit, primary$V); primary_con <- contrast_table(primary_std, primary$V)
write_csv(primary_std$table, "primary_standardized_rates.csv")
write_csv(primary_con, "primary_representation_contrasts.csv")
pop_year <- d[, .(year_population = sum(population)), by = year][order(year)]
pyw <- setNames(pop_year$year_population / sum(pop_year$year_population), pop_year$year)
specs <- list(
  sex_female = list(sex_w = c(F = 1, M = 0), year_w = setNames(rep(1/13,13), years)),
  sex_male = list(sex_w = c(F = 0, M = 1), year_w = setNames(rep(1/13,13), years)),
  population_weighted_years = list(sex_w = c(F = .5, M = .5), year_w = pyw),
  recent_3_years_equal = list(sex_w = c(F = .5, M = .5), year_w = setNames(rep(1/3,3), 2022:2024)),
  year_2024 = list(sex_w = c(F = .5, M = .5), year_w = setNames(1, 2024)))
sens <- rbindlist(lapply(names(specs), function(nm) {z <- specs[[nm]]; contrast_table(std_stack(primary$fit, primary$V, sex_w = z$sex_w, year_w = z$year_w), primary$V, label = nm)}))
write_csv(sens, "representation_target_sensitivity.csv")
flex <- fit_stack(d, flex = TRUE); flex_con <- contrast_table(std_stack(flex$fit, flex$V), flex$V, label = "flexible_country_representation_age_sex")
write_csv(flex_con, "representation_flexible_structure_sensitivity.csv")

# 2,000-draw score-linearized Rademacher cluster multiplier bootstrap.
set.seed(20260823L)
x <- primary$fit$x; mu <- fitted(primary$fit); score <- x * (primary$fit$y - mu)
s <- t(rowsum(score, primary$long$cluster_id, reorder = FALSE)); g_n <- ncol(s)
h_inv <- solve(crossprod(x, x * as.numeric(primary$fit$weights))); b_n <- 2000L
mult <- matrix(sample(c(-1,1), g_n * b_n, replace = TRUE), nrow = g_n) * sqrt(g_n / (g_n - 1))
delta <- h_inv %*% (s %*% mult)
glist <- list(); nms <- c("BR_US_RR_ucd","BR_US_RR_any_common","BR_US_RR_alternative","RRR_any_common_vs_ucd","RRR_alternative_vs_any_common")
for (rp in reps) glist[[paste0("BR_US_RR_", rp)]] <- primary_std$grads[[paste("BR",rp,sep="|")]] - primary_std$grads[[paste("US",rp,sep="|")]]
glist[["RRR_any_common_vs_ucd"]] <- glist[["BR_US_RR_any_common"]] - glist[["BR_US_RR_ucd"]]
glist[["RRR_alternative_vs_any_common"]] <- glist[["BR_US_RR_alternative"]] - glist[["BR_US_RR_any_common"]]
base_log <- setNames(log(primary_con$estimate), primary_con$contrast)
draw_log <- sapply(nms, function(nm) base_log[[nm]] + drop(crossprod(glist[[nm]], delta)))
boot <- rbindlist(lapply(seq_along(nms), function(j) {q <- quantile(exp(draw_log[,j]), c(.025,.5,.975), names = FALSE, type = 8); data.table(contrast = nms[j], estimate = exp(base_log[[nms[j]]]), bootstrap_median = q[2], lower = q[1], upper = q[3], n_boot = b_n, n_success = sum(is.finite(draw_log[,j])), n_fail = sum(!is.finite(draw_log[,j])))}))
write_csv(boot, "representation_multiplier_bootstrap_2000.csv")

# Conditional UCD fraction models and support sensitivity.
fit_sel <- function(dd, ages_use = ages) {z <- copy(dd); z[, `:=`(age_group = factor(as.character(age_group), levels = ages_use), sex = factor(as.character(sex), levels = sexes), country = factor(as.character(country), levels = countries))]; glm(cbind(ucd, any_common - ucd) ~ country * factor(year) + country * age_group + country * sex, data = z[any_common > 0], family = quasibinomial(), x = TRUE, y = TRUE, model = TRUE)}
std_sel <- function(fit, ages_use = ages, supported = NULL) {g <- target_grid(ages_use = ages_use, supported = supported); x <- align_x(fit, g); p <- plogis(drop(x %*% coef(fit))); ans <- list(); gr <- list(); for (ct in countries) {ix <- g$country == ct; ans[[ct]] <- data.table(country = ct, probability = sum(g$std_weight[ix] * p[ix])); gr[[ct]] <- colSums(x[ix,,drop=FALSE] * (g$std_weight[ix] * p[ix] * (1-p[ix])))}; list(table = rbindlist(ans), grads = gr)}
sel_summary <- function(fit, std, label) {tab <- std$table; pu <- tab[country=="US"]$probability; pb <- tab[country=="BR"]$probability; v <- vcov(fit); gd <- std$grads[["BR"]] - std$grads[["US"]]; se_rd <- safe_se(gd,v); glrr <- std$grads[["BR"]]/pb - std$grads[["US"]]/pu; se_rr <- safe_se(glrr,v); data.table(analysis=label,us_conditional_ucd_fraction=pu,br_conditional_ucd_fraction=pb,risk_difference_br_minus_us=pb-pu,rd_lower=pb-pu-1.96*se_rd,rd_upper=pb-pu+1.96*se_rd,risk_ratio_br_over_us=pb/pu,rr_lower=exp(log(pb/pu)-1.96*se_rr),rr_upper=exp(log(pb/pu)+1.96*se_rr),n_fit=nobs(fit),n_zero_trials_excluded=sum(d$any_common==0))}
sf <- fit_sel(d); sel_primary <- sel_summary(sf, std_sel(sf), "full_grid_primary")
wide <- dcast(copy(d), year + age_group + sex ~ country, value.var = "any_common"); support <- wide[US > 0 & BR > 0, .(year,age_group,sex)]
dsup <- merge(d, support, by = c("year","age_group","sex")); sf_sup <- fit_sel(dsup); sel_sup <- sel_summary(sf_sup, std_sel(sf_sup, supported = support), "common_positive_trial_support")
adult <- ages[match("20-24",ages):length(ages)]; dadult <- d[as.character(age_group) %in% adult]; sf_adult <- fit_sel(dadult, adult); sel_adult <- sel_summary(sf_adult, std_sel(sf_adult, adult), "age_20plus")
write_csv(rbindlist(list(sel_primary,sel_sup,sel_adult)), "selection_support_sensitivity.csv")
write_csv(d[any_common > 0, .(ucd=sum(ucd), any_common=sum(any_common), observed_conditional_fraction=sum(ucd)/sum(any_common), n_positive_trial_strata=.N), by=country], "selection_observed_positive_descriptive.csv")

# K80-K83 three-character component extension from de-identified aggregate input.
sub <- fread(subcode_path)
if (nrow(sub) != 3744L || uniqueN(sub[,.(subcode,country,year,age_group,sex)]) != 3744L) stop("3,744-row subcode gate failed")
sub_out <- list(); k <- 1L
for (sc in paste0("K8",0:3)) {
  dd <- sub[subcode == sc]
  dd[, `:=`(country=factor(country,levels=countries), year=as.integer(year), age_group=factor(age_group,levels=ages), sex=factor(sex,levels=sexes), cluster_id=interaction(country,year,age_group,sex,drop=TRUE,lex.order=TRUE))]
  totals <- dd[,.(country_events=sum(any_common)),by=country]
  if (any(totals$country_events < 20)) sub_out[[k]] <- data.table(subcode=sc,analysis_status="DESCRIPTIVE_ONLY_COUNTRY_TOTAL_LT20",contrast=NA_character_,estimate=NA_real_,lower=NA_real_,upper=NA_real_,se_log=NA_real_) else {
    m <- fit_stack(dd, reps_use=c("ucd","any_common")); z <- contrast_table(std_stack(m$fit,m$V,reps_use=c("ucd","any_common")),m$V,reps_use=c("ucd","any_common"),label=sc)
    z[, `:=`(subcode=sc,analysis_status="MODELED_HC1_CLUSTERED")]; sub_out[[k]] <- z
  }
  k <- k + 1L
}
subres <- rbindlist(sub_out, fill=TRUE)
idx <- which(subres$contrast=="RRR_any_common_vs_ucd" & subres$analysis_status=="MODELED_HC1_CLUSTERED")
subres[, `:=`(p_raw=NA_real_, p_holm=NA_real_, direction=ifelse(is.na(estimate),"suppressed",ifelse(estimate>1,"above 1","below 1")))]
if (length(idx)) {p <- 2*pnorm(-abs(log(subres$estimate[idx])/subres$se_log[idx])); subres$p_raw[idx] <- p; subres$p_holm[idx] <- p.adjust(p,"holm")}
write_csv(subres, "icd10_three_character_subcode_rr_rrr.csv")
write_csv(sub[,.(country_events=sum(any_common),ucd_events=sum(ucd)),by=.(subcode,country)], "icd10_three_character_subcode_event_totals.csv")

# Annual directly standardized rates and the paper's Poisson counting log intervals.
direct_log_interval <- function(count, pop, weight) {coef<-weight*1e5/pop;r<-sum(coef*count);v<-sum(coef^2*count);se_log<-sqrt(v)/r;c(estimate=r,lower=exp(log(r)-1.96*se_log),upper=exp(log(r)+1.96*se_log))}
annual <- list(); k <- 1L
for (ct in countries) for (yr in years) for (rp in c("ucd","any_common")) {
  z <- d[as.character(country)==ct & year==yr, .(age_group,sex,count=get(rp),population)]
  z <- merge(z,w[,.(age_group,ww)],by="age_group"); z[,std_weight:=ww*.5]; q <- direct_log_interval(z$count,z$population,z$std_weight)
  annual[[k]] <- data.table(country=ct,year=yr,sex="Both",endpoint=rp,deaths=sum(z$count),person_years=sum(z$population),asr=q[1],lower=q[2],upper=q[3],interval="95% Poisson counting log interval"); k <- k+1L
}
write_csv(rbindlist(annual), "annual_direct_standardized_rates.csv")

gate <- data.table(check=c("936 unique strata","WHO18 weights sum to one","count nesting","primary model converged","bootstrap draws complete","3744 unique component strata"),status=c("PASS","PASS","PASS",ifelse(primary$fit$converged,"PASS","FAIL"),ifelse(all(boot$n_success==2000L),"PASS","FAIL"),"PASS"))
write_csv(gate, "reproduction_gate.csv")
capture.output(sessionInfo(), file=file.path(out,"sessionInfo.txt"))
if (any(gate$status != "PASS")) stop("A reproduction gate failed")
message("Analysis reproduction PASS: ", out)
