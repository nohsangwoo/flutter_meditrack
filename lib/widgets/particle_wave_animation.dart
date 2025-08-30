import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class ParticleWaveAnimation extends StatefulWidget {
  final double width;
  final double height;
  final Color particleColor;
  
  const ParticleWaveAnimation({
    super.key,
    this.width = double.infinity,
    this.height = 150,
    this.particleColor = Colors.black,
  });

  @override
  State<ParticleWaveAnimation> createState() => _ParticleWaveAnimationState();
}

class _ParticleWaveAnimationState extends State<ParticleWaveAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  final List<Particle> particles = [];
  final math.Random random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
    
    _generateParticles();
    
    _particleController.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
  }
  
  void _generateParticles() {
    for (int i = 0; i < 50; i++) {
      particles.add(Particle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * widget.height,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 2,
          (random.nextDouble() - 0.5) * 2,
        ),
        radius: random.nextDouble() * 3 + 1,
        life: 1.0,
        color: widget.particleColor.withOpacity(random.nextDouble() * 0.5 + 0.2),
      ));
    }
  }
  
  void _updateParticles() {
    for (int i = particles.length - 1; i >= 0; i--) {
      final particle = particles[i];
      particle.position += particle.velocity;
      particle.life -= 0.01;
      
      // Add wave motion
      particle.position = Offset(
        particle.position.dx + math.sin(_controller.value * math.pi * 2) * 0.5,
        particle.position.dy + math.cos(_controller.value * math.pi * 2) * 0.3,
      );
      
      // Respawn particle if dead or out of bounds
      if (particle.life <= 0 || 
          particle.position.dx < -10 || 
          particle.position.dx > 410 ||
          particle.position.dy < -10 || 
          particle.position.dy > widget.height + 10) {
        particles[i] = Particle(
          position: Offset(
            random.nextDouble() * 400,
            random.nextDouble() * widget.height,
          ),
          velocity: Offset(
            (random.nextDouble() - 0.5) * 2,
            (random.nextDouble() - 0.5) * 2,
          ),
          radius: random.nextDouble() * 3 + 1,
          life: 1.0,
          color: widget.particleColor.withOpacity(random.nextDouble() * 0.5 + 0.2),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticleWavePainter(
              particles: particles,
              animation: _controller.value,
            ),
            size: Size(widget.width, widget.height),
          );
        },
      ),
    );
  }
}

class ParticleWavePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  
  ParticleWavePainter({
    required this.particles,
    required this.animation,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw connecting lines between nearby particles
    final linePaint = Paint()
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;
        if (distance < 50) {
          final opacity = (1 - distance / 50) * 0.2;
          linePaint.color = Colors.black.withOpacity(opacity);
          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            linePaint,
          );
        }
      }
    }
    
    // Draw particles with glow effect
    for (var particle in particles) {
      // Outer glow
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      canvas.drawCircle(
        particle.position,
        particle.radius * 2,
        glowPaint,
      );
      
      // Inner particle
      final particlePaint = Paint()
        ..color = particle.color.withOpacity(particle.life * 0.8);
      
      canvas.drawCircle(
        particle.position,
        particle.radius,
        particlePaint,
      );
      
      // Highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(particle.life * 0.3);
      
      canvas.drawCircle(
        Offset(
          particle.position.dx - particle.radius * 0.3,
          particle.position.dy - particle.radius * 0.3,
        ),
        particle.radius * 0.3,
        highlightPaint,
      );
    }
    
    // Draw wave overlay
    final wavePath = Path();
    final waveCount = 3;
    
    for (int w = 0; w < waveCount; w++) {
      wavePath.reset();
      wavePath.moveTo(0, size.height / 2);
      
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height / 2 + 
                  math.sin((x / size.width * math.pi * 2) + 
                  animation * math.pi * 2 + 
                  w * math.pi / waveCount) * 20;
        wavePath.lineTo(x, y);
      }
      
      final wavePaint = Paint()
        ..color = Colors.black.withOpacity(0.05 - w * 0.01)
        ..strokeWidth = 2 - w * 0.5
        ..style = PaintingStyle.stroke;
      
      canvas.drawPath(wavePath, wavePaint);
    }
  }
  
  @override
  bool shouldRepaint(ParticleWavePainter oldDelegate) => true;
}

class Particle {
  Offset position;
  Offset velocity;
  double radius;
  double life;
  Color color;
  
  Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.life,
    required this.color,
  });
}