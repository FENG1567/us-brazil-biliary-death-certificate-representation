options(stringsAsFactors = FALSE, scipen = 999)
required <- c("ggplot2", "patchwork", "scales")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Missing R packages: ", paste(missing, collapse = ", "), ". Run renv::restore().")
suppressPackageStartupMessages({library(ggplot2); library(patchwork)})

root <- getOption("usbr.repo_root"); src <- file.path(root,"figures","reference"); out <- file.path(root,"figures","generated")
dir.create(out,recursive=TRUE,showWarnings=FALSE)
theme_pub <- function(base_size=8) theme_classic(base_size=base_size,base_family="sans") + theme(panel.grid.major.x=element_line(colour="#E8E8E8",linewidth=.25),panel.grid.minor=element_blank(),legend.position="bottom",plot.title=element_text(face="bold",size=9))
export <- function(p,name,w=7.2,h=5.2){
  png_path <- file.path(out,paste0(name,".png")); pdf_path <- file.path(out,paste0(name,".pdf"))
  grDevices::png(png_path,width=w,height=h,units="in",res=300,type="cairo",bg="white"); print(p); grDevices::dev.off()
  ggsave(pdf_path,p,width=w,height=h,device=cairo_pdf,bg="white")
  if (!file.exists(png_path) || !file.exists(pdf_path) || any(file.info(c(png_path,pdf_path))$size<=0)) stop("Figure export failed: ",name)
}

# Figure 1: cohort/representation/validation source is already a frozen descriptive audit table.
f1 <- read.csv(file.path(src,"Figure1_source.csv"),check.names=FALSE)
flow <- subset(f1,source_section=="cohort_flow"); flow$n <- as.numeric(flow$value); flow$stage <- factor(flow$stage,levels=unique(flow$stage)); flow$country <- factor(flow$country,levels=c("United States","Brazil"))
p1a <- ggplot(flow,aes(stage,n,group=country,colour=country))+geom_line(linewidth=.8)+geom_point(size=2)+scale_y_log10(labels=scales::comma)+labs(title="Cohort flow and analytic endpoints",x=NULL,y="Records (log scale)")+theme_pub()+theme(axis.text.x=element_text(angle=25,hjust=1))
rep <- subset(f1,source_section=="parallel_representations"); rep$analytic_count <- as.numeric(rep$value); rep$representation <- factor(rep$representation,levels=c("ucd","any_common","alternative"))
p1b <- ggplot(rep,aes(representation,analytic_count,fill=country))+geom_col(position="dodge")+scale_y_continuous(labels=scales::comma)+labs(title="Parallel released representations",x=NULL,y="Analytic count")+theme_pub()+theme(axis.text.x=element_text(angle=20,hjust=1))
val <- subset(f1,source_section=="validation_boundary"); val$stage <- factor(val$stage,levels=c("green","amber","red"))
p1c <- ggplot(val,aes(x=representation,y=country,fill=stage))+geom_tile(colour="white",linewidth=.5)+scale_fill_manual(values=c(green="#3A923A",amber="#E6A700",red="#C74343"),drop=FALSE)+labs(title="National-source validation boundaries",x=NULL,y=NULL,fill=NULL)+theme_pub()+theme(axis.text.x=element_text(angle=20,hjust=1))
export((p1a|p1b)/p1c,"Figure1",7.2,6.5)

f2 <- read.csv(file.path(src,"Figure2_source.csv"),check.names=FALSE)
rate <- subset(f2,metric=="direct_age_standardized_rate"); frac <- subset(f2,metric=="system_specific_conditional_ucd_fraction")
rate$representation <- factor(rate$representation,levels=c("ucd","any_common")); rate$country <- factor(rate$country,levels=c("US","BR"))
make_rate <- function(ct,title){z<-subset(rate,country==ct);ggplot(z,aes(year,estimate,colour=representation,fill=representation))+geom_ribbon(aes(ymin=lower,ymax=upper),alpha=.14,colour=NA)+geom_line(linewidth=.75)+geom_point(size=1.2)+labs(title=title,x="Year",y="Rate per 100,000")+theme_pub()}
frac$country <- factor(frac$country,levels=c("US","BR")); p2c<-ggplot(frac,aes(year,estimate,colour=country,fill=country))+geom_ribbon(aes(ymin=lower,ymax=upper),alpha=.14,colour=NA)+geom_line(linewidth=.75)+geom_point(size=1.2)+scale_y_continuous(labels=scales::percent_format())+labs(title="System-specific conditional UCD fraction",x="Year",y="P(UCD | any_common)")+theme_pub()
export((make_rate("US","United States")|make_rate("BR","Brazil"))/p2c,"Figure2",7.2,6.2)

f3 <- read.csv(file.path(src,"Figure3_source.csv"),check.names=FALSE)
overall <- subset(f3,source_section=="overall"); component <- subset(f3,source_section=="component")
p3a <- ggplot(overall,aes(estimate,reorder(specification,estimate),colour=analysis_group))+geom_vline(xintercept=1,lty=2,colour="#666666")+geom_errorbarh(aes(xmin=lower,xmax=upper),height=.15)+geom_point(size=2)+labs(title="Overall released-representation contrasts",x="Ratio estimate",y=NULL,colour=NULL)+theme_pub()
p3b <- ggplot(component,aes(estimate,reorder(component,estimate),colour=specification))+geom_vline(xintercept=1,lty=2,colour="#666666")+geom_errorbarh(aes(xmin=lower,xmax=upper),height=.15,position=position_dodge(.45))+geom_point(position=position_dodge(.45),size=1.8)+labs(title="K80-K83 component contrasts",x="Ratio estimate",y=NULL,colour=NULL)+theme_pub()
export(p3a|p3b,"Figure3",7.2,4.8)

fs <- read.csv(file.path(src,"FigureS1_source.csv"),check.names=FALSE)
ab <- subset(fs,source_section=="time_form_and_leave_one_year"); cc <- subset(fs,source_section!="time_form_and_leave_one_year")
pSa <- ggplot(ab,aes(reorder(specification,estimate),estimate,colour=endpoint))+geom_errorbar(aes(ymin=lower,ymax=upper),width=.2)+geom_point(size=1.4)+scale_y_continuous(limits=c(1.20,2.55),breaks=seq(1.25,2.50,.25))+coord_flip()+labs(title="Time-form and leave-one-year sensitivity",x=NULL,y="Ratio estimate",colour=NULL)+theme_pub()
pSb <- ggplot(cc,aes(reorder(specification,estimate),estimate,colour=source_section))+geom_hline(yintercept=1,lty=2,colour="#666666")+geom_errorbar(aes(ymin=lower,ymax=upper),width=.2)+geom_point(size=1.6)+scale_y_continuous(limits=c(.74,1.01),breaks=seq(.75,1.00,.05),labels=function(x)formatC(x,format="f",digits=2))+coord_flip()+labs(title="Target, model and bootstrap sensitivity",x=NULL,y="RRR",colour=NULL)+theme_pub()
export(pSa|pSb,"FigureS1",12.0,8.5)
message("Figure reproduction PASS: ",out)
