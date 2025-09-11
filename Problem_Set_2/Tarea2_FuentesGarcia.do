/******************************************************************************************
* AUTOR: Daniel Fuentes (Github: danifuentesga )
* FECHA: 01-sep-2025
* TEMA: Tarea 2
* NOTA: Decimales redondeados a dos
******************************************************************************************/

*    Empezamos con la crónica del dofile que corre sin miedo 
*    si falla, deja tu ofrenda a Angrist en forma de pvalues


// DEFINIR DIRECTORIO GLOBAL DE TRABAJO
global basedir "C:\Users\danif\Colmex maestria\TERCER SEMESTRE\MICROECONOMETRIA EPS\TAREAS\TAREA 2"


//#PARTE 2 
//## a) Replicación de Tabla 2 - Glewwe, Ilias y Kremer (2010)
//### Panel A: Regresiones largas con tratamiento e interacción

/******************************************************************************************
* PANEL A - REGRESIONES LARGAS POR AÑO (CORREGIDO)
* Se replican las columnas (1) a (4) del Panel A en la Tabla 2 del artículo.
* Variable dependiente: t (test scores)
* Variable clave: inc (escuela con incentivos)
* Controles: sexdum, dummies geográficos (d1-d7), y dummies por grado x materia
* Errores agrupados por escuela (cluster(s))
******************************************************************************************/

//#### PASO 1: Cargar base de datos
*------------------------------------------------------------------------------------------*
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear
//#### PASO 2: Filtrar sólo observaciones relevantes para Panel A
*------------------------------------------------------------------------------------------*
keep if table2 == "A"

//#### PASO 3: Ejecutar regresiones separadas por año escolar
*------------------------------------------------------------------------------------------*
* Esta sección replica las columnas (1)-(4) del Panel A
* Se corre una regresión para cada valor de year (0 a 3)
* Variable dependiente: t
* Variable de tratamiento: inc
* Controles: sexdum, ubicación geográfica, grado x materia
* Errores robustos agrupados a nivel de escuela (variable s)
*------------------------------------------------------------------------------------------*

foreach y in 0 1 2 3 {

    display "======================================================================================"
    display "REGRESIÓN PANEL A - AÑO `y'"
    display "Variable dependiente: t | Año escolar: `y' | Variable de interés: inc"
    display "======================================================================================"

    reg t inc sexdum d1-d7 ///
        j4k1-j4k7 j5k1-j5k7 j6k1-j6k7 j7k1-j7k7 j8k1-j8k7 ///
        if year == `y', cluster(s)

}

//#### PASO 4: Guardar resultados de Panel A en eststo
*------------------------------------------------------------------------------------------*
* Creamos 4 regresiones (una por año) y guardamos cada modelo con eststo
* Luego exportamos la tabla resumen con coef, error estándar y obs
*------------------------------------------------------------------------------------------*

eststo clear

foreach y in 0 1 2 3 {
    
    eststo year`y': reg t inc sexdum d1-d7 ///
        j4k1-j4k7 j5k1-j5k7 j6k1-j6k7 j7k1-j7k7 j8k1-j8k7 ///
        if year == `y', cluster(s)

}

* Exportamos tabla tipo Panel A con solo variable inc
esttab year0 year1 year2 year3 using "panel_a.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel A. Dependent variable: score on formula used to reward teachers") ///
    replace
	

//### PANEL B: Participación en examen gubernamental
/******************************************************************************************
* PANEL B - tmock como variable dependiente
* Controles: sexdum y std
* Filtro: table2 == "B C E" (un solo string)
* Para year == 0: limitar a grados 4 a 8
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar Panel B (según instrucciones)
keep if table2 == "B C E"

//#### PASO 3: Limitar grados 4–8 solo en año 0
gen keep_obs = 1
replace keep_obs = 0 if year == 0 & (std < 4 | std > 8)
keep if keep_obs == 1

//#### PASO 4: Estimar regresiones por año
eststo clear

foreach y in 0 1 2 3 {
    
    count if year == `y'
    if r(N) > 0 {
        eststo year`y': reg tmock inc sexdum std ///
            if year == `y', cluster(s)
    }
    else {
        display "No hay observaciones para year == `y'"
    }

}

//#### PASO 5: Exportar Panel B en .tex
esttab year0 year1 year2 year3 using "$basedir\panel_b.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel B. Dependent variable: take government exam") ///
    replace
	
//### PANEL C: International Child Support (ICS)
/******************************************************************************************
* PANEL C - tics como variable dependiente
* Controles: sexdum y std
* Filtro: table2 == "B C E" (un solo string)
* Para year == 0: limitar a grados 4 a 8
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar Panel B (según instrucciones)
keep if table2 == "B C E"

//#### PASO 3: Limitar grados 4–8 solo en año 0
gen keep_obs = 1
replace keep_obs = 0 if year == 0 & (std < 4 | std > 8)
keep if keep_obs == 1

//#### PASO 4: Estimar regresiones por año
eststo clear

foreach y in 0 1 2 3 {
    
    count if year == `y'
    if r(N) > 0 {
        eststo year`y': reg tics inc sexdum std ///
            if year == `y', cluster(s)
    }
    else {
        display "No hay observaciones para year == `y'"
    }

}

//#### PASO 5: Exportar Panel B en .tex
esttab year0 year1 year2 year3 using "$basedir\panel_c.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel C. Dependent variable: International Child Support") ///
    replace
	
	
//### PANEL D: Abandono escolar
/******************************************************************************************
* PANEL D - dropout como variable dependiente
* Controles: solo sexdum
* Filtro: table2 == "D"
* Sin restricciones por grado
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar para Panel D
keep if table2 == "D"

//#### PASO 3: Estimar regresiones por año
eststo clear
local models ""

foreach y in 0 1 2 3 {
    count if year == `y'
    if r(N) > 0 {
        eststo year`y': reg dropout inc sexdum if year == `y', cluster(s)
        local models `models' year`y'
    }
    else {
        display "No hay observaciones para year == `y'"
    }
}

//#### PASO 4: Exportar Panel D a archivo .tex
if "`models'" != "" {
    esttab `models' using "$basedir\panel_d.tex", ///
        keep(inc) ///
        se star(* 0.10 ** 0.05 *** 0.01) ///
        label b(3) se(3) ///
        compress nomtitle nonotes ///
        title("Panel D. Dependent variable: dropping out (linear probability model)") ///
        replace
}
else {
    display "No se estimó ningún modelo — no se genera archivo .tex"
}



//### PANEL E: Presentó examen si estaba inscrito
/******************************************************************************************
* PANEL E - tmock como variable dependiente
* Controles: sexdum y std
* Filtro: table2 == "B C E"
* Restricción 1: std entre 4 y 8 para todos los años
* Restricción 2: excluir alumnos que dejaron la escuela en año 1 (sstdd98v4) y año 2 (sstdd99v3)
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar muestra B C E (como en Panel B/C)
keep if table2 == "B C E"

//#### PASO 3: Limitar a grados 4 a 8 para todos los años
keep if std >= 4 & std <= 8

//#### PASO 4: Excluir alumnos que abandonaron en año 1 y 2
gen keep_enrolled = 1
replace keep_enrolled = 0 if (year == 1 & inlist(sstd98v4, 55, 66, 77))
replace keep_enrolled = 0 if (year == 2 & inlist(sstd99v3, 55, 66, 77))
keep if keep_enrolled == 1

//#### PASO 5: Estimar regresiones por año
eststo clear
local models ""

foreach y in 0 1 2 3 {
    count if year == `y'
    if r(N) > 0 {
        eststo year`y': reg tmock inc sexdum std if year == `y', cluster(s)
        local models `models' year`y'
    }
    else {
        display "No hay observaciones para year == `y'"
    }
}

//#### PASO 6: Exportar tabla .tex para Panel E
if "`models'" != "" {
    esttab `models' using "$basedir\panel_e.tex", ///
        keep(inc) ///
        se star(* 0.10 ** 0.05 *** 0.01) ///
        label b(3) se(3) ///
        compress nomtitle nonotes ///
        title("Panel E. Dependent variable: take government exam if enrolled") ///
        replace
}
else {
    display "No se estimó ningún modelo — no se genera archivo .tex"
}


//## b) Replicación de Tabla 2 - Glewwe, Ilias y Kremer (2010) SIN CONTROLES 

//### PANEL A - REGRESIONES CORTAS SIN CONTROLES

use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear
keep if table2 == "A"

eststo clear
foreach y in 0 1 2 3 {
    eststo year`y': reg t inc if year == `y', cluster(s)
}

esttab year0 year1 year2 year3 using "$basedir\panel_a_short.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel A. Dependent variable: test scores (no controls)") ///
    replace


//### PANEL B (CORTO): Participación en examen gubernamental — sin controles
/******************************************************************************************
* PANEL B (corto) - tmock como variable dependiente
* Sin controles (solo variable de tratamiento inc)
* Filtro: table2 == "B C E"
* Restricción para year == 0: limitar a grados 4 a 8
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar muestra según instrucciones
keep if table2 == "B C E"

//#### PASO 3: Limitar grados 4–8 solo en año 0
gen keep_obs = 1
replace keep_obs = 0 if year == 0 & (std < 4 | std > 8)
keep if keep_obs == 1

//#### PASO 4: Estimar regresiones por año (solo variable inc)
eststo clear

foreach y in 0 1 2 3 {
    eststo year`y': reg tmock inc if year == `y', cluster(s)
}

//#### PASO 5: Exportar resultados a archivo .tex
esttab year0 year1 year2 year3 using "$basedir\panel_b_short.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel B. Dependent variable: take government exam (no controls)") ///
    replace

	
//### PANEL C (CORTO): Participación en examen de ONG — sin controles
/******************************************************************************************
* PANEL C (corto) - tics como variable dependiente
* Sin controles (solo variable de tratamiento inc)
* Filtro: table2 == "B C E"
* Restricción para year == 0: limitar a grados 4 a 8
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar muestra según instrucciones
keep if table2 == "B C E"

//#### PASO 3: Limitar grados 4–8 solo en año 0
gen keep_obs = 1
replace keep_obs = 0 if year == 0 & (std < 4 | std > 8)
keep if keep_obs == 1

//#### PASO 4: Estimar regresiones por año (solo variable inc)
eststo clear

foreach y in 0 1 2 3 {
    eststo year`y': reg tics inc if year == `y', cluster(s)
}

//#### PASO 5: Exportar resultados a archivo .tex
esttab year0 year1 year2 year3 using "$basedir\panel_c_short.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel C. Dependent variable: take NGO exam (no controls)") ///
    replace
	
	
//### PANEL D (CORTO): Abandono escolar — sin controles
/******************************************************************************************
* PANEL D (corto) - dropout como variable dependiente
* Sin controles (solo variable de tratamiento inc)
* Filtro: table2 == "D"
* Sin restricciones por grado
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar muestra para Panel D
keep if table2 == "D"

//#### PASO 3: Estimar regresiones por año (solo variable inc)
eststo clear

foreach y in 0 1 2 3 {
    eststo year`y': reg dropout inc if year == `y', cluster(s)
}

//#### PASO 4: Exportar resultados a archivo .tex
esttab year0 year1 year2 year3 using "$basedir\panel_d_short.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel D. Dependent variable: dropping out (no controls)") ///
    replace


//### PANEL E (CORTO): Presentó examen si estaba inscrito — sin controles
/******************************************************************************************
* PANEL E (corto) - tmock como variable dependiente
* Sin controles (solo variable de tratamiento inc)
* Filtro: table2 == "B C E"
* Restricción 1: std entre 4 y 8 para todos los años
* Restricción 2: excluir alumnos que abandonaron en año 1 (sstd98v4) y año 2 (sstd99v3)
******************************************************************************************/

//#### PASO 1: Cargar base
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//#### PASO 2: Filtrar muestra según Panel B/C
keep if table2 == "B C E"

//#### PASO 3: Limitar a grados 4–8 para todos los años
keep if std >= 4 & std <= 8

//#### PASO 4: Excluir alumnos que abandonaron en año 1 y 2
gen keep_enrolled = 1
replace keep_enrolled = 0 if (year == 1 & inlist(sstd98v4, 55, 66, 77))
replace keep_enrolled = 0 if (year == 2 & inlist(sstd99v3, 55, 66, 77))
keep if keep_enrolled == 1

//#### PASO 5: Estimar regresiones por año (solo variable inc)
eststo clear

foreach y in 0 1 2 3 {
    eststo year`y': reg tmock inc if year == `y', cluster(s)
}

//#### PASO 6: Exportar resultados a archivo .tex
esttab year0 year1 year2 year3 using "$basedir\panel_e_short.tex", ///
    keep(inc) ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label b(3) se(3) ///
    compress nomtitle nonotes ///
    title("Panel E. Dependent variable: take government exam if enrolled (no controls)") ///
    replace

//##e) Estadísticas descriptivas en línea basal (Año 0)

// Cargar base una vez
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//======================
//#### PASO 1: Calificaciones (t) — Panel A
//======================
preserve
keep if table2 == "A" & year == 0 & !missing(t)
gen grupo = cond(inc == 1, "Tratamiento", "Control")
estpost tabstat t, by(grupo) stats(mean sd count) columns(statistics)
eststo row1
estadd local rowname "Calificaciones (t)"
restore

//======================
//#### PASO 2: Examen gobierno (tmock) — Panel B/C/E
//======================
preserve
keep if table2 == "B C E" & year == 0 & !missing(tmock)
gen grupo = cond(inc == 1, "Tratamiento", "Control")
estpost tabstat tmock, by(grupo) stats(mean sd count) columns(statistics)
eststo row2
estadd local rowname "Examen gobierno (tmock)"
restore

//======================
//#### PASO 3: Examen ONG (tics) — Panel B/C/E
//======================
preserve
keep if table2 == "B C E" & year == 0 & !missing(tics)
gen grupo = cond(inc == 1, "Tratamiento", "Control")
estpost tabstat tics, by(grupo) stats(mean sd count) columns(statistics)
eststo row3
estadd local rowname "Examen ONG (tics)"
restore

//======================
//#### PASO 4: Abandono escolar (dropout) — Panel D
//======================
preserve
keep if table2 == "D" & year == 0 & !missing(dropout)
gen grupo = cond(inc == 1, "Tratamiento", "Control")
estpost tabstat dropout, by(grupo) stats(mean sd count) columns(statistics)
eststo row4
estadd local rowname "Abandono escolar (dropout)"
restore

//======================
//#### PASO 5: Exportar tabla .tex minimalista
//======================
esttab row1 row2 row3 row4 ///
    using "$basedir\summary_statistics.tex", ///
    cells("mean(fmt(2)) sd(fmt(2)) count") ///
    unstack ///
    label nonumber noobs ///
    fragment booktabs ///
    collabels(" " "Media" "SD" "N" "Media" "SD" "N") ///
    replace
	
	
//## f) PODER ESTADISTICO

//==============================
// Poder estadístico — Inciso (f)
//==============================

// Cargar base una vez
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear
//==============================
// Poder estadístico — Inciso (f) con alpha ajustado
//==============================

//=======================================================================
//#### PASO 1: Calcular PE donde:

*** mu1 = 0 ; mu2 = beta año 2) : sd , n1 y n2 corresponden al inciso e)
//=======================================================================

* Panel A: Calificaciones (t)
sampsi 0 0.224, n1(33614) n2(30198) sd1(1.00) sd2(1.03) alpha(0.05) onesided

* Panel B: Examen gobierno (tmock)
sampsi 0 0.063, n1(10472) n2(9507) sd1(0.40) sd2(0.40) alpha(0.05) onesided

* Panel C: Examen ONG (tics)
sampsi 0 0.010, n1(10737) n2(9768) sd1(0.39) sd2(0.38) alpha(0.05) onesided

* Panel D: Abandono escolar (dropout)
sampsi 0 -0.009, n1(7382) n2(6711) sd1(0.34) sd2(0.34) alpha(0.05) onesided

//=======================================================================
//#### PASO 2 Exportar Manualmente a .tex los valroes de PE
//=======================================================================

//## g)Poder ajustado por clustering — Inciso (g)
//==============================
use "$basedir\Glewwe_Ilias_Kremer_2010.dta", clear

//### PASO 1 (solo una vez): instalar comandos necesarios
net describe sxd4, from(http://www.stata.com/stb/stb60)   // revisa paquete con sampclus
net install sxd4                                           // instala sampclus
ssc install egenmore                                       // utilidades extra para egen


//### PASO 2: calcular intercorrelación intraclase (ICC) con loneway
// (ya sólo para ver resultados, luego usaremos valores manuales)
loneway t s if year==0
loneway tmock s if year==0
loneway tics s if year==0
loneway dropout s if year==0


//### PASO 3: guardar manualmente los ICC de cada outcome
local rho_t   = 0.147   // ICC para t
local rho_g   = 0.067   // ICC para tmock
local rho_o   = 0.020   // ICC para tics
local rho_d   = 0.037   // ICC para dropout


//### PASO 4: calcular número de escuelas y promedio de alumnos por escuela
tab s if year==0                                           // cuenta número de escuelas
local num_escuelas = r(r)

preserve
keep if year==0
duplicates drop pupid s, force                             // quitar duplicados alumno-escuela
bysort s: gen alumnos_por_escuela = _N                     // contar alumnos en cada escuela
bysort s (alumnos_por_escuela): keep if _n==1              // 1 fila por escuela
summarize alumnos_por_escuela
local obsclus = r(mean)                                    // promedio alumnos por escuela
restore

// redondear obsclus para usar en sampclus (no acepta decimales)
local obsclus_int = round(`obsclus')

display "Número de escuelas: `num_escuelas'"
display "Promedio alumnos/escuela: `obsclus' (redondeado a `obsclus_int')"


//=========================================================
//#### Outcome: t  (Año 2)
//=========================================================
sampsi 0 0.224, sd(1) alpha(0.006) power(0.8) onesided   // cálculo sin cluster
sampclus, obsclus(`obsclus_int') rho(`rho_t')                   // ajuste por clustering


//=========================================================
//#### Outcome: tmock
//=========================================================
sampsi 0 0.063, sd(0.40) alpha(0.05) power(0.8) onesided
sampclus, obsclus(`obsclus_int') rho(`rho_g')


//=========================================================
//#### Outcome: tics
//=========================================================
sampsi 0 0.010, sd(0.39) alpha(0.05) power(0.8) onesided
sampclus, obsclus(`obsclus_int') rho(`rho_o')


//=========================================================
//#### Outcome: dropout
//=========================================================
sampsi 0 -0.008, sd(0.34) alpha(0.031) power(0.8) onesided
sampclus, obsclus(`obsclus_int') rho(`rho_d')











