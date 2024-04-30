## Parte 1 - Infraestructura e IaC
Utilizacion de servicios en GCP
- Pub/Sub
- BigQuery como DB (por su enfoque en analítica de datos)
- Cloud Function (en Python) que expone datos de BQ mediante un endpoint HTTP al recibir una peticion GET

Deployment de infra a traves de terraform

## Parte 2 - Aplicaciones y flujo CI/CD
- API HTTP endpoint que muestra ya sea todos los vuelos o los vuelos desde una ciudad origen. Ejemplos: 
    - https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/get_flights
    - https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/get_flights?departure_city=Chicago

- Deployment de la Cloud Function con circleci
Uso de una SA (service account) definida en terraform para hacer el deployment. Mejoras que se proponen:
    - Usar "Workload Identity Federation" en vez de keys para la autenticacion de la SA.
    - Que el deployment automatico se realice solo cuando haya cambios relevantes a la API. No cualquier commit.


- Datos ingresados a BQ manualmente a traves de GCP console para simplificar. Lo ideal seria configurar la tabla para que tome los datos de pub sub directamente (o de otra fuente).


![alt text](docs/latam-challenge.drawio.png)

Notas: 
- Pub/Sub no esta implementado
- En un entorno real, se usarian distintos entornos como por ejemplo desarrollo (dev), QA/staging, y produccion.

## Parte 3 - Pruebas de Integración y Puntos Críticos de Calidad

1- El test *test_get_flights_no_filter* en [test_main.py](cloud_function/test_main.py) verifica que la API esta efectivamente exponiendo los datos. Esto es asi porque llama directamente a la API y controla que esta retorna datos. Este test verifica el caso en que no se usa ningun filtro, es decir se retornan todos los vuelos (flights).

2- Para este punto ademas de proponer otras pruebas de integracion, estas tambien se implementaron.
- *test_get_flights_with_filter* en [test_main.py](cloud_function/test_main.py) no solo verifica que la API esta exponiendo los datos, sino que tambien que el filtro por ciudad de origen funcione. Es decir, verifica que el primer vuelo retornado proviene de la ciudad de Chicago (asume que siempre habra al menos un vuelo desde Chicago).
- *test_get_flights_with_filter_using_non_existent_city* en [test_main.py](cloud_function/test_main.py) verifica que cuando se usa una ciudad no existente como filtro, la API efectivamente no retorne datos. Pero a la vez la peticion sea exitosa, es decir, que retorne el codigo HTTP 200.

3 y 4 - Posibles puntos críticos del sistema
- Performance. 
    - Un punto critico a mejorar es que actualmente el sistema retorna todos los vuelos existentes. Potencialmente el numero de vuelos podria incrementar a un punto que la performance del sistema se vea deteriorada. Lo ideal para solucionar este problema seria implementar un sistema de paginacion, de manera tal que se retorne como maximo un numero definido de vuelos (10 por ej.). Para testear esto, simplemente se verifica que no se retornen mas de ese numero definido de vuelos. 
    - Tambien se deberian agregar pruebas de performance o carga de trabajo, que verifiquen que el sistema responde de manera adecuada cuando la carga de trabajo aumenta de manera considerable.
- Seguridad. 
    - Actualmente cualquier persona puede hacer una peticion a esta API. Esto obviamente no es lo ideal. Se deberia implementar un sistema de autenticacion, de manera tal que solo los usuarios autenticados puedan hacerlo. Se deberia agregar una prueba que verifique que usuarios no autenticados no puedan usar la API (y que reciban un error de autenticacion), como asi otra prueba que verifique que usuarios autenticados efectivamente puedan llamar a la API y ver resultados.
    - Se deberia tambien agregar pruebas que verifiquen que el sistema es seguro ante ataques como por ej "SQL injection".


### Flujo CI/CD donde se ve que primero se realiza el deployment de la app (Cloud Function) y luego se ejecutan las pruebas de integracion

![alt text](docs/screenshot-CI-CD.jpeg)

Notas: 
- Nuevamente cabe destacar que en un entorno real, se usarian distintos entornos como por ejemplo desarrollo (dev), QA/staging, y produccion.
- Se recomendia usar alguna herramienta de "test coverage" para analizar cuales son las areas del codigo que necesitan mas pruebas. 
- Tambien se podrian usar algun tipo de "quality gate" dentro del flujo CI/CD para asegurarse que nuevos cambios en el codigo no degraden la calidad de este.

## Parte 4 - Métricas y Monitoreo

1- Tres métricas (además de las básicas CPU/RAM/DISK USAGE) críticas para entender la salud y rendimiento del sistema (teniendo en cuenta que se usa una CF):
- Duración de ejecucion
- Número de solicitudes por hora/minuto/segundo
- Tasa de errores

2- Grafana como herramienta de visualización, mostrando las siguientes metricas:

- Memoria utilizada: Visualizar el uso de memoria RAM. Esto nos permitiría identificar si la funcion usa demasiada memoria y no es eficiente, lo que podría afectar el rendimiento.
- Tasa de errores: Es importante rastrear la cantidad de errores que ocurren en el sistema, para identificar problemas en el código o en los recursos subyacentes. Ademas los errores pueden afectar la experiencia del usuario
- Número de solicitudes por hora/minuto/segundo: El número de veces que se invoca una función por hora/minuto/segundo. Es esencial para comprender la salud del sistema, identificar problemas de rendimiento, detectar anomalías y planificar la escalabilidad.
- Duración de ejecución: El tiempo que tarda una función en ejecutarse. Monitorear la duración de la ejecución es esencial para identificar funciones que podrían estar tardando demasiado en completarse y afectando asi la experiencia del usuario.

Otras metricas importantes que se usan generalmente pero no se incluyen por no estar disponibles al usar Cloud Functions:
- Uso de CPU: Monitorear la carga promedio de CPU en el sistema. Esto nos ayudaría a identificar picos de uso de CPU y posibles cuellos de botella que podrían afectar el rendimiento del sistema.
- Utilización de disco: Monitorizar la utilización del espacio en disco tanto a nivel de disco duro como por sistema de archivos. Esto nos ayudaría a identificar el uso excesivo de espacio en disco, posibles problemas de almacenamiento y la necesidad de realizar limpieza o escalamiento.
- Tráfico de red: Seguir el tráfico de red entrante y saliente en el sistema, desglosado por interfaz de red. Esto nos permitiría identificar patrones de tráfico, posibles ataques de red y evaluar la carga de trabajo de la red.

3- Implementacion en la nube GCP
- Despliegue de Grafana: Configuracion de Grafana en GCP, ya sea en una máquina virtual (Compute Engine) o en un clúster de Kubernetes (GKE).
- Configuración de fuentes de datos: Aqui conectamos Grafana a las fuentes de datos donde se almacenan las metricas del sistema, como Prometheus o Stackdriver Monitoring.
- Creación de paneles de visualización: Creamos los paneles en Grafana para mostrar las metricas importantes del sistema.
- Configuración de alertas: Configuramos alertas en Grafana para ser notificados cuando las metricas del sistema excedan ciertos límites.

4- Si escalamos la solución a 50 sistemas similares, la visualización en Grafana cambiará significativamente para adaptarse a la mayor cantidad de datos y complejidad del entorno. Estos son algunos cambios que podríamos esperar:

- Agrupacion de sistemas: En lugar de visualizar metricas individuales para cada sistema, es posible que deseemos agrupar los sistemas por funciones, regiones o cualquier otra característica relevante. Esto nos permitirá tener una vista más general y administrable de la salud y el rendimiento de los sistemas.
- Uso de etiquetas y filtros: Con tantos sistemas, es crucial poder filtrar y segmentar las metricas según diferentes dimensiones, como el nombre del sistema, la región, el entorno, etc. 
- Metricas agregadas y resumenes: En lugar de mostrar metricas detalladas para cada sistema, es posible que deseemos mostrar metricas agregadas y resumenes para obtener una vista general del rendimiento de todos los sistemas. 
- Uso de paneles dinámicos: Utilizar paneles dinámicos en Grafana nos permitirá crear paneles que se ajusten automáticamente para mostrar metricas para todos los sistemas. 

5- Si no se aborda correctamente el problema de escalabilidad en la observabilidad de los sistemas, podrian surgir dificultades como problemas para identificar y resolver fallos, perdida de visibilidad de los sistemas en general, mayor riesgo de fallos, mayor complejidad en la gestion del entorno, etc.

## Parte 5: Alertas y SRE (Opcional)

1 - Reglas/umbrales a utilizar. En general, para definir estos umbrales hay que tener en cuenta cuan critica es la aplicación, las expectativas del usuario, el impacto comercial de los errores, etc. Para este caso se tratara de utilizar valores tipicos/comunes.
- Memoria utilizada: Alerta cuando la memoria utilizada supere el 80% de la asignada. Ya que esto esto podría indicar una posible ineficiencia en el código o una necesidad de optimización. 
- Tasa de errores: Un umbral comunmente utilizado para la tasa de errores es del 1 al 5%. En este caso se podria usar un umbral del 5%. Esto significa que si más del 5% de las solicitudes resultan en errores, se activaría una alerta. Mantener la tasa de errores por debajo de este umbral ayuda a garantizar una experiencia del usuario satisfactoria y a mantener la confianza en el servicio, aceptando a la vez que tener cierto numero de errores es normal en cualquier sistema. 
- Número de solicitudes por hora/minuto/segundo: esto dependeria demasiado del tipo de aplicacion, cantidad de usuarios esperada, historial del uso, etc. Dependiendo de las expectativas, se podria usar un umbral de por ejemplo 100 a 1000 solicitudes por hora. Si el numero esta ya sea por debajo o por arriba de ese umbral se activaria una alerta. Que haya menos solicitudes de lo esperado podria indicar algun problema, lo cual require investigacion y analisis para resolverlo lo antes posible. Obviamente mas solicitudes de lo esperado, podria (tal vez) requerir algunos cambios para poder escalar el sistema de manera adecuada.
- Duración de ejecución: un umbral comúnmente utilizado para la duración de ejecución es de alrededor de 500 milisegundos (0.5 segundos), ya que esto garantiza una experiencia del usuario satisfactoria 