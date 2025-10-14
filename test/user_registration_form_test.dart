import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/helper/app_regex.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';

void main() {
  group('AppRegex Email Validation Tests', () {
    test('Valid email should pass', () {
      expect(AppRegex.isEmailValid('test@example.com'), true);
    });

    test('Invalid email should fail', () {
      expect(AppRegex.isEmailValid('a@'), false);
      expect(AppRegex.isEmailValid('@b'), false);
      expect(AppRegex.isEmailValid('@example.com'), false);
      expect(AppRegex.isEmailValid('test@.com'), false);
    });
  });

  group('AppRegex Password Validation Tests', () {
    test('Valid password should pass', () {
      expect(AppRegex.isPasswordValid('Aa1234567@'), true);
    });

    test('Weak password should fail', () {
      expect(AppRegex.isPasswordValid('Aa123'), false);
      expect(AppRegex.isPasswordValid('a1234567@'), false);
      expect(AppRegex.isPasswordValid('A1234567@'), false);
      expect(AppRegex.isPasswordValid('AaPassword@'), false);
      expect(AppRegex.isPasswordValid('Aa1234567'), false);
      expect(AppRegex.isPasswordValid(''), false);
    });
  });

  group('User Registration Form Widget Tests', () {
    testWidgets('Form shows all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid@',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows error for weak password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'weakpass',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Password is too weak'), findsOneWidget);
    });

    testWidgets('Shows error when passwords do not match', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Aa1234567@',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'Aa123',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Form submits successfully with valid data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      // Fill all fields with valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'Rasha Alaswad',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'rasha@example.com',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Aa1234567@',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'Aa1234567@',
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Registration successful!'), findsOneWidget);
    });

    testWidgets('Does not submit with empty fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UserRegistrationForm())),
      );

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Registration successful!'), findsNothing);
    });
  });
}
