import 'test_result.dart';

class TestSession {
  final String sessionId;
  final DateTime startTime;
  List<TestResult> snellenResults = [];
  List<TestResult> amslerResults = [];
  List<EyeTrackingData> eyeTrackingData = [];
  
  TestSession({
    required this.sessionId,
    required this.startTime,
  });

  void addSnellenResult(TestResult result) {
    snellenResults.add(result);
  }

  void addAmslerResult(TestResult result) {
    amslerResults.add(result);
  }

  void addEyeTrackingData(EyeTrackingData data) {
    eyeTrackingData.add(data);
  }

  List<TestResult> getAllResults() {
    return [...snellenResults, ...amslerResults];
  }

  bool get isSnellenComplete => snellenResults.isNotEmpty;
  bool get isAmslerComplete => amslerResults.isNotEmpty;
  bool get isComplete => isSnellenComplete && isAmslerComplete;
}

class TestSessionManager {
  static final TestSessionManager _instance = TestSessionManager._internal();
  factory TestSessionManager() => _instance;
  TestSessionManager._internal();

  TestSession? _currentSession;

  TestSession startNewSession() {
    _currentSession = TestSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    return _currentSession!;
  }

  TestSession? getCurrentSession() {
    return _currentSession;
  }

  void addSnellenResult(TestResult result) {
    _currentSession?.addSnellenResult(result);
  }

  void addAmslerResult(TestResult result) {
    _currentSession?.addAmslerResult(result);
  }

  void addEyeTrackingData(EyeTrackingData data) {
    _currentSession?.addEyeTrackingData(data);
  }

  void clearSession() {
    _currentSession = null;
  }
}