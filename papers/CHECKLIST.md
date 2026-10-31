# Validity checklist

Copy this file into the paper folder and tick every item before tagging a release.

## Question and framing
- [ ] One question, one dataset, one identification strategy
- [ ] The abstract and introduction say whether the evidence is descriptive or causal, and why
- [ ] Mapping to the original course paper: what is replicated, what differs, why Brazil is informative
- [ ] Limitations section written against the strongest objection, not the weakest

## Data
- [ ] Raw data downloaded by script, never committed; access dates recorded in the README
- [ ] Every expected variable asserted to exist in every year or wave (the build script stops otherwise)
- [ ] Sample construction documented with counts at each filter step (appendix table)
- [ ] Deflators and reference year stated

## Inference
- [ ] IBGE surveys analysed with weights, strata and PSUs (`survey::svydesign` or the IBGE package's design object)
- [ ] Clustered SEs at the level treatment varies; wild cluster bootstrap when clusters < 40
- [ ] Standard-error type and N stated in every table note
- [ ] At least one official published aggregate reproduced from the design object within 1% (`02_checks.R`)

## Robustness
- [ ] Pre-listed robustness checks run and reported, including the ones that did not help the story
- [ ] For RD: density test, covariate balance, bandwidth and kernel sensitivity, placebo cutoffs
- [ ] For DiD: pre-trends or a falsification test with unexposed groups

## Reproducibility
- [ ] `renv.lock` updated; `renv::restore()` works from a clean clone
- [ ] `Rscript R/run_all.R` runs tests, checks, analysis and renders the PDF without manual steps
- [ ] A second run changes no file in `output/`
- [ ] Unit tests in `tests/testthat/` pass

## Release
- [ ] English and Portuguese abstracts; JEL codes; keywords
- [ ] References complete in `references.bib`
- [ ] README with how to run, runtime, data sources and access dates
- [ ] LICENSE present in the repository
- [ ] Tagged release on GitHub; Zenodo DOI minted and added to the paper and README
