import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class TestVideoScreen extends StatefulWidget {
  const TestVideoScreen({super.key});

  @override
  State<TestVideoScreen> createState() => _TestVideoScreenState();
}

class _TestVideoScreenState extends State<TestVideoScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _error;

  // ✅ TEST CÁC URL KHÁC NHAU
  final List<String> testUrls = [
    // URL mẫu từ internet (để test xem video_player có hoạt động không)
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',

    // URL backend của bạn - HTTPS
    'https://10.0.2.2:7185/videos/situations/th001.mp4',

    // URL backend của bạn - HTTP
    'http://10.0.2.2:5091/videos/situations/th001.mp4',

    // Localhost
    'http://localhost:5091/videos/situations/th001.mp4',
  ];

  int currentUrlIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final url = testUrls[currentUrlIndex];
    print('🎬 Testing URL: $url');

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _videoController,
              autoPlay: false,
              looping: false,
            );
            _isLoading = false;
          });
          print('✅ Video loaded successfully!');
        }
      }).catchError((error) {
        print('❌ Video error: $error');
        if (mounted) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _nextUrl() {
    _chewieController?.dispose();
    _videoController.dispose();
    setState(() {
      currentUrlIndex = (currentUrlIndex + 1) % testUrls.length;
      _chewieController = null;
    });
    _loadVideo();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Video Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _nextUrl,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị URL đang test
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'URL ${currentUrlIndex + 1}/${testUrls.length}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    testUrls[currentUrlIndex],
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Video player hoặc error
            Expanded(
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải video...'),
                  ],
                ),
              )
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'LỖI:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SelectableText(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadVideo,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
                  : _chewieController != null
                  ? AspectRatio(
                aspectRatio: 16 / 9,
                child: Chewie(controller: _chewieController!),
              )
                  : const Center(child: Text('Video không khả dụng')),
            ),

            const SizedBox(height: 16),

            // Nút test
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextUrl,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Test URL tiếp theo'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}