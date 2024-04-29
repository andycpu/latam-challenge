# latam-challenge

## Parte 1 - Infraestructura e IaC
Utilizacion de servicios en GCP
- Pub/Sub
- BigQuery como DB (por su enfoque en analítica de datos)
- Cloud Function (en Python) que expone datos de BQ mediante un endpoint HTTP al recibir una peticion GET

MISSING:
2 (optional)

## Parte 2
- API HTTP endpoint que muestra ya sea todos los vuelos o los vuelos desde una ciudad origen. Ejemplos: 
    - https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/function-2
    - https://southamerica-west1-latam-challenge-421420.cloudfunctions.net/function-2?departure_city=Chicago

- Deployment de la Cloud Function:
Uso de cuenta personal para simplificar. En entornos de produccion esto deberia ser hecho con una SA (service account) con los permisos minimos necesarios.

- Datos ingresados a BQ manualmente a traves de GCP console para simplificar. Lo ideal seria configurar la tabla para que tome los datos de pub sub directamente (o de otra fuente).


gcloud functions add-invoker-policy-binding function-2 \
      --region="southamerica-west1" \
      --member="serviceAccount:my-bigquery-sa@${PROJECT_ID}.iam.gserviceaccount.com"
      
      
      
 also need to add BQ data viewer to the table!