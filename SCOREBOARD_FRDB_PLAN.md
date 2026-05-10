# Plan de Implementación: Scoreboard con Firebase Realtime Database (FRDB)

Este plan propone utilizar Firebase Realtime Database como una base de datos "espejo" optimizada para la lectura en tiempo real del ranking, reduciendo drásticamente las lecturas de Firestore.

## 1. Arquitectura de Datos

En Firestore, el documento del usuario sigue siendo la fuente de verdad. En FRDB, mantendremos una rama `/leaderboard` con la información mínima necesaria para mostrar el ranking.

### Estructura en FRDB:
```json
{
  "leaderboard": {
    "uid_1": {
      "displayName": "Nombre Usuario",
      "photoUrl": "https://...",
      "score": 1500
    },
    "uid_2": {
      "displayName": "Otro Usuario",
      "score": 1200
    }
  }
}
```

## 2. Sincronización (Cloud Functions)

Utilizaremos una Cloud Function que reaccione a los cambios en Firestore para actualizar FRDB de forma automática y gratuita (dentro del tier de Functions).

### Lógica de la Función:
1. Trigger: `onDocumentUpdated` en `users/{uid}`.
2. Si el `score`, `displayName` o `photoUrl` han cambiado:
   - Escribir en FRDB: `admin.database().ref('leaderboard/' + uid).set({ ... })`.

## 3. Implementación en el Cliente (Flutter)

### Capa de Datos:
Crear un `RealtimeDatabaseService` en `lib/data/services/` que use el paquete `firebase_database`.

```dart
class RealtimeDatabaseService {
  final _db = FirebaseDatabase.instance.ref();

  Stream<List<UserModel>> getLeaderboard() {
    return _db.child('leaderboard')
        .orderByChild('score')
        .limitToLast(100) // Top 100
        .onValue
        .map((event) {
          // Mapear el snapshot a una lista de UserModel
          // Nota: FRDB devuelve los datos en orden ascendente, 
          // habrá que invertir la lista en el cliente.
        });
  }
}
```

## 4. Ventajas de FRDB
- **Costo:** No cobra por lectura de documento, sino por ancho de banda (GB transferidos). Para un ranking de texto, es prácticamente gratuito.
- **Tiempo Real:** La actualización es instantánea sin necesidad de refrescar.
- **Integración:** No requiere configurar servicios externos ni manejar APIs REST adicionales.

## 5. Pasos a seguir
1. Habilitar Realtime Database en la consola de Firebase.
2. Crear la Cloud Function de sincronización.
3. Actualizar `UserModel` para que sea compatible con los datos de FRDB.
4. Implementar el `LeaderboardCubit` y la UI correspondiente.
