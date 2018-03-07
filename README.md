# CFSR_GEFS_Calibration (precipitacion).

Este proyecto esta orientado a generar modelos estadisticos de regresion logistica para la calibracion de los modelos de pronostico semanal CFSR (Climate Forecast System) y GEFS (GLobal Ensemble Forecast System). Usando como observacion la base de datos diaria grillada CPC_UNI.

Pasos a seguir:

* Mapas de las estaciones con los puntos mas cercanos a la estacion observacional de referencia. Se utiliza la base de datos del SMN de estacion meteorologicas, en particular su localizacion (NO sus datos). Se dibujan sobre el mapa la estacion , los puntos mas cercanos (1,9,25,49).

* Usando las posiciones de las estaciones , generamos una base de datos (mySQL) con los pronosticos de la S1 a S4 en el caso de CFSR y S1 y S2 para el caso de GEFS.

* 


