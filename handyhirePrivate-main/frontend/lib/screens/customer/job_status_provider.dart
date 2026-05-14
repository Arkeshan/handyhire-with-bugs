import 'package:flutter/material.dart';

/// App-wide job status holder. Kept as static singleton to match existing
/// screen code. In a production refactor you'd replace this with Provider /
/// Riverpod / BLoC, but swapping it out isn't required to get the app running.
class JobStatusProvider {
  static bool isSearching = false;
  static String? targetProvider;
  static String statusMessage = "Finding nearby providers...";
  static int currentStep = 0;

  static ValueNotifier<int> stepNotifier = ValueNotifier<int>(0);

  static bool isPaused = false;

  static double currentPrice = 2500.0;
  static bool isNegotiating = false;
  static String providerMessage = "I can do this for Rs. 5000 due to distance.";

  static void updateStatus(String message, int step) {
    statusMessage = message;
    currentStep = step;
    if (step > 0) isSearching = true;
    stepNotifier.value = step;
  }

  static void resetStatus() {
    isSearching = false;
    targetProvider = null;
    statusMessage = "Finding nearby providers...";
    currentStep = 0;
    currentPrice = 2500.0;
    isNegotiating = false;
    isPaused = false;
    stepNotifier.value = 0;
  }
}
