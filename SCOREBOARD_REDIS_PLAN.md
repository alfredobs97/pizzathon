# Plan de Implementación: Scoreboard con Redis (Sorted Sets)

Este plan propone utilizar **Redis**, específicamente la estructura de datos **Sorted Sets**, para manejar el ranking. Redis es la herramienta estándar de la industria para leaderboards de alto rendimiento.

## 1. Proveedor de Redis (Gratis)
Recomendamos **Upstash** (Serverless Redis) o **Aiven**.
- **Upstash:** Tier gratuito de hasta 10,000 requests diarios, suficiente para este proyecto. Permite acceso via REST API, ideal para Cloud Functions.

## 2. Estructura de Datos en Redis

Utilizaremos dos estructuras:
1. **Sorted Set (`leaderboard`):** Almacena `uid` como miembro y `score` como puntaje.
   - Comando: `ZADD leaderboard 1500 "uid_1"`
2. **Hash (`user_metadata`):** Almacena la info visual para no volver a Firestore.
   - Comando: `HSET user_metadata "uid_1" '{"name": "...", "photo": "..."}'`

## 3. Sincronización (Cloud Functions)

La Cloud Function actuará como puente entre Firestore y Redis.

### Lógica de la Función:
1. Trigger: `onDocumentUpdated` en `users/{uid}`.
2. Si el score cambia:
   - Llamada a Redis: `ZADD leaderboard new_score uid`.
3. Si el nombre o foto cambian:
   - Llamada a Redis: `HSET user_metadata uid JSON_STRING`.

## 4. Implementación en el Cliente (Flutter)

Dado que Redis es un servicio externo, el cliente Flutter puede consumir los datos de dos formas:
1. **Directamente vía REST:** Usando `http` para llamar a la API de Upstash (con un token de solo lectura).
2. **Vía Cloud Function (Callable):** Para mayor seguridad, el cliente llama a una función que a su vez consulta Redis.

### Ejemplo de Consulta (REST):
```bash
GET https://upstash-api-url/zrevrange/leaderboard/0/99/WITHSCORES
```

## 5. Ventajas de Redis
- **Velocidad Extrema:** Consultas en microsegundos.
- **Funciones Nativas:** Permite obtener el rango exacto de un usuario (`ZRANK`) o el top N (`ZREVRANGE`) de forma nativa y eficiente.
- **Escalabilidad:** Diseñado para manejar millones de actualizaciones por segundo.

## 6. Pasos a seguir
1. Crear una base de datos gratuita en [Upstash](https://upstash.com/).
2. Configurar las variables de entorno (`REDIS_URL`, `REDIS_TOKEN`) en Firebase Functions.
3. Implementar la lógica de sincronización en `functions/src/index.ts`.
4. Crear un `ScoreboardService` en Flutter que consuma la API de Redis.
