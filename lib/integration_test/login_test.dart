import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rumba_go_app/main.dart' as app;
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verifica si el usuario se loguea exitosamente con Firebase',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Aquí deberías simular que el usuario presiona el botón de Google Sign-In,
    // pero debido a que la UI de Google no puede ser controlada en tests automatizados,
    // esta prueba solo verifica si el usuario ya está autenticado.
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('✅ Usuario autenticado: ${user.email}');
    } else {
      print('❌ Ningún usuario autenticado');
    }

    expect(user != null, true);
  });
}
