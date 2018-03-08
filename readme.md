# CFSR_GEFS_Calibration (precipitación).

Este proyecto esta orientado a generar modelos estadisticos de regresion logistica para la calibracion de los modelos de pronostico semanal CFSR (Climate Forecast System) y GEFS (GLobal Ensemble Forecast System). Usando como observacion la base de datos diaria grillada CPC_UNI.

Pasos a seguir:

* Mapas de las estaciones con los puntos mas cercanos a la estacion observacional de referencia. Se utiliza la base de datos del SMN de estacion meteorologicas, en particular su localizacion (NO sus datos). Se dibujan sobre el mapa la estacion , los puntos mas cercanos (1, 9, 25, 49).

* Usando las posiciones de las estaciones , se genera una tabla en una base de datos (mySQL) con los pronosticos de la S1 a S4 en el caso de CFSR.

* Usando las posiciones de las estaciones , se genera una tabla en una base de datos (mySQL) con los pronosticos de la S1 a S2 en el caso de GEFS.

* Se plotean los histogramas de referencia para comparar Observaciones vs Pronosticos semanales CFSR usando la base de datos generada de observaciones S1 a S4.

* Se plotean los histogramas de referencia para comparar Observaciones vs Pronosticos semanales CFSR usando la base de datos generada de observaciones S1 a S4.





