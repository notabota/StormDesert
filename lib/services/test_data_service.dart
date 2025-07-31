import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/test_result.dart';
import '../models/test_session.dart';

class TestDataService {
  static final TestDataService _instance = TestDataService._internal();
  factory TestDataService() => _instance;
  TestDataService._internal();

  final List<VisionTestSession> _testHistory = [];
  final List<TestSession> _allSessions = [];

  void addCompletedSession(TestSession session) {
    _allSessions.add(session);
    
    final visionSession = VisionTestSession(
      sessionId: session.sessionId,
      testType: _determineTestType(session),
      startTime: session.startTime,
      endTime: DateTime.now(),
      testResults: session.getAllResults(),
      eyeTrackingData: session.eyeTrackingData,
      visionScore: calculateOverallScore(session),
      diagnosis: generateDiagnosis(session),
      recommendations: generateRecommendations(session),
    );
    
    _testHistory.add(visionSession);
  }

  String _determineTestType(TestSession session) {
    if (session.isSnellenComplete && session.isAmslerComplete) {
      return 'Complete Vision Test';
    } else if (session.isSnellenComplete) {
      return 'Snellen Test';
    } else if (session.isAmslerComplete) {
      return 'Amsler Grid Test';
    }
    return 'Incomplete Test';
  }

  double calculateOverallScore(TestSession session) {
    double totalScore = 0.0;
    int testCount = 0;

    if (session.isSnellenComplete) {
      totalScore += calculateSnellenScore(session.snellenResults);
      testCount++;
    }

    if (session.isAmslerComplete) {
      totalScore += calculateAmslerScore(session.amslerResults);
      testCount++;
    }

    return testCount > 0 ? totalScore / testCount : 0.0;
  }

  double calculateSnellenScore(List<TestResult> results) {
    if (results.isEmpty) return 0.0;

    final visionLevels = ['20/200', '20/100', '20/70', '20/50', '20/40', '20/30', '20/25', '20/20'];
    int bestLine = -1;
    
    for (final result in results) {
      if (result.isCorrect && result.line > bestLine) {
        bestLine = result.line;
      }
    }

    if (bestLine == -1) return 0.1; // Very poor vision if no correct answers

    switch (bestLine) {
      case 0: return 0.2; // 20/200
      case 1: return 0.3; // 20/100
      case 2: return 0.4; // 20/70
      case 3: return 0.5; // 20/50
      case 4: return 0.6; // 20/40
      case 5: return 0.7; // 20/30
      case 6: return 0.8; // 20/25
      case 7: return 0.9; // 20/20
      default: return 0.1;
    }
  }

  double calculateAmslerScore(List<TestResult> results) {
    if (results.isEmpty) return 0.0;

    final result = results.first;
    final response = result.userResponse;
    
    final distortionMatch = RegExp(r'Distortion Points: (\d+)').firstMatch(response);
    final distortionCount = distortionMatch != null ? int.parse(distortionMatch.group(1)!) : 0;
    
    final hasWavyLines = response.contains('wavy_lines: Yes');
    final hasBlurredAreas = response.contains('blurred_areas: Yes');
    final hasMissingSpots = response.contains('missing_spots: Yes');
    final hasDistortedLines = response.contains('straight_lines: No') || response.contains('straight_lines: Some areas distorted');
    final hasFocusDifficulty = response.contains('focus_difficulty: Moderate') || response.contains('focus_difficulty: Severe');
    
    double score = 1.0;
    
    if (distortionCount > 0) score -= 0.1 * min(distortionCount, 5);
    if (hasWavyLines) score -= 0.15;
    if (hasBlurredAreas) score -= 0.15;
    if (hasMissingSpots) score -= 0.2;
    if (hasDistortedLines) score -= 0.15;
    if (hasFocusDifficulty) score -= 0.1;
    
    return max(0.1, score);
  }

  String generateDiagnosis(TestSession session) {
    final score = calculateOverallScore(session);
    
    if (score >= 0.8) {
      return 'Excellent vision health. No significant visual impairments detected.';
    } else if (score >= 0.6) {
      return 'Good vision with minor variations. Regular monitoring recommended.';
    } else if (score >= 0.4) {
      return 'Moderate vision concerns detected. Professional eye examination recommended.';
    } else {
      return 'Significant vision issues detected. Immediate professional consultation strongly recommended.';
    }
  }

  List<String> generateRecommendations(TestSession session) {
    final recommendations = <String>[];
    final score = calculateOverallScore(session);
    
    if (score >= 0.8) {
      recommendations.addAll([
        'Maintain regular eye check-ups every 2 years',
        'Continue protecting your eyes from UV rays',
        'Follow the 20-20-20 rule when using digital devices',
        'Maintain a healthy diet rich in omega-3 fatty acids',
      ]);
    } else if (score >= 0.6) {
      recommendations.addAll([
        'Schedule an eye examination within 6 months',
        'Consider prescription glasses if not already wearing them',
        'Take frequent breaks from digital screens',
        'Ensure adequate lighting when reading or working',
      ]);
    } else if (score >= 0.4) {
      recommendations.addAll([
        'Schedule a comprehensive eye examination within 1 month',
        'Consider vision correction options with an eye care professional',
        'Monitor symptoms and changes in vision',
        'Avoid driving at night if vision is compromised',
      ]);
    } else {
      recommendations.addAll([
        'Seek immediate professional eye care consultation',
        'Consider emergency eye examination if symptoms are severe',
        'Avoid activities that require precise vision until evaluated',
        'Keep a record of vision changes and symptoms',
      ]);
    }

    if (session.isAmslerComplete) {
      final amslerScore = calculateAmslerScore(session.amslerResults);
      if (amslerScore < 0.7) {
        recommendations.add('Request macular degeneration screening during eye exam');
      }
    }

    return recommendations;
  }

  String getRiskLevel(double score) {
    if (score >= 0.7) return 'Low';
    if (score >= 0.4) return 'Medium';
    return 'High';
  }

  Map<String, dynamic> getTestStatistics() {
    if (_testHistory.isEmpty) {
      return {
        'totalTests': 0,
        'averageScore': 0.0,
        'lowRiskCount': 0,
        'mediumRiskCount': 0,
        'highRiskCount': 0,
        'lastTestDate': null,
        'bestScore': 0.0,
        'worstScore': 0.0,
      };
    }

    final scores = _testHistory.map((s) => s.visionScore ?? 0.0).toList();
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;
    
    int lowRiskCount = 0, mediumRiskCount = 0, highRiskCount = 0;
    
    for (final score in scores) {
      final risk = getRiskLevel(score);
      switch (risk) {
        case 'Low': lowRiskCount++; break;
        case 'Medium': mediumRiskCount++; break;
        case 'High': highRiskCount++; break;
      }
    }

    return {
      'totalTests': _testHistory.length,
      'averageScore': averageScore,
      'lowRiskCount': lowRiskCount,
      'mediumRiskCount': mediumRiskCount,
      'highRiskCount': highRiskCount,
      'lastTestDate': _testHistory.isNotEmpty ? _testHistory.last.startTime : null,
      'bestScore': scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 0.0,
      'worstScore': scores.isNotEmpty ? scores.reduce((a, b) => a < b ? a : b) : 0.0,
    };
  }

  List<VisionTestSession> getTestHistory() {
    return List.from(_testHistory.reversed);
  }

  List<VisionTestSession> getRecentActivity({int limit = 5}) {
    return _testHistory.reversed.take(limit).toList();
  }

  void clearAllData() {
    _testHistory.clear();
    _allSessions.clear();
  }
}