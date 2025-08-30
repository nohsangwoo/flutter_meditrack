import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LiquidAnimation extends StatefulWidget {
  final double height;
  final Color liquidColor;
  final double fillPercentage;

  const LiquidAnimation({
    super.key,
    this.height = 200,
    this.liquidColor = Colors.black87,
    this.fillPercentage = 0.7,
  });

  @override
  State<LiquidAnimation> createState() => _LiquidAnimationState();
}

class _LiquidAnimationState extends State<LiquidAnimation>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _bubbleController;
  late Animation<double> _waveAnimation;
  
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _velocityX = 0.0;
  double _velocityY = 0.0;
  
  StreamSubscription? _gyroscopeSubscription;
  StreamSubscription? _accelerometerSubscription;
  
  final List<Bubble> _bubbles = [];
  final math.Random _random = math.Random();
  
  @override
  void initState() {
    super.initState();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.linear,
    ));
    
    _initSensors();
    _generateBubbles();
    
    _bubbleController.addListener(() {
      setState(() {
        _updateBubbles();
      });
    });
  }
  
  void _initSensors() {
    // Gyroscope for rotation velocity
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      setState(() {
        _velocityX = event.y * 0.3;
        _velocityY = event.x * 0.3;
      });
    });
    
    // Accelerometer for tilt
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        _tiltX = (event.x / 10).clamp(-1.0, 1.0);
        _tiltY = (event.y / 10).clamp(-1.0, 1.0);
      });
    });
  }
  
  void _generateBubbles() {
    for (int i = 0; i < 8; i++) {
      _bubbles.add(Bubble(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 6 + 2,
        speed: _random.nextDouble() * 0.5 + 0.5,
      ));
    }
  }
  
  void _updateBubbles() {
    for (var bubble in _bubbles) {
      bubble.y -= bubble.speed * 0.01;
      bubble.x += math.sin(bubble.y * math.pi * 2) * 0.002;
      
      // Add gyroscope influence
      bubble.x += _velocityX * 0.001;
      
      if (bubble.y < 0) {
        bubble.y = 1.0;
        bubble.x = _random.nextDouble();
      }
      
      // Keep bubbles within bounds
      bubble.x = bubble.x.clamp(0.0, 1.0);
    }
  }
  
  @override
  void dispose() {
    _waveController.dispose();
    _bubbleController.dispose();
    _gyroscopeSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 2),
        color: Colors.grey[50],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.grey[100]!.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            // Liquid with wave effect
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: LiquidPainter(
                    animation: _waveAnimation.value,
                    fillPercentage: widget.fillPercentage,
                    color: widget.liquidColor,
                    tiltX: _tiltX,
                    tiltY: _tiltY,
                    velocityX: _velocityX,
                    velocityY: _velocityY,
                    bubbles: _bubbles,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // Glass effect overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.transparent,
                    Colors.white.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double animation;
  final double fillPercentage;
  final Color color;
  final double tiltX;
  final double tiltY;
  final double velocityX;
  final double velocityY;
  final List<Bubble> bubbles;
  
  LiquidPainter({
    required this.animation,
    required this.fillPercentage,
    required this.color,
    required this.tiltX,
    required this.tiltY,
    required this.velocityX,
    required this.velocityY,
    required this.bubbles,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final baseHeight = size.height * (1 - fillPercentage);
    
    // Calculate tilt offset
    final tiltOffsetY = tiltY * 30;
    final tiltOffsetX = tiltX * 20;
    
    // Create wave points with physics
    final wavePoints = <Offset>[];
    const pointCount = 100;
    
    for (int i = 0; i <= pointCount; i++) {
      final x = (size.width / pointCount) * i;
      final normalizedX = i / pointCount;
      
      // Multiple wave layers for realistic effect
      final wave1 = math.sin((normalizedX * 2 * math.pi) + animation) * 8;
      final wave2 = math.sin((normalizedX * 3 * math.pi) - animation * 1.5) * 4;
      final wave3 = math.sin((normalizedX * 5 * math.pi) + animation * 2) * 2;
      
      // Add velocity influence
      final velocityWave = math.sin((normalizedX * math.pi) + velocityX * 2) * velocityX * 10;
      
      // Combine waves with tilt
      final y = baseHeight + 
                wave1 + 
                wave2 + 
                wave3 + 
                velocityWave +
                tiltOffsetY + 
                (tiltOffsetX * math.sin(normalizedX * math.pi));
      
      wavePoints.add(Offset(x, y));
    }
    
    // Build liquid path
    path.moveTo(0, size.height);
    path.lineTo(0, wavePoints.first.dy);
    
    for (int i = 0; i < wavePoints.length - 1; i++) {
      final p1 = wavePoints[i];
      final p2 = wavePoints[i + 1];
      final cp = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2,
      );
      path.quadraticBezierTo(p1.dx, p1.dy, cp.dx, cp.dy);
    }
    
    path.lineTo(size.width, wavePoints.last.dy);
    path.lineTo(size.width, size.height);
    path.close();
    
    // Draw liquid gradient
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.6),
        color.withOpacity(0.9),
      ],
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, gradientPaint);
    
    // Draw bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (var bubble in bubbles) {
      if (bubble.y > (1 - fillPercentage)) {
        final bubbleX = bubble.x * size.width;
        final bubbleY = bubble.y * size.height;
        
        // Only draw if below liquid surface
        final surfaceY = baseHeight + 
          math.sin((bubble.x * 2 * math.pi) + animation) * 8 +
          tiltOffsetY;
        
        if (bubbleY > surfaceY) {
          canvas.drawCircle(
            Offset(bubbleX, bubbleY),
            bubble.size,
            bubblePaint,
          );
          
          // Add bubble highlight
          final highlightPaint = Paint()
            ..color = Colors.white.withOpacity(0.5)
            ..style = PaintingStyle.fill;
          
          canvas.drawCircle(
            Offset(bubbleX - bubble.size * 0.3, bubbleY - bubble.size * 0.3),
            bubble.size * 0.3,
            highlightPaint,
          );
        }
      }
    }
    
    // Draw surface foam/highlights
    final foamPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final foamPath = Path();
    foamPath.moveTo(0, wavePoints.first.dy);
    
    for (int i = 0; i < wavePoints.length - 1; i++) {
      final p1 = wavePoints[i];
      final p2 = wavePoints[i + 1];
      final cp = Offset(
        (p1.dx + p2.dx) / 2,
        (p1.dy + p2.dy) / 2 - 2,
      );
      foamPath.quadraticBezierTo(p1.dx, p1.dy - 2, cp.dx, cp.dy);
    }
    
    canvas.drawPath(foamPath, foamPaint);
  }
  
  @override
  bool shouldRepaint(LiquidPainter oldDelegate) {
    return animation != oldDelegate.animation ||
           tiltX != oldDelegate.tiltX ||
           tiltY != oldDelegate.tiltY ||
           velocityX != oldDelegate.velocityX ||
           velocityY != oldDelegate.velocityY;
  }
}

class Bubble {
  double x;
  double y;
  final double size;
  final double speed;
  
  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}