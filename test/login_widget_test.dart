import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rumba_go_app/vista/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  testWidgets('Botón de login con Google aparece y se puede presionar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginView()),
    );

    final googleLoginButton = find.text('Continuar con Google');
    expect(googleLoginButton, findsOneWidget);

    await tester.tap(googleLoginButton);
    await tester.pump(); // Ejecuta cualquier animación

    // Aquí podrías agregar una expectativa si mockeas el login real
    // pero en web no puedes simular toda la lógica de Firebase directamente
  });
}
