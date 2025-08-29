/****************************************************************************************
* AUTOR:        Daniel Fuentes      Github: danifuentesga                              *
* FECHA:        15 de agosto de 2025                                                   *
* TAREA:        Tarea 1                                                                *
* DESCRIPCIÓN:  Ver archivo Tarea 1           *
****************************************************************************************/

**** Por un México con datos limpios y resultados significativos al 1%  , venga....***   

*------------------------------------------------------------------------------
*                        1. CARGA DE LA BASE DE DATOS
*------------------------------------------------------------------------------

//# EJERCICIO 2: Limpieza de la base de datos

clear all
set more off

* Cambia el path si es necesario:
cd "C: ... "  // <--- AJUSTA ESTA RUTA

use encaseh97.dta, clear

*------------------------------------------------------------------------------
*                        2. INSPECCIÓN DE LA ESTRUCTURA
*------------------------------------------------------------------------------

//## a) ¿Cuántas variables y observaciones tiene la base?

* Ver número de variables y observaciones
describe

* También puedes usar esto para obtener solo el conteo:
count
display "Número de variables: " _N
display "Número de observaciones: " _vars

*------------------------------------------------------------------------------
*                        3. IDENTIFICADORES CLAVE
*------------------------------------------------------------------------------

//## b) Identificar variable del hogar y del individuo

* Según la nota metodológica:
* - La variable que identifica al HOGAR es: numero
* - La variable que identifica al INDIVIDUO es: renglon

* Verifiquemos cómo se ven estas variables:
list numero renglon if _n <= 10

* Chequeo de unicidad por hogar e individuo:
duplicates report numero renglon



*------------------------------------------------------------------------------
*                4. FILTRO: QUEDARSE SOLO CON JEFES DE HOGAR
*------------------------------------------------------------------------------

//## c) Filtrar solo jefes de hogar

* Nos interesa únicamente el jefe del hogar (renglon == 1)
* Cada hogar está identificado con la variable "numero"
* Según la nota metodológica: renglon == 1 corresponde al jefe(a) del hogar

keep if renglon == 1

* Comprobación rápida
list numero renglon if _n <= 10

*------------------------------------------------------------------------------
*                5. CONTEO DE HOGARES (JEFES DE FAMILIA)
*------------------------------------------------------------------------------

* Cada jefe de hogar representa un hogar
* Contamos el número de hogares únicos usando la variable "numero"

duplicates report numero   // Verificamos que no haya duplicados inesperados
bysort numero: keep if _n == 1  // (Solo como medida extra, en caso de repeticiones)

* Finalmente, contamos cuántos hogares hay
count
display "Número total de hogares (jefes de familia): " _N


*------------------------------------------------------------------------------
*                6. SELECCIÓN DE VARIABLES RELEVANTES PARA EL ANÁLISIS
*------------------------------------------------------------------------------

* Nos quedamos únicamente con:
* - Identificadores: numero (hogar), claveofi (localidad), contba_1 (tratamiento/control)
* - Variables de interés: p08, p11, p17, p18, p19, p20, p24, p25, p38, p65b

keep numero claveofi contba_1 p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b

* Verificamos que las variables estén correctamente
describe

*------------------------------------------------------------------------------
*                7. RECODIFICACIÓN DE VARIABLE DE TRATAMIENTO
*------------------------------------------------------------------------------

//## d) Recodificar contba_1 a dummy y calcular % tratamiento

* La variable contba_1 es:
*   - 1 si el hogar está en una localidad con tratamiento
*   - 2 si el hogar está en una localidad control

* Para regresiones y tabulaciones, recodificamos para que:
*   - Tratamiento = 1
*   - Control     = 0

gen tratamiento = .
replace tratamiento = 1 if contba_1 == 1
replace tratamiento = 0 if contba_1 == 2

label variable tratamiento "1 = Tratamiento, 0 = Control"

*------------------------------------------------------------------------------
*                8. CÁLCULO DEL PORCENTAJE DE HOGARES EN TRATAMIENTO
*------------------------------------------------------------------------------

* Total de hogares:
count
scalar total_hogares = r(N)

* Total de hogares con tratamiento:
count if tratamiento == 1
scalar tratados = r(N)

* Porcentaje de hogares tratados:
display "Porcentaje de hogares en tratamiento: " (tratados/total_hogares)*100 "%"


*------------------------------------------------------------------------------
*        9. PRUEBA DE IGUALDAD DE DISTRIBUCIONES ENTRE TRATAMIENTO Y CONTROL
*------------------------------------------------------------------------------

//# EJERCICIO 3: Corroboración de la aleatorización a nivel HOGAR

* Siguiendo a Behrman y Todd (1999):
* - Kolmogorov-Smirnov para edad (p08)
* - Ji-cuadrada de Pearson para las demás

*------------------------------------------------------------------------------
*                        9.1 Prueba Kolmogorov-Smirnov: Edad
*------------------------------------------------------------------------------

//## a) Kolmogorov-Smirnov y chi² por grupo de tratamiento

* Comparación de distribución de edad (p08) entre tratamiento y control
ksmirnov p08, by(tratamiento)

*------------------------------------------------------------------------------
*                        9.2 Pruebas Ji-cuadrada: Variables discretas
*------------------------------------------------------------------------------

* Sexo
tabulate p11 tratamiento, chi2

* ¿Habla español?
tabulate p17 tratamiento, chi2

* Alfabetismo
tabulate p18 tratamiento, chi2

* Asistencia a la escuela
tabulate p19 tratamiento, chi2

* Nivel de escolaridad
tabulate p20 tratamiento, chi2

* Condición de inactividad
tabulate p24 tratamiento, chi2

* Posición en la ocupación
tabulate p25 tratamiento, chi2

* Ingreso del hogar
tabulate p38 tratamiento, chi2

* Tiene refrigerador
tabulate p65b tratamiento, chi2

*------------------------------------------------------------------------------
*           10. PRUEBA DE IGUALDAD DE MEDIAS ENTRE TRATAMIENTO Y CONTROL
*------------------------------------------------------------------------------

//## b) Pruebas t para igualdad de medias

* En este bloque se evalúa si las medias de las variables difieren
* entre los hogares en tratamiento y en control usando 4 métodos:

* - t-test
* - regresión lineal
* - regresión con errores robustos
* - regresión con errores agrupados por localidad

*------------------------------------------------------------------------------
*                   10.1 Prueba t de igualdad de medias
*------------------------------------------------------------------------------

* Variable continua: edad (p08)
ttest p08, by(tratamiento)

* Variables discretas (STATA permite ttest para variables binarias y ordinales)
ttest p11, by(tratamiento)
ttest p17, by(tratamiento)
ttest p18, by(tratamiento)
ttest p19, by(tratamiento)
ttest p20, by(tratamiento)
ttest p24, by(tratamiento)
ttest p25, by(tratamiento)
ttest p38, by(tratamiento)
ttest p65b, by(tratamiento)

*------------------------------------------------------------------------------
*                   10.2 Regresión lineal simple (OLS)
*------------------------------------------------------------------------------

//## c) Regresiones lineales simples

reg p08 tratamiento
reg p11 tratamiento
reg p17 tratamiento
reg p18 tratamiento
reg p19 tratamiento
reg p20 tratamiento
reg p24 tratamiento
reg p25 tratamiento
reg p38 tratamiento
reg p65b tratamiento

*------------------------------------------------------------------------------
*             10.3 Regresión lineal con errores estándar robustos
*------------------------------------------------------------------------------

//## d) Regresiones con errores robustos

reg p08 tratamiento, robust
reg p11 tratamiento, robust
reg p17 tratamiento, robust
reg p18 tratamiento, robust
reg p19 tratamiento, robust
reg p20 tratamiento, robust
reg p24 tratamiento, robust
reg p25 tratamiento, robust
reg p38 tratamiento, robust
reg p65b tratamiento, robust

*------------------------------------------------------------------------------
*     10.4 Regresión lineal con errores agrupados por localidad (cluster)
*------------------------------------------------------------------------------

//## e) Regresiones con errores agrupados por localidad

reg p08 tratamiento, vce(cluster claveofi)
reg p11 tratamiento, vce(cluster claveofi)
reg p17 tratamiento, vce(cluster claveofi)
reg p18 tratamiento, vce(cluster claveofi)
reg p19 tratamiento, vce(cluster claveofi)
reg p20 tratamiento, vce(cluster claveofi)
reg p24 tratamiento, vce(cluster claveofi)
reg p25 tratamiento, vce(cluster claveofi)
reg p38 tratamiento, vce(cluster claveofi)
reg p65b tratamiento, vce(cluster claveofi)


*------------------------------------------------------------------------------
*        11. CAMBIO DE NIVEL: PROMEDIOS A NIVEL LOCALIDAD (USANDO COLLAPSE)
*------------------------------------------------------------------------------

//# EJERCICIO 4: Corroboración de la aleatorización a nivel LOCALIDAD

* Promediamos todas las variables por localidad
* La variable contba_1 se usará como max para conservar el valor de tratamiento/control
* Esto genera una base a nivel de localidad (una fila por claveofi)

//## a) Colapsar a nivel localidad y repetir pruebas de balance

collapse (mean) p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b (max) contba_1, by(claveofi)

//# EJERCICIO 5: Supuesto de ignorabilidad y aleatorización original

//## a) Filtrar solo hogares pobres y contar observaciones
* Creamos nuevamente variable binaria de tratamiento (como antes, pero ahora a nivel localidad)
gen tratamiento = .
replace tratamiento = 1 if contba_1 == 1
replace tratamiento = 0 if contba_1 == 2

label variable tratamiento "1 = Tratamiento, 0 = Control (a nivel localidad)"

//## b) Filtrar variables clave y repetir pruebas con contba_1

* Verificamos número de localidades tratadas y control
tab tratamiento

/****************************************************************************************
*                12. PRUEBAS DE IGUALDAD A NIVEL LOCALIDAD                              *
*                (Como en el problema 3, incisos a–d, pero ahora por localidad)         *
****************************************************************************************/

*------------------------------------------------------------------------------
*                     12.1 Kolmogorov-Smirnov para igualdad de distribuciones
*------------------------------------------------------------------------------

ksmirnov p08, by(tratamiento)
ksmirnov p11, by(tratamiento)
ksmirnov p17, by(tratamiento)
ksmirnov p18, by(tratamiento)
ksmirnov p19, by(tratamiento)
ksmirnov p20, by(tratamiento)
ksmirnov p24, by(tratamiento)
ksmirnov p25, by(tratamiento)
ksmirnov p38, by(tratamiento)
ksmirnov p65b, by(tratamiento)

*------------------------------------------------------------------------------
*                     12.2 T test
*------------------------------------------------------------------------------

ttest p11, by(tratamiento)
ttest p17, by(tratamiento)
ttest p18, by(tratamiento)
ttest p19, by(tratamiento)
ttest p20, by(tratamiento)
ttest p24, by(tratamiento)
ttest p25, by(tratamiento)
ttest p38, by(tratamiento)
ttest p65b, by(tratamiento)

*------------------------------------------------------------------------------
*                     12.3 Regresión lineal simple
*------------------------------------------------------------------------------

reg p08 tratamiento
reg p11 tratamiento
reg p17 tratamiento
reg p18 tratamiento
reg p19 tratamiento
reg p20 tratamiento
reg p24 tratamiento
reg p25 tratamiento
reg p38 tratamiento
reg p65b tratamiento

*------------------------------------------------------------------------------
*                     12.4 Regresión con errores robustos
*------------------------------------------------------------------------------

reg p08 tratamiento, robust
reg p11 tratamiento, robust
reg p17 tratamiento, robust
reg p18 tratamiento, robust
reg p19 tratamiento, robust
reg p20 tratamiento, robust
reg p24 tratamiento, robust
reg p25 tratamiento, robust
reg p38 tratamiento, robust
reg p65b tratamiento, robust

*------------------------------------------------------------------------------
*                     12.5 Regresión con errores agrupados por localidad
*                     (Ya no es necesario aquí, porque ahora cada obs = localidad)
*------------------------------------------------------------------------------

* Nota: Ya estamos a nivel localidad, así que no tiene sentido agrupar por localidad.
* Este paso se omite porque cada observación ES una localidad.

* Si fuera otro nivel, usaríamos: vce(cluster claveofi)

/****************************************************************************************
*        13. APLICACIÓN DEL SUPUESTO DE IGNORABILIDAD Y ALEATORIZACIÓN (PROGRESA)      *
****************************************************************************************/


*------------------------------------------------------------------------------
*                13.1 Recargar base original y filtrar jefe del hogar
*------------------------------------------------------------------------------


clear all
set more off

* Cambia la ruta si es necesario
cd " "  // <--- AJUSTA ESTA RUTA

use encaseh97.dta, clear

* Filtramos para quedarnos solo con jefes de hogar
keep if renglon == 1

*------------------------------------------------------------------------------
*                13.2 Filtrar solo hogares pobres
*------------------------------------------------------------------------------

* La variable pobre_1 indica hogares pobres (1 = pobre)
keep if pobre_1 == 1

*------------------------------------------------------------------------------
*                13.3 Conteo final de observaciones (hogares pobres)
*------------------------------------------------------------------------------

count
display "Número total de hogares pobres (observaciones): " _N

*------------------------------------------------------------------------------
*         14. FILTRAR VARIABLES Y RECODIFICAR TRATAMIENTO (HOGARES POBRES)
*------------------------------------------------------------------------------

* Nos quedamos solo con variables necesarias
keep folio claveofi contba_1 p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b

* Reespecificamos tratamiento como dummy 1 = tratamiento, 0 = control
gen tratamiento = .
replace tratamiento = 1 if contba_1 == 1
replace tratamiento = 0 if contba_1 == 2
label variable tratamiento "1 = Tratamiento, 0 = Control"

*------------------------------------------------------------------------------
*        15. REPETIR PRUEBAS DE IGUALDAD DE DISTRIBUCIONES (Problema 3)
*------------------------------------------------------------------------------

* Kolmogorov-Smirnov para edad
ksmirnov p08, by(tratamiento)

* Ji-cuadrada para variables discretas
foreach var in p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    tabulate `var' tratamiento, chi2
}

* Prueba t de igualdad de medias
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    ttest `var', by(tratamiento)
}

* Regresión simple
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' tratamiento
}

* Regresión con errores robustos
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' tratamiento, robust
}

* Regresión con errores agrupados por localidad
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' tratamiento, vce(cluster claveofi)
}

*------------------------------------------------------------------------------
*        16. CAMBIO A NIVEL LOCALIDAD (COLLAPSE PARA HOGARES POBRES)
*------------------------------------------------------------------------------

collapse (mean) p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b (max) contba_1, by(claveofi)

* Recrear dummy de tratamiento a nivel localidad
gen tratamiento = .
replace tratamiento = 1 if contba_1 == 1
replace tratamiento = 0 if contba_1 == 2

label variable tratamiento "1 = Tratamiento, 0 = Control (localidad)"

*------------------------------------------------------------------------------
*        17. REPETIR ANÁLISIS A NIVEL LOCALIDAD (Problema 4)
*------------------------------------------------------------------------------

* Kolmogorov-Smirnov
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    ksmirnov `var', by(tratamiento)
}

* Regresión simple
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' tratamiento
}

* Regresión con errores robustos
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' tratamiento, robust
}

* Nota: No se necesita vce(cluster claveofi) porque estamos a nivel localidad

/****************************************************************************************
*                              18. NUEVA ALEATORIZACIÓN                                 *
*        Preparación de la base para simular una aleatorización a nivel localidad       *
****************************************************************************************/

*------------------------------------------------------------------------------
*          18.1 Recargar base original (encaseh97.dta) y limpiar entorno
*------------------------------------------------------------------------------

//# EJERCICIO 6: Nueva aleatorización

clear all
set more off

cd "..."  // AJUSTA ESTA RUTA

use encaseh97.dta, clear

*------------------------------------------------------------------------------
*          18.2 Conservar solo una observación por localidad
*------------------------------------------------------------------------------


//## a) Una observación por localidad (tag_local)

* Usamos tag() para marcar una sola fila por cada localidad (claveofi)
egen tag_local = tag(claveofi)
recode tag_local (0=.)

* Nos quedamos solo con esas observaciones únicas por localidad
keep if tag_local == 1

* Verificación
list claveofi tag_local if _n <= 10

*------------------------------------------------------------------------------
*           18.3 Generación de número aleatorio por localidad
*------------------------------------------------------------------------------
//## b) Generar número aleatorio con seed fijo

* Fijamos semilla para reproducibilidad (¡clave para aleatorización!)
set seed 1

* Generamos variable aleatoria continua en (0,1) solo para las observaciones tag_local == 1
gen random = runiform() if tag_local == 1

* Verificamos
list claveofi random if _n <= 10

* Nota: Esta variable se usará para simular nueva asignación de tratamiento

*------------------------------------------------------------------------------
*         18.4 Ordenar localidades por número aleatorio (ascendente)
*------------------------------------------------------------------------------
//## c) Ordenar por random y encontrar menor valor

sort random

* Mostramos la primera observación (menor valor aleatorio)
list claveofi random if !missing(random) in 1

* Alternativamente, podrías guardar el mínimo en un scalar:
summarize random, meanonly
display "Menor número aleatorio generado: " r(min)

* También puedes ver todas las 5 primeras si quieres:
list claveofi random if !missing(random) in 1/5

*------------------------------------------------------------------------------
*        18.5 Asignación de tratamiento aleatorio: 320 tratadas, 186 control
*------------------------------------------------------------------------------


//## d) Asignar tratamiento aleatorio a 320 localidades (trat)

* Creamos ranking de localidades por su número aleatorio
egen n = group(random)

* Asignamos tratamiento a las primeras 320 (menor random → mayor prioridad)
gen trat = .
replace trat = 1 if n <= 320
replace trat = 0 if n > 320 & n <= 506


//## e) Filtrar hogares pobres y seleccionar variables clave

* Ahora aseguramos que todas las observaciones en la base tengan su trat correcto
* (por si aún hay observaciones repetidas por localidad — esto es útil si no colapsaste aún)
sort claveofi n
replace trat = trat[_n-1] if trat[_n-1] != . & claveofi == claveofi[_n-1]

* Verificamos conteo
tab trat

/****************************************************************************************
*       19. NUEVA ALEATORIZACIÓN: ANÁLISIS A NIVEL HOGAR Y LOCALIDAD CON trat          *
****************************************************************************************/

*------------------------------------------------------------------------------
*           19.1 Filtrar hogares pobres, jefe de hogar y variables necesarias
*------------------------------------------------------------------------------

//## f) Repetir pruebas de balance con nueva aleatorización (trat)

* Volvemos a cargar la base original
clear all
set more off
cd "C..."  // AJUSTA RUTA

use encaseh97.dta, clear

* Jefes de hogar únicamente
keep if renglon == 1

* Hogares pobres únicamente
keep if pobre_1 == 1

* Conservamos solo las variables solicitadas
keep folio claveofi trat p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b

*------------------------------------------------------------------------------
*           19.2 Repetir pruebas de balance a nivel hogar (Problema 3)
*------------------------------------------------------------------------------

* Kolmogorov-Smirnov (para edad)
ksmirnov p08, by(trat)

* Chi-cuadrada para variables discretas
foreach var in p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    tabulate `var' trat, chi2
}

* Prueba t de medias
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    ttest `var', by(trat)
}

* Regresión simple
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' trat
}

* Regresión con errores robustos
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' trat, robust
}

* Regresión con clustering por localidad
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' trat, vce(cluster claveofi)
}

*------------------------------------------------------------------------------
*         19.3 Repetir pruebas a nivel localidad (Problema 4) con trat
*------------------------------------------------------------------------------

* Colapsamos la base a nivel localidad
collapse (mean) p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b (max) trat, by(claveofi)

* Verificación: ¿cuántas tratadas y control hay?
tab trat

* Kolmogorov-Smirnov
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    ksmirnov `var', by(trat)
}

* Regresión simple
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' trat
}

* Regresión con errores robustos
foreach var in p08 p11 p17 p18 p19 p20 p24 p25 p38 p65b {
    reg `var' trat, robust
}















