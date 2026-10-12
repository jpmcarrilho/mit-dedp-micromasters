# Reading notes: Duflo (2001) and Roodman's reanalysis

Sources read on 2026-10-11: Duflo, E. (2001), "Schooling and Labor Market Consequences of School Construction in Indonesia: Evidence from an Unusual Policy Experiment", *AER* 91(4): 795–813 (page numbers below refer to the journal version); Roodman, D., "Schooling and Labor Market Consequences of School Construction in Indonesia: Comment", arXiv 2207.09036, version dated October 2025.

## 1. The paper in one paragraph

Between 1973–74 and 1978–79 Indonesia built 61,807 primary schools (INPRES SD), about two per 1,000 children aged 5–14 in 1971. Exposure to the program depends on two things an adult cannot choose: year of birth (children aged 12 or older in 1974 had left primary school) and district of birth (more schools went to districts with low enrollment in 1972). Using men born 1950–72 in the 1995 SUPAS intercensal survey matched to district-level school counts, Duflo estimates that each school per 1,000 children raised schooling by 0.12–0.19 years and wages by 1.5–2.7 percent for fully exposed cohorts, which implies 2SLS returns to education of 6.8–10.6 percent, close to the OLS estimate of 7.8 percent (pp. 795, 807, 811).

## 2. Program and allocation rule (pp. 796–797)

- Cost over 500 million 1990 USD, 1.5% of 1973 GDP; schools designed for three teachers and 120 pupils; teachers recruited and paid centrally.
- Allocation rule: schools per district proportional to the number of primary-age children *not enrolled* in 1972; the presidential instructions listed the planned number per district, and a 1983 ministry survey found construction closely matched the plans (footnote 1).
- Table 2 (N = 255 districts): log(INPRES schools) on log(children 5–14) gives 0.78 (0.027) and on log(1 − enrollment rate 1973) gives 0.12 (0.038), R² = 0.78. Both should be near 1 under the rule; the program was "less redistributive than it intended to" (p. 797).

## 3. Data (p. 796, Table 1)

- 1995 SUPAS; men born 1950–1972; N = 152,989; mean schooling 7.98 years. 60,633 work for a wage (45% of the sample; most of the rest are self-employed, so wages are missing for them).
- Matched on *district of birth* (293 districts) to planned schools. Region of birth is not endogenous to the program because everyone in the sample was born before it; 91.5% of IFLS children still lived in their birth district at age 12 (p. 798).

## 4. Identification (pp. 797–799, Table 3)

- Exposure = (age in 1974) × (schools per 1,000 children in region of birth). Children aged 12+ in 1974 are unexposed: under 3% of those born 1950–62 were still in primary school in 1974 (IFLS).
- 2×2 difference-in-differences, wage-earner sample, high vs low program regions (difference in intensity 0.90 schools per 1,000):
  - Education: aged 2–6 vs 12–17 in 1974, DiD = 0.12 (SE 0.089) years → 0.13 years per school.
  - Log wage: DiD = 0.026 (0.015) → 0.029 per school. The Wald return is the ratio of the two.
  - Control experiment (aged 12–17 vs 18–24): DiD 0.034 (0.098) for education and 0.0070 (0.016) for wages, "very close to 0" but imprecise.
- Threats named in the text: mean reversion in regions with low initial enrollment; other oil-boom programs allocated similarly (handled with cohort × 1971 enrollment and cohort × water-and-sanitation-program controls); general-equilibrium effects on returns.

## 5. Regression framework and main estimates (pp. 799–806, Tables 4–5)

- Equation (1): S_ijk = c + α_j + β_k + (P_j T_i)γ + (C_j T_i)δ + ε, with region-of-birth and cohort fixed effects; C_j includes the number of children aged 5–14 in 1971 (always interacted with cohort dummies), the 1971 enrollment rate and the water-and-sanitation allocation (columns 2–3).
- Table 4, panel A (aged 2–6 vs 12–17): education 0.124 (0.025), 0.15, 0.188 in the whole sample (N = 78,470); 0.196–0.259 among wage earners; log hourly wage 0.0147 (0.0073), 0.0172, 0.0270. Panel B control experiment: 0.0093 (0.026) and smaller, never significant.
- Unrestricted reduced form (equations 2 and 6): one interaction per age-in-1974 dummy. Coefficients are flat around zero for ages ≥ 12 and rise for younger cohorts (Figures 1 and 3); education and wage coefficients track each other. These are the "fingerprints" that Roodman later finds partly robust.
- Restricted estimates (Table 5, columns 7–9): one school per 1,000 children raised 1995 wages of those aged 2 in 1974 by 1.6–4.0 percent; at the mean 1.89 schools this is a 3–7 percent wage gain.

## 6. Returns to education (pp. 806–808, Table 7)

- OLS of log hourly wage on years of education with region and cohort effects: 0.0776 (0.00062), unaffected by controls; log monthly earnings 0.0698. Duflo notes this is below older Indonesian estimates (World Bank 1990: 19% in 1982 falling to 10% in 1986), consistent with returns falling as education expands.
- 2SLS with year-of-birth × intensity instruments: 0.0675 (0.028), 0.0809 (0.027), 0.106 (0.022), 0.0908 (0.054 with propensity-score controls); single-instrument versions 0.0752–0.104. Over-identification F in brackets ≈ 0.9.
- Conclusion drawn: 2SLS "close to and not significantly different from the OLS estimates", so no support for the view that OLS returns in developing countries are biased upward by family background (p. 811); also unlike the IV > OLS pattern in industrialized countries.
- Quality vs quantity (IV.B): pupil/teacher ratio changes unrelated to school counts; no program effect on those with 9+ years, so wages of that group would have revealed quality effects. Selection (IV.D): only 45% earn a wage; education raises wage-sector participation (2SLS 0.10); earnings imputed for the self-employed from SUSENAS cells; propensity-score controls.

## 7. Conclusion numbers (p. 811)

+0.25 to 0.40 years of education on average; +12 percentage points in the probability of completing primary school; +3 to 5.4 percent in wages; returns 6.8–10.6 percent. Duflo stresses the results "need not generalize to other contexts".

## 8. Roodman's reanalysis (arXiv 2207.09036)

Main changes: (1) correcting data-entry errors in baseline variables, affecting about 10% of observations; (2) clustering standard errors by regency, the geographic unit of treatment (the original SEs are classical); (3) adding later surveys to follow the cohorts into prime working ages; (4) weak-identification-robust inference (Kleibergen–Paap, Anderson–Rubin with wild cluster bootstrap); (5) examining survey weights, which Duflo's code applied in the 2×2 DiD but not in the two-way fixed-effects regressions, a choice the original text does not discuss; (6) questioning the cohort × 1971-population controls, which are unusual, applied inconsistently and motivated in the working paper by their effect on results.

Findings: headline estimates from the 1995 follow-up "are generally not robust to the revisions"; returns to schooling "are weakly identified" and "appear almost impossible to measure with any precision"; yet the fingerprints (impacts only in expected cohorts and grade levels, positive kink-based estimates) persist, so the best explanation remains causal, with "certainty [that] is low" (Conclusion, pp. 46–47 of the preprint).

## 9. What this means for Paper 1 (Brazil)

- **What P1 replicates.** The OLS Mincer benchmark that Duflo reports first in Table 7 and compares her IV estimates against. P1 estimates that benchmark for Brazil with inference that respects the survey design, across 2012–2024 and across groups. It makes no causal claim; the paper says so in the abstract.
- **Lessons carried over from the reanalysis.** State every inference choice in the text (weights, strata, PSUs, SE type), pre-list controls and keep them fixed, report the selected sample (who has earnings), and show pattern evidence rather than one coefficient: returns by completed level (sheepskin effects at 4, 8, 11 and 15 years) and the year-by-year trend.
- **Why the trend matters.** Duflo reads her lower OLS return as the result of educational expansion. Brazil expanded schooling fast after the 1990s, so a falling or flattening coefficient over 2012–2024 is the Brazilian counterpart of that observation.
- **An advantage of PNAD Contínua.** Earnings are observed for the self-employed and informal workers, not only wage employees, so the selection that forced Duflo's imputation can be studied directly (formal only vs all occupied).
- **What a Duflo-style design would need in Brazil.** A documented allocation rule (the FUNDEF 1998 per-pupil redistribution is the closest analogue), region of *birth* (available in the 2010 and 2022 Censuses, not in PNAD Contínua, which records state of residence only) and many treatment clusters (municipalities, not 27 states). That is a separate paper.
- **Variable mapping.** Log hourly wage (SUPAS) ↔ habitual earnings in the main job divided by hours in the main job (VD4016, V4039); years of education ↔ VD3005; cohort ↔ age (V2009); region of birth ↔ not available.
