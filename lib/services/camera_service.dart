import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'ml_service.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  final MLService _mlService = MLService();
  final List<String> _capturedImages = [];
  final List<EyeAnalysisResult> _eyeAnalyses = [];
  bool _isCapturing = false;

  Future<String?> captureEyeImage(CameraController cameraController, {String? testType}) async {
    if (_isCapturing) return null;
    
    try {
      if (!cameraController.value.isInitialized) {
        print('Camera not initialized');
        return null;
      }

      _isCapturing = true;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = path.join(tempDir.path, 'eye_capture_${timestamp}.jpg');

      final XFile imageFile = await cameraController.takePicture();
      
      final File savedImage = await File(imageFile.path).copy(imagePath);
      
      _capturedImages.add(savedImage.path);
      
      print('Eye image captured: ${savedImage.path}');
      return savedImage.path;
      
    } catch (e) {
      print('Error capturing eye image: $e');
      return null;
    } finally {
      _isCapturing = false;
    }
  }

  Future<void> captureTestSession(CameraController cameraController, String testType) async {
    // Staggered captures during test session
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(seconds: 2 + i * 3)); // Stagger captures
      await captureEyeImage(cameraController, testType: testType);
    }
  }

  Future<List<EyeAnalysisResult>> analyzeAllCapturedImages() async {
    final results = <EyeAnalysisResult>[];
    
    for (final imagePath in _capturedImages) {
      try {
        final analysisResult = await _mlService.analyzeEyeImage(imagePath);
        results.add(analysisResult);
        _eyeAnalyses.add(analysisResult);
      } catch (e) {
        print('Error analyzing image $imagePath: $e');
      }
    }
    
    return results;
  }

  EyeAnalysisResult? getBestAnalysisResult() {
    if (_eyeAnalyses.isEmpty) return null;
    
    EyeAnalysisResult bestResult = _eyeAnalyses.first;
    for (final result in _eyeAnalyses) {
      if (result.confidence > bestResult.confidence) {
        bestResult = result;
      }
    }
    
    return bestResult;
  }

  EyeAnalysisResult? getAggregateAnalysis() {
    if (_eyeAnalyses.isEmpty) return null;
    
    final conditionCounts = <String, int>{};
    double totalConfidence = 0.0;
    final allRiskFactors = <String>{};
    final allRecommendations = <String>{};
    
    for (final analysis in _eyeAnalyses) {
      conditionCounts[analysis.condition] = (conditionCounts[analysis.condition] ?? 0) + 1;
      totalConfidence += analysis.confidence;
      allRiskFactors.addAll(analysis.riskFactors);
      allRecommendations.addAll(analysis.recommendations);
    }
    
    String mostCommonCondition = 'normal';
    int maxCount = 0;
    
    conditionCounts.forEach((condition, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommonCondition = condition;
      }
    });
    
    final averageConfidence = totalConfidence / _eyeAnalyses.length;
    
    return EyeAnalysisResult(
      condition: mostCommonCondition,
      confidence: averageConfidence,
      riskFactors: allRiskFactors.toList(),
      recommendations: allRecommendations.toList(),
    );
  }

  Future<void> cleanup() async {
    for (final imagePath in _capturedImages) {
      try {
        final file = File(imagePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting image file $imagePath: $e');
      }
    }
    
    _capturedImages.clear();
    _eyeAnalyses.clear();
  }

  List<String> getCapturedImagePaths() {
    return List.from(_capturedImages);
  }

  List<EyeAnalysisResult> getAllAnalysisResults() {
    return List.from(_eyeAnalyses);
  }

  Future<void> startPeriodicCapture(CameraController cameraController, String testType) async {
    // Captures images at 10-second intervals
    
    try {
      await captureEyeImage(cameraController, testType: testType);
      
      // Additional timed captures
      await Future.delayed(const Duration(seconds: 10));
      await captureEyeImage(cameraController, testType: testType);
      
      await Future.delayed(const Duration(seconds: 10));
      await captureEyeImage(cameraController, testType: testType);
      
    } catch (e) {
      print('Error in periodic capture: $e');
    }
  }

  List<EyeTrackingData> generateEyeTrackingData() {
    final eyeTrackingData = <EyeTrackingData>[];
    final now = DateTime.now();
    
    // Mock data for demo - production extracts from actual images
    for (int i = 0; i < 50; i++) {
      eyeTrackingData.add(EyeTrackingData(
        timestamp: now.subtract(Duration(seconds: i)),
        leftEyeX: 100.0 + (i % 10 - 5),
        leftEyeY: 50.0 + (i % 8 - 4),
        rightEyeX: 200.0 + (i % 10 - 5),
        rightEyeY: 50.0 + (i % 8 - 4),
        blinkDuration: i % 20 == 0 ? 150.0 : 0.0,
        isBlinking: i % 20 == 0,
      ));
    }
    
    return eyeTrackingData;
  }

  bool hasCaptures() {
    return _capturedImages.isNotEmpty;
  }

  Map<String, dynamic> getCaptureStatistics() {
    return {
      'totalCaptures': _capturedImages.length,
      'totalAnalyses': _eyeAnalyses.length,
      'bestConfidence': _eyeAnalyses.isNotEmpty 
          ? _eyeAnalyses.map((a) => a.confidence).reduce((a, b) => a > b ? a : b)
          : 0.0,
      'averageConfidence': _eyeAnalyses.isNotEmpty
          ? _eyeAnalyses.map((a) => a.confidence).reduce((a, b) => a + b) / _eyeAnalyses.length
          : 0.0,
    };
  }
}