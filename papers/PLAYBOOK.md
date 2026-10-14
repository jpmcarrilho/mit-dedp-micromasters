# Playbook: how a paper in this series is made

Written 2026-10-14 after Paper 01 (returns to schooling, PNAD Contínua). Audience: an agent (or a person) asked to produce the next paper in `papers/`. It records what the author asked for at each step, what was done in response, the procedure to repeat, and the mistakes that cost time. Read it together with `README.md` (series stance), `CHECKLIST.md` (what "valid" means here), `PUBLISHING.md` (release path) and the notes in `01-returns-to-schooling/notes/`.

## 1. The author's requests and what each one triggered

| Step | Author's request (paraphrased) | What was done | Where it lives |
|---|---|---|---|
| 1 | "Is it plausible and valid to re-run each week's methods on Brazilian data and publish small, econometrically valid papers (arXiv, like a Brazilian TCC)?" | Grounded assessment: read the repo, verified MIT DEDP admission rules and the arXiv endorsement policy on the web, inventoried Brazilian data and R packages, then wrote a plan in plan mode (series design, venues, timeline) and asked three questions (first paper, location, application cycle). | `~/.claude/plans/…` (session plan), `README.md`, `PUBLISHING.md` |
| 2 | "Web search MIT's DEDP program if necessary." | Pulled the admissions page and the support articles: grades weigh most; application has a 2-page Research Proposal, Statement, CV, 2 letters, video; credential must be complete by the November exam session to apply in the Nov–Jan window. | memory file, plan, `README.md` |
| 3 | "Let's go from 1 to 2 for now; read the original paper and do this analysis; create a paper with a simple but tested R script and valid analysis; choose the conclusions if confident." | Narrowed the plan to Phase 0 (infrastructure) + Paper 01, approved, then built everything in this document's Section 2. | `01-returns-to-schooling/` |
| 4 | "I love where the paper is going, but it is repetitive; cite the sources and explain the ideas plainly, like a good economics paper." | Rewrote all prose: each idea once, plain explanations before numbers, a citation for every borrowed idea; 13 references added. Numbers and tables untouched. | `paper.qmd`, `references.bib` |
| 5 | "Is there any paper that does a similar analysis? Do a literature research." | Parallel searches in English and Portuguese (SciELO, RePEc, SSRN, IPEA, ANPEC, journal sites), abstracts and methods fetched, 23 papers positioned against Paper 01, edits listed; references added. | `notes/literature-review.md` |
| 6 | "Can you trust these results? Review the code. Is this paper worth sharing?" | Independent re-computations on the real data, cluster-structure analysis, alternative specifications, and a hunt for the cause of the one failed official check (found in IBGE's own report). Findings ranked, verdict given. | `notes/review-2026-10-13.md` |
| 7 | "Export a .md explaining all the steps so another agent can replicate it." | This file. | `PLAYBOOK.md` |

Each milestone was committed on the feature branch `feature/papers-01-returns-to-schooling` with the attribution trailer; data, logs and the renv library are never committed.

## 2. The procedure to repeat for the next paper

Work in a feature branch (`git checkout -b feature/papers-NN-slug`). Use absolute paths in shell commands and avoid `cd` in commands that may run in parallel: the shell's working directory is shared and one call's `cd` can land in another call. Put temporary files in the session scratchpad, never in the repo.

### Step 0. Load context

Read `README.md`, `CHECKLIST.md`, `PUBLISHING.md`, this file, and the previous papers' `notes/`. Check the memory files for the author's goals and deadlines. The author's standing preferences: descriptive and causal claims labelled honestly; survey-design inference always; plain prose, each idea once, every borrowed idea cited; English with a Portuguese abstract; no marketing language; report what the data show, not what was hoped for.

### Step 1. Plan before building

In plan mode: map the course week to its original paper; pick the Brazilian dataset and identification strategy; decide whether the evidence will be descriptive or causal and say why; list the official aggregates that will serve as checks; estimate effort; ask the author only the questions that change the work (which paper, where, which deadline). Write the plan file and get approval. Paper 01's plan took the approach "one question, one dataset, one strategy, 10–20 pages".

### Step 2. Environment

```bash
R --version                      # 4.5.2 at the time of writing
~/.local/bin/quarto --version    # 1.10.19, installed without sudo from the macOS .tar.gz release
which tectonic                   # /opt/homebrew/bin/tectonic is the PDF engine
```

`brew install quarto` fails because the cask needs an admin password; the tarball into `~/.local/opt` works. R packages used: survey, srvyr, PNADcIBGE, sidrar, modelsummary, tinytable, kableExtra, renv, here, testthat, sandwich, lmtest, ggplot2, dplyr, tidyr, purrr, readxl. From a clean clone run `renv::restore(project = "papers")`.

### Step 3. Read the original paper first

Download the course paper and any published reanalysis to the scratchpad (keep downloads in their own empty directory), extract text with `pdftotext -layout`, and write `notes/<original>-notes.md` with: the program or experiment and its allocation rule; data and sample; the identification idea in plain words; the key tables with numbers; the reanalysis's changes and verdict; the lessons to carry over; and a variable-by-variable mapping to the Brazilian data. Paper 01's notes drove the framing of the whole paper (OLS benchmark vs causal estimate; state inference choices; show pattern evidence).

### Step 4. Download the microdata with a resumable script

`R/00_download.R` pattern (PNAD Contínua annual first-visit files via PNADcIBGE):

- `get_pnadc(year, interview = 1, vars = <analysis variables>, labels = FALSE, deflator = TRUE, defyear = 2025, design = FALSE, savedir = data/raw, reload = FALSE)`; one year per call; skip years whose `.rds` exists; delete the extracted `.txt` after each year; keep the zips.
- Drop the 200 bootstrap replicate-weight columns (`V1032001`–`V1032200`) before saving; the design object does not use them and they multiply disk use by five.
- Pin the deflator year explicitly (`DEFYEAR`), record it in the README, and confirm which deflator column does what: for annual files `CO1`/`CO1e` bring values to the same year's average prices, `CO2`/`CO2e` to the reference year's prices. Verify by checking that `CO2` equals 1 in the reference year.
- Record the access date and the file version dates printed in the download log (IBGE re-releases files; the 2025-08 versions are the post-Census re-weighting).
- Expect missing years: IBGE released no first-visit files for 2020 and 2021.

Each year took about 30 seconds to download and parse on a fast connection; 13 years in under 10 minutes.

### Step 5. Build the sample with pure, tested functions

- `R/build_functions.R`: `recode_persons()` (types, labels, deflation, a stop if any expected raw column is missing) and `flag_sample()` (filters, the analysis flag, robustness flags such as a wider age range, and a tibble of counts at each filter step). No file I/O.
- `R/01_build.R`: loop over cached years, write `data/clean/persons_<year>.rds` (all persons, because the survey design must be built on the full file and then subset), `sample.rds` and `build_counts.csv`.
- `tests/testthat/test-build.R`: a synthetic fixture shaped like the raw extract; tests for the wage formula, recoding, missing-column error, filter logic, monotone counts, positive weights, and that `svymean` on a design equals the hand-computed weighted mean.
- Anchor every script to the repository root with `here::i_am("papers/NN-slug/R/<script>.R")`; `renv.lock` in `papers/` otherwise makes `here()` resolve to `papers/`.

### Step 6. Reproduce official aggregates before any regression

`R/02_checks.R`: find the published series with `sidrar::search_sidra()` and `info_sidra()`, pull them with `get_sidra()`, recompute them from the design object, and `stop()` if the relative difference exceeds a tolerance set by the source (0.5% for a series computed from the same microdata, 1.5% for one from another supplement rounded to one decimal). Write `output/tables/official_checks.csv` and a Markdown table for the appendix.

When a check fails, find the real reason before calling it an exception. Paper 01's 2022 labour-income gap of 3.3% was not a data revision: IBGE's own report states that its 2020–2022 annual series use fifth-visit files while other years use first-visit files. Read IBGE's *informativo* for the release in question; its footnotes say which visit and which population projection each year uses.

### Step 7. Fit models in one script, report in another

- `R/03_analysis.R` fits and saves everything to `data/clean/results.rds` (tidy coefficient tables, not model objects: a pooled `svyglm` on 1.8 million rows is too large to keep). Re-fitting takes about six minutes; keeping it separate means table and figure fixes cost seconds.
- Design per year: `svydesign(ids = ~upa, strata = ~estrato, weights = ~w, nest = TRUE)` on the full file, then `subset(design, in_sample)`. Pooled: stack the minimal columns of all years and build one design the same way; the same tract in different years becomes one cluster (the master sample rotates: about half the tracts change within three years, nearly all within ten).
- `options(survey.lonely.psu = "adjust")`.
- Year-by-year models, a pooled model with year fixed effects, completed-level dummies, interactions with sex and race (group slopes as linear combinations of coefficients with the full covariance matrix; verified against `svycontrast`), regional subsets with `update(subset(d, region == r), uf_f = droplevels(uf_f))`, and a robustness block that includes the two inference shortcuts (unweighted OLS with HC1; weighted OLS clustered by tract).
- `R/04_report.R` writes tables (`.md` and `.tex`), figures (`.pdf` and `.png`), every estimate as CSV, and `headline.rds` for the paper's inline numbers.

### Step 8. Tables and figures

- `modelsummary`/`datasummary_df` must be given a file path as `output` (`output = "<stem>.md"`); they return table objects, not text.
- Append the Quarto label to the caption line of each Markdown table (`label_md_table(file, "tbl-id")`) so `@tbl-id` cross-references work when the file is included with `{{< include >}}`.
- Keep tables to about seven columns on A4; transpose wide ones (variants as rows).
- Show years as character so they do not print as `2012.00`; four decimals for coefficients whose SEs are below 0.001.
- Figures use `_common/R/theme.R` (validated palette, fixed slot order); keep ggplot subtitles and captions short or they are clipped at the figure width; the paper caption carries the detail.

### Step 9. Write the paper

- Start from `_template/paper.qmd`; `metadata-files: [../_common/format-pdf.yml]`, `bibliography: ../references.bib`, `csl: ../_common/chicago-author-date.csl`.
- A setup chunk reads the CSVs and `headline.rds`; every number in the prose is an inline R expression, never typed.
- Order: introduction (why the question, what is done in plain words, where it sits, the findings, a roadmap), what the original paper and its reanalysis teach, data (survey, sample, checks), method (equation explained, inference explained), results (one subsection per table or figure), robustness, what the numbers cannot tell us, conclusion, references, appendix (counts, checks).
- Style the author asked for: each idea once, in the place it belongs; explain an idea in a sentence before giving the number; cite the source of every borrowed idea (Mincer, Griliches, Card, Hungerford and Solon, Yitzhaki, Katz and Murphy, Lumley, and so on); label descriptive versus causal evidence once, clearly, and do not repeat the warning in every section; English with a Portuguese *Resumo*; JEL codes and keywords.
- Render with `~/.local/bin/quarto render paper.qmd --to pdf` and move `paper.pdf` into `output/`. Never pass `--output-dir output`: Quarto empties that folder, which also holds the tables and figures.
- Keep bibliography author spellings consistent across entries, otherwise citeproc disambiguates with initials ("N. A. Menezes-Filho").
- Check the rendered PDF page by page (`pdftoppm -r 60 -png`), not only the log.

### Step 10. Run everything end to end

`Rscript papers/NN-slug/R/run_all.R` from the repository root: download (cached years skipped), build, unit tests, checks, fit, report, render. Snapshot `shasum` of `output/tables/*` before and after a second run; the diff must be empty. Record runtimes in the paper's README.

### Step 11. Literature review

Run several searches in parallel, in English and Portuguese, on SciELO, RePEc/IDEAS, SSRN, IPEA, ANPEC and journal sites; fetch abstracts and methods sections; for binary PDFs, save and `pdftotext` them locally. Write `notes/literature-review.md`: the closest papers with their data, method and numbers; what each confirms; what the new paper adds and lacks; where each citation goes in the text. Add the entries to `references.bib` with a comment line marking the batch.

### Step 12. Review before sharing

Re-read every script. Recompute the headline coefficient by at least two other routes (weighted `lm`, `srvyr`). Check that subsetting the design keeps the stratum structure. Verify manual contrasts against `svycontrast`. Re-run the main result under an alternative reference group and an alternative sample filter. Measure cluster overlap across years before claiming anything about pooled standard errors. For any failed official check, find the cause in IBGE's documentation. Write `notes/review-<date>.md` with findings ranked by severity, what was verified, what could not be, and a verdict.

### Step 13. Commit and release

Commit at milestones with descriptive messages and the attribution trailer. `.gitignore` excludes `papers/**/data/`, logs, caches and the renv library. Releases follow `PUBLISHING.md`: GitHub release, Zenodo DOI, SSRN, MPRA; arXiv only with a personal endorsement.

## 3. Pitfalls met in Paper 01 and their fixes

| Pitfall | Fix |
|---|---|
| `brew install quarto` needs sudo | install the macOS tarball under `~/.local/opt`, symlink to `~/.local/bin/quarto`; `run_all.R` falls back to that path |
| `quarto render --output-dir output` wiped `output/` (tables and figures lost) | render next to the source and move the PDF; `04_report.R` regenerates all CSVs so a wipe is recoverable |
| `here::here()` resolved to `papers/` after `renv::init()` created `renv.lock` there | `here::i_am("papers/…/R/<script>.R")` at the top of every script and test |
| Parallel shell calls share one working directory; a `cd` in one broke another | absolute paths everywhere; no `cd` in parallel calls |
| PNADcIBGE kept 200 replicate-weight columns (243 columns per year) | drop `^V1032[0-9]{3}$` before saving; 43 columns, under 10 MB per year |
| Deflator columns are `CO1/CO1e/CO2/CO2e/CO3`, not `Habitual/Efetivo` | inspect `deflator_PNADC_<year>.xls`; `CO2` is the reference-year deflator; verify against the official income series |
| IBGE published no first-visit files for 2020–2021 | state it in the data section; leave the gap in every figure |
| Official 2022 labour income differed by 3.3% | IBGE's 2020–2022 published series use fifth-visit files; document as a visit difference, not a revision |
| `modelsummary(..., output = "markdown")` returned an object, `writeLines` failed | pass the file path as `output` |
| Quarto cross-references to included tables did not resolve | append `{#tbl-id}` to the "Table:" caption line |
| ggplot subtitles and captions clipped | shorten; put detail in the Quarto caption |
| Wide tables overflowed A4 | transpose; limit to about seven columns |
| citeproc printed "N. A. Menezes-Filho" | make author spellings identical across bib entries |
| Design-based vs robust SE ratio looked like a clean "clustering" story | within a year the ratio is 1.3; pooled it is 3.4 because tracts are re-used across years and weights are unequal; explain all three parts |
| Zotero returned "Style not found" for the AER CSL | use `chicago-author-date.csl` from the CSL GitHub repository |

## 4. Time budget observed for Paper 01

Planning and web verification, about an hour. Infrastructure and installs, about an hour. Reading the original paper and reanalysis, half an hour. Pipeline to first full run, about three hours including the detours above. Writing and rendering, about two hours. Rewrite for style, one hour. Literature review, one hour. Review, one hour. Machine time: download 6 minutes, build 3, checks 2, fitting 6, report under 1, render 1; the whole `run_all.R` takes 7.5 minutes with cached data.

## 5. Definition of done for a paper

All items in `CHECKLIST.md`, plus: notes on the original paper exist; the literature note positions the paper against the two or three closest studies and the paper cites them; a dated review note exists with no open medium-severity finding; `run_all.R` passes from the repository root; the rendered PDF has been looked at page by page; the author has read it and the text follows the style rules in Step 9.

## 6. File map of a paper folder

```
NN-slug/
  README.md                 question, evidence type, data table with access date, how to run, runtimes, code map
  paper.qmd                 the paper; all numbers inline from output/tables
  notes/                    <original>-notes.md, literature-review.md, review-<date>.md
  R/00_download.R           resumable download, variable selection, deflator pinned
  R/build_functions.R       pure, unit-tested recoding and sample flags
  R/01_build.R              persons_<year>.rds, sample.rds, build_counts.csv
  R/02_checks.R             official aggregates reproduced; stop on failure; documented exceptions
  R/03_analysis.R           fits; saves data/clean/results.rds
  R/04_report.R             tables (.md/.tex), figures, CSVs, headline.rds, cross-ref labels
  R/run_all.R               entry point: download, build, tests, checks, fit, report, render
  tests/testthat/           synthetic-fixture tests
  output/tables, output/figures, output/paper.pdf   committed, small
  data/raw, data/clean      git-ignored, rebuilt by the scripts
```
