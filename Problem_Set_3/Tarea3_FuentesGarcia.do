/******************************************************************************************
* AUTOR: Daniel Fuentes (Github: danifuentesga )
* FECHA: 21-sep-2025
* TEMA: Tarea 3
* NOTA: Decimales redondeados a dos
******************************************************************************************/

// DEFINIR DIRECTORIO GLOBAL DE TRABAJO
global basedir "C:\Users\danif\Colmex maestria\TERCER SEMESTRE\MICROECONOMETRIA EPS\TAREAS\TAREA 3"

//# PROBLEMA A) Tablas descriptivas Tratados y No Tratados (NSW)

//## PASO A1: Cargar base
use "$basedir\nsw_data.dta", clear

//## PASO A2: (Opcional en consola) Descriptivos por tratamiento
tabstat age education black hispanic married nodegree RE74 RE75 RE78, ///
    by(treatment) stat(mean sd min max n) col(stat)

//## PASO A3: Crear carpeta RESULTADOS
cap mkdir "$basedir\RESULTADOS"

//## PASO A4: Exportar tablas LaTeX minimalistas (tratados y controles)

// Variables y nombres bonitos (incluye RE78 una sola vez)
local vars  age education black hispanic married nodegree RE74 RE75 RE78
local names "Edad Educación Negro Hispano Casado "Sin Grado" RE74 RE75 RE78"

// ---- Tratados (treatment==1)
file open ft using "$basedir\RESULTADOS\A_DESCRIPTIVE_TREATED.tex", write replace
file write ft "\begin{tabular}{lccccc}" _n "\hline" _n ///
              "Variable & Media & Desv.Est. & Min & Max & N \\\\" _n "\hline" _n
local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly summarize `v' if treatment==1
    local mean : display %9.2f r(mean)
    local sd   : display %9.2f r(sd)
    local min  : display %9.2f r(min)
    local max  : display %9.2f r(max)
    local n    : display %9.0f r(N)
    file write ft "`nice' & `mean' & `sd' & `min' & `max' & `n' \\\\" _n
    local ++i
}
file write ft "\hline" _n "\end{tabular}" _n
file close ft

// ---- Controles (treatment==0)
file open fc using "$basedir\RESULTADOS\A_DESCRIPTIVE_CONTROL.tex", write replace
file write fc "\begin{tabular}{lccccc}" _n "\hline" _n ///
              "Variable & Media & Desv.Est. & Min & Max & N \\\\" _n "\hline" _n
local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly summarize `v' if treatment==0
    local mean : display %9.2f r(mean)
    local sd   : display %9.2f r(sd)
    local min  : display %9.2f r(min)
    local max  : display %9.2f r(max)
    local n    : display %9.0f r(N)
    file write fc "`nice' & `mean' & `sd' & `min' & `max' & `n' \\\\" _n
    local ++i
}
file write fc "\hline" _n "\end{tabular}" _n
file close fc

//# PROBLEMA B) Igualdad de medias en covariables entre tratados y controles

//## PASO B1: Definir variables y etiquetas
local vars  age education black hispanic married nodegree RE74 RE75 RE78
local names `"Edad Educación Negro Hispano Casado "Sin Grado" RE74 RE75 RE78"'

//## PASO B2: Exportar tabla con medias, t y p
file open fb using "$basedir\RESULTADOS\B_TTEST.tex", write replace
file write fb "\begin{tabular}{lcccc}" _n "\hline" _n
file write fb "Variable & Media Control & Media Tratado & t & p \\\\" _n "\hline" _n

local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly ttest `v', by(treatment)
    local mc : display %9.2f r(mu_1)   // media grupo control
    local mt : display %9.2f r(mu_2)   // media grupo tratado
    local t  : display %9.2f r(t)      // estadístico t
    local p  : display %9.3f r(p)      // valor p
    file write fb "`nice' & `mc' & `mt' & `t' & `p' \\\\" _n
    local ++i
}

file write fb "\hline" _n "\end{tabular}" _n
file close fb

//# PROBLEMA C) Estimación del TOT experimental por regresión

//## PASO C1: Estimar TOT sin controles
reg RE78 treatment, vce(robust)
estimates store C_nocontrols

//## PASO C2: Generar variables cuadráticas
gen age2 = age^2
gen education2 = education^2
gen re752 = RE75^2
gen re742 = RE74^2

//## PASO C3: Estimar TOT con controles
reg RE78 treatment age age2 education education2 black hispanic married RE75 re752 RE74 re742, vce(robust)
estimates store C_controls

//## PASO C4: Exportar resultados a LaTeX
file open fc using "$basedir\RESULTADOS\C_TOT_REG.tex", write replace
file write fc "\begin{tabular}{lcc}" _n "\hline" _n
file write fc "Modelo & Coef. Tratamiento & Error Est. \\\\" _n "\hline" _n

// Modelo sin controles
mat b = e(b)
mat V = e(V)
local beta : display %9.2f b[1,"treatment"]
local se   : display %9.2f sqrt(V[1,1])
file write fc "Sin controles & `beta' & `se' \\\\" _n

// Modelo con controles
estimates restore C_controls
mat b = e(b)
mat V = e(V)
local beta : display %9.2f b[1,"treatment"]
local se   : display %9.2f sqrt(V[1,1])
file write fc "Con controles & `beta' & `se' \\\\" _n

file write fc "\hline" _n "\end{tabular}" _n
file close fc

//# PROBLEMA D) Replicar (a)–(c) con cps_data.dta

//## PASO D1: Cargar base CPS
use "$basedir\cps_data.dta", clear

//## PASO D2: Crear carpeta RESULTADOS
cap mkdir "$basedir\RESULTADOS"

//## PASO D3: Definir variables y nombres bonitos
local vars  age education black hispanic married nodegree RE74 RE75 RE78
local names `"Edad Educación Negro Hispano Casado "Sin Grado" RE74 RE75 RE78"'

//====================================================
//## PASO D4: Exportar descriptivos (tratados y controles, como en a)
//====================================================

// ---- Tratados (treatment==1)
file open ft using "$basedir\RESULTADOS\D_DESCRIPTIVE_TREATED.tex", write replace
file write ft "\begin{tabular}{lccccc}" _n "\hline" _n
file write ft "Variable & Media & Desv.Est. & Min & Max & N \\\\" _n "\hline" _n
local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly summarize `v' if treatment==1
    local mean : display %9.2f r(mean)
    local sd   : display %9.2f r(sd)
    local min  : display %9.2f r(min)
    local max  : display %9.2f r(max)
    local n    : display %9.0f r(N)
    file write ft "`nice' & `mean' & `sd' & `min' & `max' & `n' \\\\" _n
    local ++i
}
file write ft "\hline" _n "\end{tabular}" _n
file close ft

// ---- Controles (treatment==0)
file open fc using "$basedir\RESULTADOS\D_DESCRIPTIVE_CONTROL.tex", write replace
file write fc "\begin{tabular}{lccccc}" _n "\hline" _n
file write fc "Variable & Media & Desv.Est. & Min & Max & N \\\\" _n "\hline" _n
local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly summarize `v' if treatment==0
    local mean : display %9.2f r(mean)
    local sd   : display %9.2f r(sd)
    local min  : display %9.2f r(min)
    local max  : display %9.2f r(max)
    local n    : display %9.0f r(N)
    file write fc "`nice' & `mean' & `sd' & `min' & `max' & `n' \\\\" _n
    local ++i
}
file write fc "\hline" _n "\end{tabular}" _n
file close fc

//====================================================
//## PASO D5: Prueba de igualdad de medias (como en b)
//====================================================
file open ft using "$basedir\RESULTADOS\D_TTEST.tex", write replace
file write ft "\begin{tabular}{lcccc}" _n "\hline" _n
file write ft "Variable & Media Control & Media Tratado & t & p \\\\" _n "\hline" _n

local i = 1
foreach v of local vars {
    local nice : word `i' of `names'
    quietly ttest `v', by(treatment)
    local mc : display %9.2f r(mu_1)
    local mt : display %9.2f r(mu_2)
    local t  : display %9.2f r(t)
    local p  : display %9.3f r(p)
    file write ft "`nice' & `mc' & `mt' & `t' & `p' \\\\" _n
    local ++i
}
file write ft "\hline" _n "\end{tabular}" _n
file close ft

//====================================================
//## PASO D6: Estimación del TOT experimental por regresión (como en c)
//====================================================

// Sin controles
reg RE78 treatment, vce(robust)
estimates store D_nocontrols

// Con controles
gen age2 = age^2
gen education2 = education^2
gen re752 = RE75^2
gen re742 = RE74^2

reg RE78 treatment age age2 education education2 black hispanic married RE75 re752 RE74 re742, vce(robust)
estimates store D_controls

// Exportar tabla con coeficiente de tratamiento
file open fr using "$basedir\RESULTADOS\D_TOT_REG.tex", write replace
file write fr "\begin{tabular}{lcc}" _n "\hline" _n
file write fr "Modelo & Coef. Tratamiento & Error Est. \\\\" _n "\hline" _n

// Modelo sin controles
estimates restore D_nocontrols
mat b = e(b)
mat V = e(V)
local beta : display %9.2f b[1,"treatment"]
local se   : display %9.2f sqrt(V[1,1])
file write fr "Sin controles & `beta' & `se' \\\\" _n

// Modelo con controles
estimates restore D_controls
mat b = e(b)
mat V = e(V)
local beta : display %9.2f b[1,"treatment"]
local se   : display %9.2f sqrt(V[1,1])
file write fr "Con controles & `beta' & `se' \\\\" _n

file write fr "\hline" _n "\end{tabular}" _n
file close fr

//# PROBLEMA E) Propensity score en CPS con pscore (Becker & Ichino, 2002)

//## PASO E1: Instalar pscore suite (Becker & Ichino)
net from http://www.stata-journal.com/software/sj5-3
net install st0026_2

which pscore

//## PASO E2: Crear variables cuadráticas y adicionales (si no existen)

// Edad al cuadrado
cap confirm variable age2
if _rc gen age2 = age^2

// Educación al cuadrado
cap confirm variable education2
if _rc gen education2 = education^2

// RE75 al cuadrado
cap confirm variable re752
if _rc gen re752 = RE75^2

// RE74 al cuadrado
cap confirm variable re742
if _rc gen re742 = RE74^2


//## PASO E3: Estimar propensity score con pscore
local xvars age age2 education education2 black hispanic married RE75 re752 RE74 re742

pscore treatment `xvars', pscore(pscore) blockid(blockid) comsup

//## PASO E4: Refinar especificación para lograr balance

// Crear interacciones simples (si no existen)
cap gen age_educ   = age*education
cap gen re74_re75  = RE74*RE75

// Borrar variables anteriores de pscore y blockid
cap drop pscore blockid

// Re-estimar pscore con interacciones añadidas
local xvars age age2 education education2 black hispanic married RE75 re752 RE74 re742 age_educ re74_re75
pscore treatment `xvars', pscore(pscore) blockid(blockid) comsup

//## PASO E5 corregido: Exportar Probit dividido en dos paneles lado a lado

// Primero guardamos el modelo completo
probit treatment age age2 education education2 black hispanic married ///
    RE75 re752 RE74 re742 age_educ re74_re75
eststo fullmodel

// Guardar dos mitades para la exportación
// Panel A (primeras covariables)
eststo panelA: probit treatment age age2 education education2 black hispanic married

// Panel B (resto de covariables + constante)
eststo panelB: probit treatment RE75 re752 RE74 re742 age_educ re74_re75

// Exportar en formato LaTeX lado a lado
esttab panelA panelB using "$basedir\RESULTADOS\E_PS.tex", ///
    se b(%9.3f) se(%9.3f) star(* 0.10 ** 0.05 *** 0.01) ///
    replace label nonumber noobs compress booktabs ///
    title("Determinantes del Tratamiento: Modelo Probit para el Propensity Score") ///
    mtitle("Panel A" "Panel B") collabels(none)
	

//# PROBLEMA F) 
*Histogramas del Propensity Score (tratados vs. controles)

//## PASO F1: Histograma grupo control (naranja metálico, 20% opaco)
histogram pscore if treatment==0, width(0.05) frequency addlabels ///
    fcolor("255 59 0%30") lcolor("255 59 0") ///
    xtitle("Propensity Score") ytitle("Frecuencia")

graph export "$basedir\RESULTADOS\F_HIST_CONTROL.png", replace

//## PASO F2: Histograma grupo tratado (azul pastel, 20% opaco)
histogram pscore if treatment==1, width(0.05) frequency addlabels ///
    fcolor("100 149 237%30") lcolor("100 149 237") ///
    xtitle("Propensity Score") ytitle("Frecuencia")

graph export "$basedir\RESULTADOS\F_HIST_TREATED.png", replace

//## PASO F3: Histogramas solapados en un solo gráfico
twoway ///
    (histogram pscore if treatment==0, width(0.05) fcolor("255 59 0%20") lcolor("255 59 0")) ///
    (histogram pscore if treatment==1, width(0.05) fcolor("100 149 237%20") lcolor("100 149 237")), ///
    legend(label(1 "Controles") label(2 "Tratados")) ///
    xtitle("Propensity Score") ytitle("Frecuencia")

graph export "$basedir\RESULTADOS\F_HIST_OVERLAY.png", replace

//# PROBLEMA G) Diagnóstico fino de overlap

//## PASO G1: Exportar tabla de rangos de Propensity Score

file open fr using "$basedir\RESULTADOS\G_PS_SUMMARY.tex", write replace
file write fr "\begin{tabular}{lccccc}" _n
file write fr "\hline" _n
file write fr "Grupo & N & Media & Desv.Est. & Mínimo & Máximo \\\\" _n
file write fr "\hline" _n

// Controles
summarize pscore if treatment==0
local n_c    : display %9.0f r(N)
local mean_c : display %9.3f r(mean)
local sd_c   : display %9.3f r(sd)
local min_c  : display %9.6f r(min)
local max_c  : display %9.6f r(max)
file write fr "Controles & `n_c' & `mean_c' & `sd_c' & `min_c' & `max_c' \\\\" _n

// Tratados
summarize pscore if treatment==1
local n_t    : display %9.0f r(N)
local mean_t : display %9.3f r(mean)
local sd_t   : display %9.3f r(sd)
local min_t  : display %9.6f r(min)
local max_t  : display %9.6f r(max)
file write fr "Tratados & `n_t' & `mean_t' & `sd_t' & `min_t' & `max_t' \\\\" _n

file write fr "\hline" _n
file write fr "\end{tabular}" _n
file close fr



//## PASO G2: Graficar densidades kernel por grupo
twoway ///
    (kdensity pscore if treatment==0, lcolor("255 59 0") lwidth(medthick) ///
        fcolor("255 59 0%20") lpattern(solid) ///
        legend(label(1 "Controles"))) ///
    (kdensity pscore if treatment==1, lcolor("100 149 237") lwidth(medthick) ///
        fcolor("100 149 237%20") lpattern(solid) ///
        legend(label(2 "Tratados"))), ///
    xtitle("Propensity Score") ytitle("Densidad") ///
    legend(pos(12) ring(0) col(2))

//## PASO G3: Guardar gráfica
graph export "$basedir\RESULTADOS\G_KERNEL_OVERLAP.png", replace



//# PROBLEMA H) 
*Estimación del TOT con soporte común

count if treatment==1 & comsup==1
count if treatment==0 & comsup==1

* Número de observaciones antes
count

//## PASO H1: Mantener solo soporte común
keep if comsup==1


* Número de observaciones después
count

* Rango de PS en tratados (T)
summarize pscore if treatment==1, detail

* Rango de PS en controles (C)
summarize pscore if treatment==0, detail

//## PASO H2: Estratificación manual (bloques de pscore)
reg RE78 treatment i.blockid, vce(robust)

//## PASO H3: Estratificación automática (atts)
atts RE78 treatment, pscore(pscore) blockid(blockid)

//## PASO H4: Vecino más cercano (attnd)
attnd RE78 treatment, pscore(pscore)

//## PASO H5: Kernel matching (attk)
attk RE78 treatment, pscore(pscore)

//## PASO H6: Radius matching (attr)
attr RE78 treatment, pscore(pscore)

// Radius matching con r = 0.001
attr RE78 treatment, pscore(pscore) radius(0.001)

// Radius matching con r = 0.0001
attr RE78 treatment, pscore(pscore) radius(0.0001)

// Radius matching con r = 0.00001
attr RE78 treatment, pscore(pscore) radius(0.00001)


*** EXPORTAR MANUEMENTE LOS RESULTADOS EN UNA TABLa***

//# PORBLEMA I)

* Número de observaciones antes del trimming Crump
count

//## PASO I1: Definir muestra Crump (0.1 < ps < 0.9)
keep if pscore > 0.1 & pscore < 0.9

* Número de observaciones después del trimming
count

* Resumen de PS para tratados y controles
summarize pscore if treatment==1, detail
summarize pscore if treatment==0, detail


//## PASO I2: Estratificación manual
reg RE78 treatment i.blockid, vce(robust)

//## PASO I3: Estratificación automática (atts)
atts RE78 treatment, pscore(pscore) blockid(blockid)

//## PASO I4: Vecino más cercano
attnd RE78 treatment, pscore(pscore)

//## PASO I5: Kernel matching
attk RE78 treatment, pscore(pscore)

//## PASO I6: Radius matching
attr RE78 treatment, pscore(pscore)

// Radius matching con r = 0.001
attr RE78 treatment, pscore(pscore) radius(0.001)

// Radius matching con r = 0.0001
attr RE78 treatment, pscore(pscore) radius(0.0001)

// Radius matching con r = 0.00001
attr RE78 treatment, pscore(pscore) radius(0.00001)


//# PROBLEMA J) 

//## PASO J1: Placebo bajo soporte común clásico (comsup)
// Estratificación manual
reg RE75 treatment i.blockid if comsup==1, vce(robust)

// Estratificación automática
atts RE75 treatment if comsup==1, pscore(pscore) blockid(blockid)

// Vecino más cercano
attnd RE75 treatment if comsup==1, pscore(pscore)

// Kernel matching
attk RE75 treatment if comsup==1, pscore(pscore)

// Radius matching
attr RE75 treatment if comsup==1, pscore(pscore)

// AIPW (Augmented IPW)
teffects aipw (RE75 age age2 education education2 black hispanic married re752 RE74 re742) ///
              (treatment), atet vce(robust)
			  
keep if pscore > 0.1 & pscore < 0.9

// AIPW
teffects aipw (RE75 age age2 education education2 black hispanic married re752 RE74 re742) ///
              (treatment), atet vce(robust)


//## PASO J2: Placebo bajo trimming tipo Crump (0.1 < ps < 0.9)
// Estratificación manual
reg RE75 treatment i.blockid if pscore>0.1 & pscore<0.9, vce(robust)

// Estratificación automática
atts RE75 treatment if pscore>0.1 & pscore<0.9, pscore(pscore) blockid(blockid)

// Vecino más cercano
attnd RE75 treatment if pscore>0.1 & pscore<0.9, pscore(pscore)

// Kernel matching
attk RE75 treatment if pscore>0.1 & pscore<0.9, pscore(pscore)

// Radius matching
attr RE75 treatment if pscore>0.1 & pscore<0.9, pscore(pscore)


//# PROBLEMA K) 

*Estimadores doblemente robustos (DR)

//## PASO K: Estimación bajo soporte común clásico (pscore)

// Mantener soporte común
keep if comsup==1

// AIPW (Augmented IPW)
teffects aipw (RE78 age age2 education education2 black hispanic married RE75 re752 RE74 re742) ///
              (treatment), atet vce(robust)
			  
tabulate treatment if comsup==1


// IPWRA (Inverse Probability Weighted Regression Adjustment)
teffects ipwra (RE78 age age2 education education2 black hispanic married RE75 re752 RE74 re742) ///
               (treatment age age2 education education2 black hispanic married RE75 re752 RE74 re742), atet vce(robust)

tabulate treatment if comsup==1
			   
//## PASO K2: Estimación bajo trimming tipo Crump (0.1 < pscore < 0.9)

keep if pscore > 0.1 & pscore < 0.9

// AIPW
teffects aipw (RE78 age age2 education education2 black hispanic married RE75 re752 RE74 re742) ///
              (treatment), atet vce(robust)
			  
tabulate treatment if comsup==1


// IPWRA
teffects ipwra (RE78 age age2 education education2 black hispanic married RE75 re752 RE74 re742) ///
               (treatment age age2 education education2 black hispanic married RE75 re752 RE74 re742), atet vce(robust)
			   
		tabulate treatment if comsup==1	  
			 


















