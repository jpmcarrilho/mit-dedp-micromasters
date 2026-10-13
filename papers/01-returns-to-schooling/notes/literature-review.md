# Literature review: who has done a similar analysis?

Searched on 2026-10-13 in English and Portuguese (SciELO, RePEc/IDEAS, SSRN, IPEA, ANPEC, World Bank, journal sites). BibTeX keys refer to `papers/references.bib`. Abstracts and methods sections were read; full texts only where open access. Numbers quoted below come from those sources and should be re-checked against the full papers before being cited in the text.

## 1. Closest studies: Mincer returns in Brazil over time

**Ribeiro, Nakabashi and Barros Jr. (2025), *Estudos Econômicos* 55(2)** [`ribeiro2025`] is the closest paper. It estimates Mincer equations on PNAD 1995–2015 and PNAD Contínua 2016–2023 for workers aged 25–64, log hourly wage at 2015 prices (monthly main-job earnings over weekly hours × 4.2), by OLS, with Heckman's selection correction and with Garen's correction for ability and measurement error. Schooling is interacted with experience, race, urban, sector and sex. The authors state that they account for the surveys' stratification, clustering and unequal selection probabilities, citing Lumley (2004) and Moura (2008). Findings: the return fell by about 30 percent between 1995 and 2023 (0.9–1.0 percent a year), almost all of it before 2016; over 2016–2023 the fall is only 1–4 percent in total, with a sharp dip in 2019–2021 attributed to COVID-19 and flat or slightly higher values in 2021–2023. Returns are highest for the most educated group (about 2.3 times the least educated), for White, urban and services workers, and in RS, SC, SP and DF; lowest in AL, MA and PA. Their explanations: state-level school quality (SAEB, IDEB) and the expansion of the supply of educated workers (returns of a group fall as its employment share rises). Differences from Paper 01: they exclude civil servants, the military, Indigenous and Asian respondents and earners above 100 minimum wages, impute two PNADC variables with a neural network, do not say which PNADC file they use, correct for selection, and do not report completed-level premia or official-aggregate checks.

**Cota, Pinho Neto and Alves (2025), *Brazilian Review of Econometrics* 43(1)** [`cota2025`]: quarterly PNAD Contínua 2018Q1–2023Q4, Heckman two-step, wages deflated to 2024Q1 prices, event-time dummies around 2019Q4. Returns remain high, but after the pandemic the return for completed higher education fell by about 7.3 percent nationally, 9.6 percent in the Nordeste and 11.0 percent in the Norte. No mention of survey weights or design in the parts read. Paper 01's lowest linear returns in 2022–2024 and the dip in every group in Figure 3 are the same phenomenon measured on annual first-visit files.

**Rocha da Silva, Esperidião and Santana (2026), *RBERU* 20(3)** [`rochadasilva2026`]: PNAD Contínua 2023, Nordeste states, Mincer with Heckman correction, Trostel-type non-linear extensions and quantile regression. Returns are higher at five and nine years of schooling than nationally and much larger at the top of the conditional wage distribution.

**Detoni (2025), *Empirical Economics Letters* 24(4)** [`detoni2025`]: RAIS 2003–2018, Mincer by year on formal-sector administrative data; returns fell at every level, most at secondary and tertiary.

Earlier trend studies on PNAD: Lam and Schoeni (1993) [`lam1993`], Blom, Holm-Nielsen and Verner (2001) [`blom2001`] (1982–1998, return falling to 12.8 percent by 1998), Menezes-Filho (2001) [`menezesfilho2001`], Barbosa Filho and Pessôa (2008) [`barbosafilho2008`], Menezes-Filho, Fernandes and Picchetti (2006) [`menezesfilho2006`], Ferreira, Firpo and Messina (2022) [`ferreira2022`]. The pattern across all of them is a return above 15 percent in the 1980s and 1990s falling towards 10 percent by the 2010s, which is where Paper 01's series starts.

## 2. The shape of the profile: convexity and sheepskin effects

**Crespo and Reis (2009), *RBE* 63(3)** [`crespo2009`]: PNAD 1982, 1992, 1998, 2004, urban workers aged 25–60, splines and completion dummies at 4, 8, 11 and 15 years. Sheepskin effects fell (secondary 32 to 27 percent, college 31 to 19 percent, 1982–2004) while the log earnings–schooling relation became more convex. Paper 01 picks this up in the 2010s and 2020s: the completion jumps are 0.18 (fundamental), 0.16 (médio) and 0.52 (degree) log points, larger than Crespo and Reis's 2004 values, and the convexity is extreme (about 5, 7 and 20 percent per year across the three segments).

**Moura (2008), *RBE* 62(4)** [`moura2008`] rejects the linearity and separability assumptions of the Mincer equation for Brazil, estimates internal rates of return instead, and finds them up to 14 points below the Mincer coefficient; estimates incorporate the PNAD sample design. This is the strongest Brazilian statement of why the linear coefficient should be read with the level premia beside it, as Paper 01 does.

**Arcand, d'Hombres and Ponde Avena (2003), CERDI WP 2003.26** [`arcand2003`]: Salvador metropolitan region; for White workers the sheepskin effect is the conventional completion premium, for Black workers it comes from admission to university.

**Binelli, Meghir and Menezes-Filho (2008), IFS working paper** [`binelli2008`]: structural model of schooling choice, participation and wages with unobserved ability; changes in returns in the 1990s reflect market prices rather than ability composition, and the expansion at intermediate levels depressed wages there; credit constraints limited progression to college.

**Stefani and Biderman (2009), *Applied Economics* 41(11)** [`stefani2009`]: PNAD 1988 and 1996, quantile regressions by sex and colour with endogeneity correction; returns vary strongly across the distribution.

## 3. Why premia fell: supply, composition, quality, minimum wage

- **Fernández and Messina (2018), *JDE* 135** [`fernandez2018`]: Argentina, Brazil, Chile; the fall in education premia drives lower-tail inequality; supply shifts explain part, demand shifts (minimum wage, commodity boom) the rest.
- **Acosta, Cruces, Galiani and Gasparini (2019), *LAER* 28(1)** [`acosta2019`]: supply–demand framework for Latin America; secondary returns fell throughout; tertiary returns rose in the 1990s, fell sharply in the 2000s and more slowly in the 2010s.
- **Wang (2015), Tulane WP 1525** [`wang2015`]: PNAD 1995–2013; decomposes the fall in the tertiary premium into a price effect of relative supply and a composition effect from lower average quality of recent graduate cohorts.
- **Guanziroli, Jou and Rache (2024), working paper** [`guanziroli2024`]: one million graduates from 42 universities linked to RAIS 2003–2018; the college premium of graduates from a fixed set of established universities rose 24 percent while the overall premium fell 16 percent, so the fall is mostly the entry of lower-ranked institutions; preliminary and incomplete version.
- **Neri and Bonomo (2018), WIDER WP 2018/129** [`neri2018`]: PNAD 1996 and 2014 family-background supplements; measurement error understates returns by 14–32 percent, omitting parents' education overstates them by about 24 percent; the largest fall is at intermediate levels; intergenerational persistence of schooling fell from 0.70 to 0.47.
- **Engbom and Moser (2022), *AER* 112(12)** [`engbom2022`]: the minimum wage explains a large share of the compression of Brazilian earnings, which is the mechanism Paper 01 invokes for the falling premium of every level relative to no schooling.
- **Franca, Machado and Corseuil (2025), *IJED* 114** [`franca2025`]: IV returns to secondary completion for ages 20–24 using school density at age 15, about five times the OLS return; a Duflo-style supply instrument on Brazilian data, relevant to the series' next paper.

## 4. Sex and race

**Vaz (2020), *Cadernos de Pesquisa* 50(177)** [`vaz2020`]: PNAD 1996 and 2014 mobility supplements, employed men, extended Mincer with diploma dummies, parents' education and race interactions. A degree raises earnings about 263 percent for non-Black and 193 percent for Black men (2014); the racial gap narrowed from about 20 to 8 percent, but family background kept its weight. Paper 01's finding that the conditional racial gap widens with schooling (−0.10 log points at 9 years, −0.28 at 16) is consistent with her smaller degree premium for Black workers. Stefani and Biderman (2009) and the quantile literature find the same widening at the top of the distribution.

## 5. Survey design in PNAD and PNAD Contínua analyses

- **Silva, Pessoa and Lila (2002), *Ciência & Saúde Coletiva* 7(4)** [`silva2002`]: design effects in PNAD 1998 between 1.9 and 13.7, mean 5.5; the reference paper on why PNAD cannot be treated as a simple random sample.
- **Pereira, Lima, Lima, Braga and Mendonça (2013), *REC* 17(1)** [`pereira2013`]: PNAD 2009, men, Heckman correction with the sampling plan incorporated; results differ substantially from the simple-random-sample treatment.
- **Resende and Wyllie (2006), *Economia Aplicada* 10(3)** [`resende2006`]: note that the Brazilian returns literature ignores the complex design of PPV and PNAD and leaves the adaptation of methods as an open question.
- **Moreira (2019), UFJF undergraduate thesis** [`moreira2019`]: PNAD Contínua rates with and without the design in Stata; ignoring it underestimates standard errors.
- Ribeiro et al. (2025) and Moura (2008) incorporate the design in Mincer estimation. No paper found reports, for PNAD Contínua Mincer regressions, the side-by-side comparison of design-based, cluster-robust and naive standard errors that Paper 01's Table 6 gives.

## 6. International comparables

**Montenegro and Patrinos (2014), World Bank PRWP 7020** [`montenegro2014`] and **Patrinos (2016), *IZA World of Labor*** [`patrinos2016`]: the same Mincer specification on 819 harmonised surveys from 139 economies; returns cluster tightly, are higher for women, decline over time and are highest for tertiary education, all of which Paper 01 finds for Brazil. Psacharopoulos and Patrinos (2018) [`psacharopoulos2018`] update the global averages.

## 7. Where Paper 01 stands

What the literature already establishes and Paper 01 confirms for 2012–2025: a return near 10 percent after a long decline; a convex profile with large completion effects; higher returns for women and lower for Black and Brown workers; higher returns where educated workers are scarcer (Nordeste); a dip after the pandemic.

What Paper 01 adds:

1. The annual first-visit files for every year released, 2012–2019 and 2022–2025, including the 2025 revision, with all occupied workers (not only employees) and a documented sample.
2. Completed-level premia estimated year by year with design-based confidence intervals, which show that every premium fell by a similar proportion while the linear coefficient stayed flat, and an explanation of why the two facts are consistent.
3. Reproduction of IBGE's published aggregates from the same microdata before estimation, which no paper found does, and which exposed the 2022 discrepancy.
4. The explicit inference comparison (design-based vs cluster-robust vs naive), with the factor-of-three result.
5. A replication package that downloads the data and regenerates every number.

What the closest papers do that Paper 01 does not, and could add in a revision:

- A Heckman selection correction (Ribeiro et al.; Cota et al.; Rocha da Silva et al.; Pereira et al.), at least as a robustness column. The selection equation needs household variables (children, other income) that are in the first-visit file.
- Quantile regressions (Stefani and Biderman; Rocha da Silva et al.) to show where in the distribution the gradient is steepest.
- Family-background or ability corrections (Neri and Bonomo; Vaz; Binelli et al.), which the PNAD Contínua cannot support but which bound the bias discussed in Section 7.
- A state-level link to school quality (Ribeiro et al.), which would explain part of the regional ranking.

## 8. Suggested edits to the paper

- Introduction, first paragraph: add Ribeiro et al. (2025) and Cota et al. (2025) as the most recent estimates and say in one sentence how this paper differs (first-visit files, level premia with design-based intervals, official checks, inference comparison).
- Section 2 or a short "Related work" paragraph: Crespo and Reis (2009) and Moura (2008) for the shape of the profile; Wang (2015), Guanziroli et al. (2024) and Neri and Bonomo (2018) for the composition and family-background explanations; Pereira et al. (2013) and Silva et al. (2002) for the design argument.
- Section 5.2: compare the completion jumps with Crespo and Reis's 2004 values; note Guanziroli et al.'s composition story as an alternative to the supply story for the falling degree premium.
- Section 5.3: cite Vaz (2020) next to the widening racial gap.
- Section 7: cite Neri and Bonomo (2018) for the size of the measurement-error and family-background biases in Brazilian data.

## Sources consulted

- Ribeiro, Nakabashi & Barros Jr. (2025): https://www.scielo.br/j/ee/a/VPKVfks8GZHvKjHRSTPmKqR/?lang=pt
- Cota, Pinho Neto & Alves (2025): https://periodicos.fgv.br/bre/article/view/92343
- Rocha da Silva, Esperidião & Santana (2026): https://revistaaber.org.br/rberu/article/view/1283
- Detoni (2025): https://zenodo.org/records/15276941
- Crespo & Reis (2009): https://www.scielo.br/j/rbe/a/68hszTNBzXnbWRvNbkbgM8x/?lang=en
- Moura (2008): https://ideas.repec.org/a/fgv/epgrbe/v62y2008i4a996.html
- Resende & Wyllie (2006): https://www.scielo.br/j/ecoa/a/vkn4VDW349gBJJNQDMdHb7C/?lang=pt
- Pereira et al. (2013): https://revistas.ufrj.br/index.php/rec/article/view/24129
- Silva, Pessoa & Lila (2002): https://www.scielosp.org/pdf/csc/2002.v7n4/659-670/pt
- Moreira (2019): https://repositorio.ufjf.br/jspui/handle/ufjf/12724
- Vaz (2020): https://www.scielo.br/j/cp/a/hHXnPRJMBd8FbK8Z6KhZZTK/?lang=pt
- Stefani & Biderman (2009): https://ideas.repec.org/a/taf/applec/v41y2009i11p1453-1460.html
- Arcand, d'Hombres & Ponde Avena (2003): https://ideas.repec.org/p/cdi/wpaper/450.html
- Neri & Bonomo (2018): https://www.wider.unu.edu/publication/returns-education-intergenerational-mobility-and-inequality-trends-brazil-0
- Wang (2015): https://ideas.repec.org/p/tul/wpaper/1525.html
- Guanziroli, Jou & Rache (2024): https://papers.ssrn.com/sol3/papers.cfm?abstract_id=7403467
- Binelli, Meghir & Menezes-Filho (2008): https://ifs.org.uk/sites/default/files/output_url_files/binellietal.pdf
- Fernández & Messina (2018): https://ideas.repec.org/p/iza/izadps/dp10718.html
- Acosta, Cruces, Galiani & Gasparini (2019): https://nber.org/papers/w24015
- Franca, Machado & Corseuil (2025): https://ideas.repec.org/a/eee/injoed/v114y2025ics0738059325000537.html
- Blom, Holm-Nielsen & Verner (2001): https://econpapers.repec.org/paper/wbkwbrwps/2686.htm
- Montenegro & Patrinos (2014): https://openknowledge.worldbank.org/handle/10986/20340
- Patrinos (2016): https://wol.iza.org/uploads/articles/278/pdfs/estimating-return-to-schooling-using-mincer-equation.pdf
