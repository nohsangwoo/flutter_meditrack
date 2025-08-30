import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/medication.dart';

class MedicationProgressLiquid extends StatefulWidget {
  final List<Medication> medications;
  final double height;
  
  const MedicationProgressLiquid({
    super.key,
    required this.medications,
    this.height = 180,
  });

  @override
  State<MedicationProgressLiquid> createState() => _MedicationProgressLiquidState();
}

class _MedicationProgressLiquidState extends State<MedicationProgressLiquid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  List<MedicationStatus> _getMedicationStatuses() {
    final now = DateTime.now();
    final todayDate = Medication.dateOnly(now);
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTimeInMinutes = currentHour * 60 + currentMinute;
    
    List<MedicationStatus> statuses = [];
    
    // Sort medications by time
    final sortedMeds = List.from(widget.medications)
      ..sort((a, b) {
        final aMinutes = a.time.hour * 60 + a.time.minute;
        final bMinutes = b.time.hour * 60 + b.time.minute;
        return aMinutes.compareTo(bMinutes);
      });
    
    for (var med in sortedMeds) {
      final medTimeInMinutes = med.time.hour * 60 + med.time.minute;
      final isTaken = med.hasTakenMedicationTodayDate == todayDate;
      final isPast = medTimeInMinutes <= currentTimeInMinutes;
      
      statuses.add(MedicationStatus(
        medication: med,
        isTaken: isTaken,
        isPast: isPast,
        isUpcoming: !isPast,
        timeString: _formatTime(med.time),
      ));
    }
    
    return statuses;
  }
  
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  double _calculateProgress() {
    if (widget.medications.isEmpty) return 0.15;
    
    final statuses = _getMedicationStatuses();
    final totalMeds = statuses.length;
    final takenMeds = statuses.where((s) => s.isTaken).length;
    
    // Base level + progress
    return 0.15 + (takenMeds / totalMeds) * 0.7;
  }
  
  Color _getProgressColor() {
    final statuses = _getMedicationStatuses();
    final pastMeds = statuses.where((s) => s.isPast).toList();
    
    if (pastMeds.isEmpty) return Colors.grey[800]!;
    
    final missedCount = pastMeds.where((s) => !s.isTaken).length;
    
    if (missedCount > 0) {
      return Colors.red[700]!;
    }
    
    final takenRatio = statuses.where((s) => s.isTaken).length / statuses.length;
    
    if (takenRatio == 1.0) {
      return Colors.green[700]!;
    } else if (takenRatio >= 0.5) {
      return Colors.blue[700]!;
    } else {
      return Colors.grey[800]!;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final statuses = _getMedicationStatuses();
    final progress = _calculateProgress();
    final liquidColor = _getProgressColor();
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[50]!,
                    Colors.white,
                  ],
                ),
              ),
            ),
            
            // Liquid animation
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: SmoothLiquidPainter(
                    animation: _waveAnimation.value,
                    fillPercentage: progress,
                    color: liquidColor,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Medication indicators
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: liquidColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${statuses.where((s) => s.isTaken).length}/${statuses.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: liquidColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Medication time indicators
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: statuses.map((status) {
                          return _buildMedicationIndicator(status);
                        }).toList(),
                      ),
                    ),
                    
                    // Time labels
                    if (statuses.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: statuses.map((status) {
                          return SizedBox(
                            width: 60,
                            child: Text(
                              status.timeString,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMedicationIndicator(MedicationStatus status) {
    IconData icon;
    Color color;
    Color bgColor;
    
    if (status.isTaken) {
      icon = Icons.check_circle;
      color = Colors.green[700]!;
      bgColor = Colors.green[50]!;
    } else if (status.isPast) {
      icon = Icons.error;
      color = Colors.red[600]!;
      bgColor = Colors.red[50]!;
    } else {
      icon = Icons.schedule;
      color = Colors.grey[400]!;
      bgColor = Colors.grey[50]!;
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            size: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: Text(
            status.medication.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: status.isTaken 
                  ? Colors.green[700]
                  : status.isPast 
                      ? Colors.red[600]
                      : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class SmoothLiquidPainter extends CustomPainter {
  final double animation;
  final double fillPercentage;
  final Color color;
  
  SmoothLiquidPainter({
    required this.animation,
    required this.fillPercentage,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final baseHeight = size.height * (1 - fillPercentage);
    
    // Create smooth continuous wave
    final path = Path();
    path.moveTo(0, size.height);
    
    const segments = 150;
    for (int i = 0; i <= segments; i++) {
      final x = (size.width / segments) * i;
      final normalizedX = i / segments;
      
      // Smooth continuous waves
      final primaryWave = math.sin((normalizedX * math.pi * 2) + (animation * math.pi * 4)) * 6;
      final secondaryWave = math.sin((normalizedX * math.pi * 3) - (animation * math.pi * 6)) * 3;
      final microWave = math.sin((normalizedX * math.pi * 8) + (animation * math.pi * 12)) * 1;
      
      final y = baseHeight + primaryWave + secondaryWave + microWave;
      
      if (i == 0) {
        path.lineTo(x, y);
      } else {
        final prevX = (size.width / segments) * (i - 1);
        final prevNormalizedX = (i - 1) / segments;
        
        final prevPrimaryWave = math.sin((prevNormalizedX * math.pi * 2) + (animation * math.pi * 4)) * 6;
        final prevSecondaryWave = math.sin((prevNormalizedX * math.pi * 3) - (animation * math.pi * 6)) * 3;
        final prevMicroWave = math.sin((prevNormalizedX * math.pi * 8) + (animation * math.pi * 12)) * 1;
        
        final prevY = baseHeight + prevPrimaryWave + prevSecondaryWave + prevMicroWave;
        
        final cpX = (prevX + x) / 2;
        final cpY = (prevY + y) / 2;
        
        path.quadraticBezierTo(prevX, prevY, cpX, cpY);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    // Draw gradient liquid
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.4),
        color.withOpacity(0.7),
      ],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, baseHeight - 20, size.width, size.height - baseHeight + 20),
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
    
    // Draw surface line
    final surfacePaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    final surfacePath = Path();
    for (int i = 0; i <= segments; i++) {
      final x = (size.width / segments) * i;
      final normalizedX = i / segments;
      
      final wave = math.sin((normalizedX * math.pi * 2) + (animation * math.pi * 4)) * 6 +
                   math.sin((normalizedX * math.pi * 3) - (animation * math.pi * 6)) * 3;
      
      final y = baseHeight + wave;
      
      if (i == 0) {
        surfacePath.moveTo(x, y);
      } else {
        surfacePath.lineTo(x, y);
      }
    }
    
    canvas.drawPath(surfacePath, surfacePaint);
  }
  
  @override
  bool shouldRepaint(SmoothLiquidPainter oldDelegate) {
    return animation != oldDelegate.animation ||
           fillPercentage != oldDelegate.fillPercentage ||
           color != oldDelegate.color;
  }
}

class MedicationStatus {
  final Medication medication;
  final bool isTaken;
  final bool isPast;
  final bool isUpcoming;
  final String timeString;
  
  MedicationStatus({
    required this.medication,
    required this.isTaken,
    required this.isPast,
    required this.isUpcoming,
    required this.timeString,
  });
}