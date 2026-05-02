// lib/screens/scan_screen.dart

import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../models/employee_model.dart';
import '../providers/settings_provider.dart';
import '../services/attendance_service.dart';
import '../services/database_service.dart';
import '../services/notif_service.dart';
import '../services/scanner_service.dart';

class ScanScreen extends StatefulWidget {
  final bool isAdminMode;
  const ScanScreen({super.key, this.isAdminMode = false});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cam;
  late final TabController _tab;
  final _audio  = AudioPlayer();
  final _db     = DatabaseService();
  bool _loadingCamera    = true;
  bool _permissionDenied = false;
  bool _processing       = false;
  String _result  = '';
  bool   _ok      = false;
  Rect?  _faceRect;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _openCamera();
  }

  Future<void> _openCamera() async {
    setState(() { _loadingCamera = true; _permissionDenied = false; });
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() { _permissionDenied = true; _loadingCamera = false; });
      return;
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() { _permissionDenied = true; _loadingCamera = false; });
        return;
      }
      _cam = CameraController(cameras[0], ResolutionPreset.medium,
          enableAudio: false);
      await _cam!.initialize();
    } on CameraException {
      _permissionDenied = true;
    } finally {
      if (mounted) setState(() => _loadingCamera = false);
    }
  }

  Future<void> _scanQr() async {
    if (_cam == null || _processing) return;
    final settings = context.read<SettingsProvider>();
    setState(() => _processing = true);
    try {
      final pic = await _cam!.takePicture();
      final qr  = await ScannerService.instance.scanQRFromFile(pic.path);
      if (qr == null) return _show(false, settings.t('qr_not_detected'));
      final emp = await _db.getEmployeeByQR(qr);
      await _markAttendance(emp, settings.t('scan_qr'));
    } catch (_) {
      _show(false, settings.t('scan_error_qr'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _scanText() async {
    if (_cam == null || _processing) return;
    final settings = context.read<SettingsProvider>();
    setState(() => _processing = true);
    try {
      final pic  = await _cam!.takePicture();
      final text = await ScannerService.instance.readTextFromFile(pic.path);
      Employee? emp;
      if (text.extractedId != null) {
        emp = await _db.getEmployeeByQR(text.extractedId!);
      }
      emp ??= (await _db.getAllEmployees())
          .where((e) =>
              text.fullText.toLowerCase().contains(e.name.toLowerCase()))
          .firstOrNull;
      await _markAttendance(emp, settings.t('text_recognized'));
    } catch (_) {
      _show(false, settings.t('scan_error_text'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _scanFace() async {
    if (_cam == null || _processing) return;
    final settings = context.read<SettingsProvider>();
    setState(() => _processing = true);
    try {
      final pic      = await _cam!.takePicture();
      final input    = InputImage.fromFilePath(pic.path);
      final detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableContours:  false,
        ),
      );
      final faces = await detector.processImage(input);
      await detector.close();
      if (faces.isEmpty) {
        setState(() => _faceRect = null);
        return _show(false, settings.t('face_not_detected'));
      }
      final face = faces.first;
      setState(() => _faceRect = face.boundingBox);
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title:   Text(settings.t('face_confirm_title')),
              content: Text(settings.t('face_confirm_msg')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(settings.t('cancel'))),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(settings.t('confirm'))),
              ],
            ),
          ) ??
          false;
      if (confirmed) _show(true, settings.t('face_confirmed'));
    } catch (_) {
      _show(false, settings.t('scan_error_face'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _markAttendance(Employee? emp, String source) async {
    final attendance = context.read<AttendanceService>();
    final settings   = context.read<SettingsProvider>();
    if (emp == null) {
      return _show(false, '$source: ${settings.t('employee_not_found')}');
    }
    final result = await attendance.processScan(emp);
    if (settings.soundEnabled) {
      try { await _audio.play(AssetSource('sounds/beep.mp3')); } catch (_) {}
    }
    if (settings.vibrationEnabled &&
        ((await Vibration.hasVibrator()) ?? false)) {
      Vibration.vibrate(duration: 180);
    } else {
      HapticFeedback.mediumImpact();
    }
    if (settings.notificationsEnabled) {
      await NotifService.instance
          .showScanSuccess(emp.name, emp.department, result.type.name);
    }
    _show(true, result.message);
  }

  void _show(bool ok, String message) =>
      setState(() { _ok = ok; _result = message; });

  @override
  void dispose() {
    _cam?.dispose();
    _audio.dispose();
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (!kIsWeb && Platform.isWindows && _permissionDenied) {
      return _permissionDeniedView(settings);
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: widget.isAdminMode
            ? null
            : const BackButton(color: Colors.white),
        title: Text(settings.t('scanner_label'),
            style: const TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tab,
          labelColor:      Colors.white,
          indicatorColor:  Colors.greenAccent,
          tabs: [
            Tab(text: settings.t('scan_qr')),
            Tab(text: settings.t('scan_text')),
            Tab(text: settings.t('scan_face')),
          ],
        ),
      ),
      body: _loadingCamera
          ? Center(child: Text(settings.t('loading'),
                style: const TextStyle(color: Colors.white)))
          : _cam == null
              ? _noCameraView(settings)
              : Stack(children: [
                  Positioned.fill(child: CameraPreview(_cam!)),
                  Positioned.fill(
                      child: CustomPaint(
                          painter: _ScannerOverlayPainter())),
                  if (_faceRect != null)
                    Positioned.fill(
                        child: CustomPaint(
                            painter: _FaceRectPainter(_faceRect!))),
                  Positioned(
                    left: 16, right: 16, bottom: 120,
                    child: AnimatedOpacity(
                      opacity:  _result.isEmpty ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _ok
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_result,
                            style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16, right: 16, bottom: 26,
                    child: ElevatedButton.icon(
                      onPressed: _processing
                          ? null
                          : () {
                              switch (_tab.index) {
                                case 0: _scanQr();   break;
                                case 1: _scanText(); break;
                                default: _scanFace();
                              }
                            },
                      icon: Icon(_processing
                          ? Icons.hourglass_top : Icons.camera_alt),
                      label: Text(_processing
                          ? settings.t('processing')
                          : settings.t('scan_badge')),
                    ),
                  ),
                ]),
    );
  }

  Widget _permissionDeniedView(SettingsProvider settings) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.videocam_off, color: Colors.white54, size: 54),
        const SizedBox(height: 12),
        Text(settings.t('camera_denied'),
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        const SizedBox(height: 12),
        ElevatedButton(
            onPressed: _openCamera,
            child: Text(settings.t('retry'))),
      ]),
    ),
  );

  Widget _noCameraView(SettingsProvider settings) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(settings.t('no_camera'),
          style: const TextStyle(color: Colors.white)),
      const SizedBox(height: 10),
      OutlinedButton(
          onPressed: _openCamera,
          child: Text(settings.t('retry'))),
    ]),
  );
}

// ── Painters ──────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width:  size.width * 0.7,
      height: size.width * 0.7,
    );
    final clear = Paint()..blendMode = BlendMode.clear;
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(scanRect, const Radius.circular(18)), clear);
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(18)),
      Paint()
        ..color       = Colors.greenAccent
        ..strokeWidth = 3
        ..style       = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FaceRectPainter extends CustomPainter {
  final Rect rect;
  const _FaceRectPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      rect,
      Paint()
        ..color       = Colors.yellowAccent
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceRectPainter oldDelegate) =>
      oldDelegate.rect != rect;
}