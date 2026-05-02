import 'dart:async';
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../database.dart';

// --- GAME ENGINE ---
class EmojiJumpGame extends FlameGame with HasCollisionDetection {
  final String selectedEmoji;
  EmojiJumpGame({required this.selectedEmoji});

  late Player emoji;
  int score = 0;
  late TextComponent scoreText;

  @override
  Future<void> onLoad() async {
    // Background Hijau Lembut sesuai konsep TikTok
    add(RectangleComponent(size: size, paint: Paint()..color = const Color.fromARGB(255, 255, 244, 255)));

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold)),
    );
    add(scoreText);

    emoji = Player(selectedEmoji);
    add(emoji);

    // Lantai dasar awal agar tidak langsung jatuh
    add(Platform(position: Vector2(0, size.y - 40), isGround: true)..size = Vector2(size.x, 40));

    double currentY = size.y - 200;
    for (int i = 0; i < 6; i++) {
      _spawnPlatform(currentY);
      currentY -= 180;
    }
  }

  void _spawnPlatform(double y) {
    add(Platform(position: Vector2(Random().nextDouble() * (size.x - 80), y)));
  }

  @override
    void update(double dt) {
      super.update(dt);

      // Logika Kamera (Layar Bergeser) - Tetap ada, tapi tanpa tambah skor
      if (emoji.y < size.y / 2) {
        double diff = (size.y / 2) - emoji.y;
        emoji.y = size.y / 2;
        // score += diff.toInt(); <-- BARIS INI DIHAPUS

        children.query<Platform>().forEach((p) {
          p.y += diff;
          if (p.y > size.y) {
            p.removeFromParent();
            _spawnPlatform(-20);
          }
        });
      }

      // LOGIKA SKOR BARU: Cek setiap platform
      children.query<Platform>().forEach((p) {
        // Jika emoji sudah naik melewati platform dan platform belum ditandai 'isPassed'
        if (!p.isPassed && emoji.y < p.y && !p.isGround) {
          p.isPassed = true; // Tandai agar tidak dihitung lagi
          score += 3; // Tambah 3 poin per pijakan
          scoreText.text = 'Score: $score'; // Update teks skor
        }
      });

      // Logika Game Over
      if (emoji.y > size.y + 100) {
        _showGameOver();
      }
    }

    void _showGameOver() async {
      // 1. Tambahkan overlay dulu
      overlays.add('GameOver');
      
      await Future.delayed(const Duration(milliseconds: 50));      
      pauseEngine();
      // 3. Simpan skor ke database[cite: 1]
      int currentHighScore = await DatabaseHelper.instance.getGlobalHighScore(); 
      if (score > currentHighScore) {
        await DatabaseHelper.instance.insertScore(score, selectedEmoji);
      }
    }
}

// --- PLAYER DENGAN SENSOR GERAK ---
class Player extends PositionComponent with HasGameRef<EmojiJumpGame>, CollisionCallbacks {
  final String char;
  double velocityY = 0;
  double gravity = 15.0;
  double jumpStrength = -650.0;
  StreamSubscription? _sub;

  Player(this.char) : super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    add(TextComponent(text: char, textRenderer: TextPaint(style: const TextStyle(fontSize: 45))));
    
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 150);
    
    _sub = accelerometerEvents.listen((e) {
      // Logika gerak kanan-kiri via HP[cite: 2]
      position.x -= e.x * 6;
      if (position.x < 0) position.x = gameRef.size.x;
      if (position.x > gameRef.size.x) position.x = 0;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocityY += gravity;
    y += velocityY * dt;
  }

  void jump() { if (velocityY > 0) velocityY = jumpStrength; }

  @override
  void onRemove() { _sub?.cancel(); super.onRemove(); }
}

// --- PLATFORM (BUAYA) ---
class Platform extends PositionComponent with CollisionCallbacks {
  final bool isGround;
  bool isPassed = false; // Flag baru untuk menandai pijakan yang sudah dilewati
    
    Platform({required Vector2 position, this.isGround = false}) 
        : super(position: position, size: Vector2(80, 15));
        
  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size, 
      paint: Paint()..color = isGround ? Colors.brown : Colors.purple[800]!
    ));
    add(RectangleHitbox());
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    
    if (other is Player) {

      double emojiFeet = other.y + (other.size.y / 2);
      double platformTop = y;
      double platformBottom = y + size.y;

      if (other.velocityY > 0 && emojiFeet >= platformTop && emojiFeet <= platformBottom) {
        other.y = platformTop - (other.size.y / 2);
        other.jump();
      }
    }
  }
}

// --- WIDGET SCREEN (FIXED NULL-SAFETY) ---
class EmojiGameScreen extends StatefulWidget {
  @override
  _EmojiGameScreenState createState() => _EmojiGameScreenState();
}

class _EmojiGameScreenState extends State<EmojiGameScreen> {
  String? selectedEmoji;
  EmojiJumpGame? game;

  void _onStartGame() {
    if (selectedEmoji != null) {
      setState(() {
        game = EmojiJumpGame(selectedEmoji: selectedEmoji!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedEmoji == null || game == null) {
      return _buildSelectionMenu();
    }

    final activeGame = game!; 
    return Scaffold(
      body: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) game?.pauseEngine();
        },
        child: GameWidget(
          game: activeGame,
          overlayBuilderMap: {
            'GameOver': (context, EmojiJumpGame g) => _buildGameOverOverlay(g),
          },
        ),
      ),
    );
  }

  Widget _buildSelectionMenu() {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 244, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Emoji Jump", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const Text("Choose your emoji and start jumping!",
              style: TextStyle(fontSize: 14,
              color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['😃', '😐', '😭', '😡'].map((e) => _emojiButton(e)).toList(),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
              ),
              onPressed: selectedEmoji == null ? null : _onStartGame,
              child: const Text("START GAME"),
            )
          ],
        ),
      ),
    );
  }

  Widget _emojiButton(String e) {
    return GestureDetector(
      onTap: () => setState(() => selectedEmoji = e),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selectedEmoji == e ? Colors.purple[200] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: selectedEmoji == e ? Colors.purple : Colors.transparent, width: 2),
        ),
        child: Text(e, style: const TextStyle(fontSize: 40)),
      ),
    );
  }

  Widget _buildGameOverOverlay(EmojiJumpGame g) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("GAME OVER!", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.red)),
              const Divider(height: 40),
              Text("YOUR SCORE: ${g.score}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const Text(
                "Game over, but not your journey! Bounce back and beat your score!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                ),
                onPressed: () => setState(() {
                  selectedEmoji = null;
                  game = null;
                }),
                child: const Text("Play Again!"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}