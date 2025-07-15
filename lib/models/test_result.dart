class TestResult {
  final int line;
  final String letter;
  final String userResponse;
  final bool isCorrect;
  final DateTime timestamp;

  TestResult({
    required this.line,
    required this.letter,
    required this.userResponse,
    required this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      'letter': letter,
      'userResponse': userResponse,
      'isCorrect': isCorrect,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      line: json['line'],
      letter: json['letter'],
      userResponse: json['userResponse'],
      isCorrect: json['isCorrect'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class EyeTrackingData {
  final DateTime timestamp;
  final double leftEyeX;
  final double leftEyeY;
  final double rightEyeX;
  final double rightEyeY;
  final double blinkDuration;
  final bool isBlinking;

  EyeTrackingData({
    required this.timestamp,
    required this.leftEyeX,
    required this.leftEyeY,
    required this.rightEyeX,
    required this.rightEyeY,
    required this.blinkDuration,
    required this.isBlinking,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'leftEyeX': leftEyeX,
      'leftEyeY': leftEyeY,
      'rightEyeX': rightEyeX,
      'rightEyeY': rightEyeY,
      'blinkDuration': blinkDuration,
      'isBlinking': isBlinking,
    };
  }

  factory EyeTrackingData.fromJson(Map<String, dynamic> json) {
    return EyeTrackingData(
      timestamp: DateTime.parse(json['timestamp']),
      leftEyeX: json['leftEyeX'],
      leftEyeY: json['leftEyeY'],
      rightEyeX: json['rightEyeX'],
      rightEyeY: json['rightEyeY'],
      blinkDuration: json['blinkDuration'],
      isBlinking: json['isBlinking'],
    );
  }
}

class VisionTestSession {
  final String sessionId;
  final String testType;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TestResult> testResults;
  final List<EyeTrackingData> eyeTrackingData;
  final double? visionScore;
  final String? diagnosis;
  final List<String> recommendations;

  VisionTestSession({
    required this.sessionId,
    required this.testType,
    required this.startTime,
    this.endTime,
    required this.testResults,
    required this.eyeTrackingData,
    this.visionScore,
    this.diagnosis,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'testType': testType,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'testResults': testResults.map((r) => r.toJson()).toList(),
      'eyeTrackingData': eyeTrackingData.map((e) => e.toJson()).toList(),
      'visionScore': visionScore,
      'diagnosis': diagnosis,
      'recommendations': recommendations,
    };
  }

  factory VisionTestSession.fromJson(Map<String, dynamic> json) {
    return VisionTestSession(
      sessionId: json['sessionId'],
      testType: json['testType'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      testResults: (json['testResults'] as List)
          .map((r) => TestResult.fromJson(r))
          .toList(),
      eyeTrackingData: (json['eyeTrackingData'] as List)
          .map((e) => EyeTrackingData.fromJson(e))
          .toList(),
      visionScore: json['visionScore'],
      diagnosis: json['diagnosis'],
      recommendations: List<String>.from(json['recommendations']),
    );
  }
}