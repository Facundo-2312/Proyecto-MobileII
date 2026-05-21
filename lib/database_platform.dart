import 'database_platform_io.dart'
    if (dart.library.html) 'database_platform_web.dart';

Future<void> initializeDatabaseFactory() => initializeDatabaseFactoryPlatform();
