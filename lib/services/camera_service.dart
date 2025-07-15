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

  // Capture eye image during test
  Future<String?> captureEyeImage(CameraController cameraController, {String? testType}) async {
    if (_isCapturing) return null; // Skip if already capturing
    
    try {
      if (!cameraController.value.isInitialized) {
        print('Camera not initialized');
        return null;
      }

      _isCapturing = true;

      // Get temporary directory for storing images
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = path.join(tempDir.path, 'eye_capture_${timestamp}.jpg');

      // Capture image
      final XFile imageFile = await cameraController.takePicture();
      
      // Copy to our designated path
      final File savedImage = await File(imageFile.path).copy(imagePath);
      
      // Store the image path
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

  // Capture multiple images during test session
  Future<void> captureTestSession(CameraController cameraController, String testType) async {
    // Capture images at different intervals during test
    for (int i = 0; i < 3; i++) {
      await Future.delayed(Duration(seconds: 2 + i * 3)); // Stagger captures
      await captureEyeImage(cameraController, testType: testType);
    }
  }

  // Analyze all captured images using AI
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

  // Get the best analysis result (highest confidence)
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

  // Get aggregate analysis from all captured images
  EyeAnalysisResult? getAggregateAnalysis() {
    if (_eyeAnalyses.isEmpty) return null;
    
    // Count conditions and find most common
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
    
    // Find most common condition
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

  // Cleanup captured images and analysis results
  Future<void> cleanup() async {
    // Delete captured image files
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
    
    // Clear lists
    _capturedImages.clear();
    _eyeAnalyses.clear();
  }

  // Get captured image paths (for debugging/review)
  List<String> getCapturedImagePaths() {
    return List.from(_capturedImages);
  }

  // Get all analysis results
  List<EyeAnalysisResult> getAllAnalysisResults() {
    return List.from(_eyeAnalyses);
  }

  // Periodic capture during active test
  Future<void> startPeriodicCapture(CameraController cameraController, String testType) async {
    // Capture an image every 10 seconds during test
    // This would be called when test starts
    
    try {
      // Initial capture
      await captureEyeImage(cameraController, testType: testType);
      
      // Schedule additional captures (in a real implementation, 
      // you'd use a Timer or stream subscription)
      await Future.delayed(const Duration(seconds: 10));
      await captureEyeImage(cameraController, testType: testType);
      
      await Future.delayed(const Duration(seconds: 10));
      await captureEyeImage(cameraController, testType: testType);
      
    } catch (e) {
      print('Error in periodic capture: $e');
    }
  }

  // Generate mock eye tracking data from captured images
  List<EyeTrackingData> generateEyeTrackingData() {
    final eyeTrackingData = <EyeTrackingData>[];
    final now = DateTime.now();
    
    // Generate mock tracking data for demonstration
    // In a real implementation, this would extract actual eye positions from images
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

  // Check if any images have been captured
  bool hasCaptures() {
    return _capturedImages.isNotEmpty;
  }

  // Get capture statistics
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