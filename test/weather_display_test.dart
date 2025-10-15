import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/weather_display.dart';

void main() {
  group('Temperature Conversion Unit Tests', () {
    late _WeatherConversionHelper weatherConversionHelper;

    setUp(() {
      weatherConversionHelper = _WeatherConversionHelper();
    });

    test('Celsius to Fahrenheit conversion is correct', () {
      expect(weatherConversionHelper.celsiusToFahrenheit(0), 32.0);
      expect(weatherConversionHelper.celsiusToFahrenheit(100), 212.0);
      expect(weatherConversionHelper.celsiusToFahrenheit(-40), -40.0);
    });

    test('Fahrenheit to Celsius conversion is correct', () {
      expect(weatherConversionHelper.fahrenheitToCelsius(32), 0.0);
      expect(weatherConversionHelper.fahrenheitToCelsius(212), 100.0);
      expect(weatherConversionHelper.fahrenheitToCelsius(-40), -40.0);
    });
  });

  group('Weather Display Widget Tests', () {
    testWidgets('Initially shows loading indicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('City: '), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('City dropdown shows all cities', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('New York'), findsWidgets);
      expect(find.text('London'), findsWidgets);
      expect(find.text('Tokyo'), findsWidgets);
      expect(find.text('Invalid City'), findsWidgets);
    });

    testWidgets('Selecting London shows London weather', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('London').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('London'), findsAtLeastNWidgets(1));
      expect(find.text('15.0°C'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('8.5 km/h'), findsOneWidget);
    });

    testWidgets('Selecting Tokyo shows Tokyo weather', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tokyo').last);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Tokyo'), findsAtLeastNWidgets(1));
      expect(find.text('Cloudy'), findsOneWidget);
      expect(find.text('25.0°C'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('5.2 km/h'), findsOneWidget);
    });

    testWidgets('Fahrenheit conversion displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WeatherDisplay())),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('22.5°C'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(find.text('72.5°F'), findsOneWidget);
    });
  });

  group('Weather Data Model Tests', () {
    test('WeatherData.fromJson with complete data', () {
      final json = {
        'city': 'London',
        'temperature': 15.0,
        'description': 'Rainy',
        'humidity': 85,
        'windSpeed': 8.5,
        'icon': '🌧️',
      };

      final weather = WeatherData.fromJson(json);

      expect(weather.city, 'London');
      expect(weather.temperatureCelsius, 15.0);
      expect(weather.description, 'Rainy');
      expect(weather.humidity, 85);
      expect(weather.windSpeed, 8.5);
      expect(weather.icon, '🌧️');
    });

    test('WeatherData.fromJson with null data uses defaults', () {
      final weather = WeatherData.fromJson(null);

      expect(weather.city, 'Unknown');
      expect(weather.temperatureCelsius, 0.0);
      expect(weather.description, 'Unknown');
      expect(weather.humidity, 0);
      expect(weather.windSpeed, 0.0);
      expect(weather.icon, '?');
    });
  });
}

class _WeatherConversionHelper {
  double celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }
}
