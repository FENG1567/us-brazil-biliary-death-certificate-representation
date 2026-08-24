#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grepl("^--file=", args)])
# Use the working directory first. This avoids a Windows R 4.3 locale failure
# when normalizePath() receives a full path containing non-ASCII characters.
repo_root <- "."
if (!file.exists(file.path(repo_root, "README.md"))) stop("Run this command from the repository root.")
run_args <- commandArgs(trailingOnly = TRUE)
mode <- if (length(run_args)) run_args[1] else "all"
allowed <- c("all", "analysis", "figures", "verify")
if (!mode %in% allowed) stop("Usage: Rscript run_all.R [all|analysis|figures|verify]")

dir.create(file.path(repo_root, "results", "generated"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(repo_root, "figures", "generated"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(repo_root, "logs"), recursive = TRUE, showWarnings = FALSE)

run_step <- function(script) {
  message("\n==> ", script)
  source(file.path(repo_root, "R", script), local = new.env(parent = globalenv()), encoding = "UTF-8")
}

options(usbr.repo_root = repo_root)
if (mode %in% c("all", "analysis")) run_step("01_reproduce_analysis.R")
if (mode %in% c("all", "figures")) run_step("02_build_figures.R")
if (mode %in% c("all", "verify")) run_step("03_verify_reproduction.R")

message("\nPASS: requested reproduction route completed.")
