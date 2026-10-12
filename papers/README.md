# Brazilian Replications in Development Economics

Short, reproducible working papers that re-run the empirical methods taught in the MIT DEDP MicroMasters (Data Analysis for Social Scientists, Foundations of Development Policy, Political Economy and Economic Development) on Brazilian public microdata.

## Stance

Each paper asks one question, uses one dataset and one identification strategy, and states explicitly whether its evidence is descriptive or causal. Inference follows the data's design: IBGE household surveys are analysed with their weights, strata and primary sampling units (`survey`/`srvyr`); treatments that vary at a group level get clustered standard errors. Every table note states the standard-error type and the sample size. Every paper ships a replication package that downloads its raw data and regenerates every number from a clean clone.

## Papers

| # | Paper | Course theme (original paper) | Data | Evidence | Status |
|---|---|---|---|---|---|
| 01 | Returns to Schooling in Brazil, 2012–2025: Design-Based Mincer Estimates from the PNAD Contínua | 14.740x Week 3, Education (Duflo 2001) | PNAD Contínua annual, visit 1 (IBGE), 2012–2019 and 2022–2025 | Descriptive | draft v0.1, PDF in `01-returns-to-schooling/output/` |

Planned: female mayors and prenatal care (close-election RD, Brollo & Troiano 2016); food and calorie Engel curves (POF 2017–18); audits and re-election (Ferraz & Finan 2008).

## How to run a paper

```r
# from the repository root
renv::restore(project = "papers")
source("papers/01-returns-to-schooling/R/run_all.R")
```

Raw microdata are downloaded to each paper's `data/` folder (git-ignored) on first run.

## Layout

- `_common/R/` shared helpers (survey design wrappers, table export, plot theme)
- `_template/` Quarto skeleton for new papers
- `NN-slug/` one folder per paper: `R/` pipeline, `tests/`, `paper.qmd`, `output/`
- `CHECKLIST.md` validity checklist ticked before any release
- `PUBLISHING.md` release steps (Zenodo DOI, SSRN, MPRA, arXiv, ANPEC/SBE)

## Citing

Each released paper carries a Zenodo DOI in its README. Data belong to their producers (IBGE, INEP, TSE, DataSUS) under their own terms.
