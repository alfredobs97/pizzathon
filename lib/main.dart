import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart'; // Importamos el servicio que creamos

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ESTA ES LA CLAVE: Solo activamos Crashlytics si NO estamos en un entorno Web.
  if (!kIsWeb) {
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizzathon',
      debugShowCheckedModeBanner: false, // Quitamos la etiqueta de debug para que se vea más limpio
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      // Aquí está la magia: en lugar de un Scaffold fijo, cargamos el AuthGate
      home: const AuthGate(),
    );
  }
}

/// El "Portero": Escucha a Firebase y decide si vas al login o al perfil
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras comprueba, mostramos una rueda de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si hay datos (usuario logueado), le pasamos el usuario a la pantalla de perfil
        if (snapshot.hasData) {
          return ProfileScreen(user: snapshot.data!);
        }

        // Si no, a la pantalla de login
        return const LoginScreen();
      },
    );
  }
}

/// Pantalla de Login
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenido a Pizzathon')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final userCredential = await authService.signInWithGoogle();
            if (userCredential == null) {
              // Si falla o el usuario cierra la ventana, lo pintamos en consola
              debugPrint("Login fallido o cancelado por el usuario.");
            }
          },
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión con Google'),
        ),
      ),
    );
  }
}

/// Pantalla de Perfil
class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    // Separamos el nombre y apellido (es un apaño rápido porque Google manda todo junto)
    final nameParts = (user.displayName ?? "Usuario Anónimo").split(" ");
    final firstName = nameParts.isNotEmpty ? nameParts.first : "";
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut(); // Llamamos al logout
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 20),
            // Datos
            Text('Nombre: $firstName', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Apellido: $lastName', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Text('Email: ${user.email}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}