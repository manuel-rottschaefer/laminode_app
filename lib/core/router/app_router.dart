import 'package:go_router/go_router.dart';
import 'package:laminode_app/features/profile_editor/presentation/screens/profile_editor_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ProfileEditorScreen(),
    ),
  ],
);
