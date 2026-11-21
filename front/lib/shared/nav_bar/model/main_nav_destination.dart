import 'package:langwij/shared/app/routing/routing.dart';

/// Destinations of the bottom navigation bar, in display order.
enum MainNavDestination {
  vocabulary(AppRoutes.home),
  specialized(AppRoutes.specialized),
  tools(AppRoutes.tools),
  language(AppRoutes.language);

  const MainNavDestination(this.routePath);

  final String routePath;
}
