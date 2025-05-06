import 'package:go_router/go_router.dart';
import 'package:seminari_flutter/screens/auth/login_screen.dart';
import 'package:seminari_flutter/screens/borrar_screen.dart';
import 'package:seminari_flutter/screens/details_screen.dart';
import 'package:seminari_flutter/screens/editar_screen.dart';
import 'package:seminari_flutter/screens/imprimir_screen.dart';
import 'package:seminari_flutter/screens/home_screen.dart';
import 'package:seminari_flutter/screens/perfil_screen.dart';
import 'package:seminari_flutter/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:seminari_flutter/provider/users_provider.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/' : '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details',
          builder: (context, state) => const DetailsScreen(),
          routes: [
            GoRoute(
              path: 'imprimir',
              builder: (context, state) => const ImprimirScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'editar',
          builder: (context, state) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            if (userProvider.loggedInUser != null) {
              return EditarScreen(user: userProvider.loggedInUser!); // Lleva a la edición del perfil
            } else {
              return LoginPage(); // Redirigir al login si no hay usuario autenticado
            }
          },
        ),
        GoRoute(
          path: 'borrar',
          builder: (context, state) => const BorrarScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const PerfilScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/perfil',
      builder: (context, state) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.loggedInUser != null) {
          return const PerfilScreen(); // Lleva al perfil del usuario
        } else {
          return LoginPage(); // Redirigir al login si no hay usuario autenticado
        }
      },
    ),
  ],
);
