# Paper 01 — Returns to Schooling in Brazil, 2012–2025: Design-Based Mincer Estimates from the PNAD Contínua

**Question.** How large is the earnings return to a year of schooling in Brazil, how has it moved since 2012, and how does it differ by completed level, sex, race and region, when the estimates respect the survey's sampling design?

**Evidence type.** Descriptive. The paper estimates the OLS Mincer benchmark that Duflo (2001) reports before her instrumental-variables estimates, for Brazil, with design-based inference. It makes no causal claim; see `notes/duflo-2001-notes.md` for how the original paper and Roodman's reanalysis shaped the design.

## Data

| Item | Value |
|---|---|
| Source | IBGE, PNAD Contínua, annual first-visit microdata ("Visita 1"), downloaded with the `PNADcIBGE` R package from `ftp.ibge.gov.br` |
| Years | 2012–2019 and 2022–2025. IBGE did not release first-visit microdata for 2020 and 2021 |
| Access date | 2026-10-11 (file versions: 2012–2014, 2016–2019, 2022–2023 dated 2025-08-22; 2015 dated 2025-12-10; 2024 dated 2025-11-19; 2025 dated 2026-09-23) |
| Deflators | IBGE `deflator_PNADC_2025.xls`; earnings multiplied by CO2 (habitual) or CO2e (effective) to 2025 average prices |
| Design | Strata (`Estrato`), primary sampling units (`UPA`), first-visit weights (`V1032`), `nest = TRUE`; lonely PSUs adjusted |
| Sample | Occupied persons aged 25–64 with positive habitual earnings and 1–120 weekly hours in the main job, schooling and race reported: 1,773,567 person-years |

Raw and cleaned data live in `data/` (git-ignored, about 2.5 GB) and are rebuilt by the scripts.

## How to run

```r
# from the repository root
renv::restore(project = "papers")
source("papers/01-returns-to-schooling/R/run_all.R")
```

`run_all.R` runs, in order: `00_download.R` (skips cached years), `01_build.R`, the unit tests in `tests/testthat/`, `02_checks.R` (reproduces IBGE's published mean real labour income from SIDRA table 7445 within 0.5% and mean years of schooling from table 7126 within 1.5%, stopping otherwise), `03_analysis.R`, and the Quarto render of `paper.qmd` to `output/paper.pdf`. Quarto must be on the PATH or installed at `~/.local/bin/quarto`; the PDF engine is `tectonic`.

Approximate runtime on an Apple-silicon laptop: download 6 minutes (first run only), build 3 minutes, checks 2 minutes, analysis 15 minutes, render 1 minute.

## Outputs

- `output/tables/`: `tab_main`, `tab_levels`, `tab_by_year`, `tab_regions`, `tab_robustness`, `tab_descriptives`, `tab_build_counts`, `tab_checks` (each as `.md` and `.tex`) and the estimates behind them as `.csv`
- `output/figures/`: `fig_returns_by_year`, `fig_levels_by_year`, `fig_heterogeneity`, `fig_regions` (`.pdf` and `.png`)
- `output/paper.pdf`

## Code map

| File | Role |
|---|---|
| `R/00_download.R` | resumable download, keeps analysis and design variables, drops replicate weights |
| `R/build_functions.R` | pure functions: recoding, deflation, sample flags, filter counts (unit-tested) |
| `R/01_build.R` | writes `data/clean/persons_<year>.rds`, `sample.rds`, `build_counts.csv` |
| `R/02_checks.R` | official-aggregate checks against SIDRA |
| `R/03_analysis.R` | year-by-year and pooled `svyglm` models, tables, figures, headline numbers |
| `R/run_all.R` | entry point |
| `tests/testthat/test-build.R` | tests on a synthetic fixture |
| `../_common/R/` | survey, table and plot helpers shared by the series |
