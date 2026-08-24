.PHONY: all analysis figures verify

all:
	Rscript run_all.R all

analysis:
	Rscript run_all.R analysis

figures:
	Rscript run_all.R figures

verify:
	Rscript run_all.R verify
