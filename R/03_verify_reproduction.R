options(stringsAsFactors=FALSE,scipen=999,digits=17)
if (!requireNamespace("data.table",quietly=TRUE)) stop("Missing package: data.table")
library(data.table)
root <- getOption("usbr.repo_root"); gen <- file.path(root,"results","generated"); ref <- file.path(root,"results","reference","results")
checks <- list()
add <- function(id,status,detail){checks[[length(checks)+1L]] <<- data.table(check=id,status=status,detail=detail)}
compare_numeric <- function(generated,reference,key_g,key_r=NULL,tol=1e-8){if(is.null(key_r))key_r<-key_g;g<-fread(generated);r<-fread(reference);g[,key:=do.call(paste,c(.SD,sep="|")),.SDcols=key_g];r[,key:=do.call(paste,c(.SD,sep="|")),.SDcols=key_r];z<-merge(g,r,by="key",suffixes=c("_g","_r"));cols<-intersect(sub("_g$","",grep("_g$",names(z),value=TRUE)),sub("_r$","",grep("_r$",names(z),value=TRUE)));cols<-cols[vapply(cols,function(x)is.numeric(z[[paste0(x,"_g")]])&&is.numeric(z[[paste0(x,"_r")]]),logical(1))];if(!nrow(z)||!length(cols))return(Inf);vals<-vapply(cols,function(x){q<-abs(z[[paste0(x,"_g")]]-z[[paste0(x,"_r")]]);if(all(is.na(q)))0 else max(q,na.rm=TRUE)},numeric(1));max(vals,na.rm=TRUE)}
files <- c("primary_standardized_rates.csv","primary_representation_contrasts.csv","representation_multiplier_bootstrap_2000.csv","icd10_three_character_subcode_rr_rrr.csv","annual_direct_standardized_rates.csv","reproduction_gate.csv")
for(f in files)add(paste0("exists:",f),ifelse(file.exists(file.path(gen,f)),"PASS","FAIL"),file.path("results/generated",f))
if(all(vapply(checks,function(x)x$status=="PASS",logical(1)))){
  e1<-compare_numeric(file.path(gen,"primary_standardized_rates.csv"),file.path(ref,"v5_primary_standardized_rates.csv"),c("country","representation"));add("primary rates within 1e-8",ifelse(e1<=1e-8,"PASS","FAIL"),format(e1,scientific=TRUE))
  e2<-compare_numeric(file.path(gen,"primary_representation_contrasts.csv"),file.path(ref,"v5_primary_representation_contrasts.csv"),"contrast");add("primary contrasts within 1e-8",ifelse(e2<=1e-8,"PASS","FAIL"),format(e2,scientific=TRUE))
  e3<-compare_numeric(file.path(gen,"icd10_three_character_subcode_rr_rrr.csv"),file.path(ref,"icd10_three_character_subcode_rr_rrr.csv"),c("subcode","contrast"));add("component contrasts within 1e-8",ifelse(e3<=1e-8,"PASS","FAIL"),format(e3,scientific=TRUE))
  e4<-compare_numeric(file.path(gen,"representation_multiplier_bootstrap_2000.csv"),file.path(ref,"representation_multiplier_bootstrap_2000.csv"),"contrast");add("cluster multiplier bootstrap within 1e-8",ifelse(e4<=1e-8,"PASS","FAIL"),format(e4,scientific=TRUE))
  e5<-compare_numeric(file.path(gen,"representation_flexible_structure_sensitivity.csv"),file.path(ref,"representation_flexible_structure_sensitivity.csv"),"contrast");add("flexible model sensitivity within 1e-8",ifelse(e5<=1e-8,"PASS","FAIL"),format(e5,scientific=TRUE))
  e6<-compare_numeric(file.path(gen,"representation_target_sensitivity.csv"),file.path(root,"data","source_data","representation_sex_year_weight_sensitivity.csv"),c("analysis","contrast"));add("target sensitivity within 1e-8",ifelse(e6<=1e-8,"PASS","FAIL"),format(e6,scientific=TRUE))
  e7<-compare_numeric(file.path(gen,"selection_support_sensitivity.csv"),file.path(ref,"selection_zero_trial_support_and_age_sensitivity.csv"),"analysis");add("selection support sensitivity within 1e-8",ifelse(e7<=1e-8,"PASS","FAIL"),format(e7,scientific=TRUE))
  ga<-fread(file.path(gen,"annual_direct_standardized_rates.csv"));ra<-fread(file.path(root,"figures","reference","Figure2_source.csv"))[metric=="direct_age_standardized_rate"]
  za<-merge(ga,ra,by.x=c("country","year","endpoint"),by.y=c("country","year","representation"),suffixes=c("_g","_r"));e8<-max(abs(c(za$asr-za$estimate,za$lower_g-za$lower_r,za$upper_g-za$upper_r)),na.rm=TRUE);add("annual direct rates and Poisson log intervals within 1e-8",ifelse(nrow(za)==52L&&e8<=1e-8,"PASS","FAIL"),paste0("rows=",nrow(za),"; max_abs_diff=",format(e8,scientific=TRUE)))
}
qa<-rbindlist(checks,fill=TRUE);fwrite(qa,file.path(gen,"verification_report.csv"));if(any(qa$status=="FAIL"))stop("Reproduction verification failed; see results/generated/verification_report.csv")
message("Verification PASS; ",nrow(qa)," checks.")
