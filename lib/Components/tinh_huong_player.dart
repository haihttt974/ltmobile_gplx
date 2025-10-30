import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

typedef OnClickAt = void Function(double seconds);

class TinhHuongPlayer extends StatefulWidget {
  final String url;
  final OnClickAt onClickAt;
  final Widget? bottom;

  const TinhHuongPlayer({
    super.key,
    required this.url,
    required this.onClickAt,
    this.bottom
  });

  @override
  State<TinhHuongPlayer> createState() => _TinhHuongPlayerState();
}

class _TinhHuongPlayerState extends State<TinhHuongPlayer> {
  late VideoPlayerController _v;
  ChewieController? _c;
  bool hasError = false;
  String? errorMessage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // print('🎬 Video URL: ${widget.url}');
    _initializeVideo();
  }

  void _initializeVideo() {
    setState(() {
      hasError = false;
      errorMessage = null;
      isLoading = true;
    });

    // Kiểm tra URL trước
    if (widget.url.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = "URL video rỗng";
        isLoading = false;
      });
      return;
    }

    // print("Initializing video: ${widget.url}"); // Debug log

    try {
      final uri = Uri.parse(widget.url);
      _v = VideoPlayerController.networkUrl(uri);

      _v.initialize().then((_) {
        if (mounted) {
          setState(() {
            _c = ChewieController(
              videoPlayerController: _v,
              autoPlay: false,
              looping: false,
              // Thêm cấu hình xử lý lỗi
              showControls: true,
              allowFullScreen: true,
              allowMuting: true,
              errorBuilder: (context, errorMessage) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lỗi phát video',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            isLoading = false;
          });
        }
      }).catchError((error) {
        print("Video initialization error: $error"); // Debug log
        if (mounted) {
          setState(() {
            hasError = true;
            errorMessage = "Không thể tải video: ${_getErrorMessage(error)}";
            isLoading = false;
          });
        }
      });
    } catch (e) {
      print("URL parsing error: $e"); // Debug log
      setState(() {
        hasError = true;
        errorMessage = "URL không hợp lệ: $e";
        isLoading = false;
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('Source error')) {
      return 'Lỗi nguồn video - kiểm tra đường dẫn';
    } else if (errorStr.contains('Network')) {
      return 'Lỗi mạng - kiểm tra kết nối internet';
    } else if (errorStr.contains('Format')) {
      return 'Định dạng video không được hỗ trợ';
    }
    return 'Lỗi không xác định';
  }

  void _retryVideo() {
    _c?.dispose();
    _v.dispose();
    setState(() {
      _c = null;
    });
    _initializeVideo();
  }

  @override
  void didUpdateWidget(TinhHuongPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _c?.dispose();
      _v.dispose();
      setState(() {
        _c = null;
      });
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _c?.dispose();
    _v.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final videoHeight = (constraints.maxWidth / 16) * 9; // 16:9 aspect ratio
        final buttonHeight = 56.0; // Estimated button height
        final spacingHeight = 16.0; // SizedBox heights
        final bottomHeight = widget.bottom != null ? 40.0 : 0.0; // Estimated bottom widget height

        final totalContentHeight = videoHeight + buttonHeight + spacingHeight + bottomHeight;
        final needsScrolling = totalContentHeight > availableHeight;

        if (hasError) {
          return Container(
            height: needsScrolling ? availableHeight : videoHeight,
            color: Colors.grey[200],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage ?? 'Lỗi không xác định',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryVideo,
                      child: const Text('Thử lại'),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        'URL: ${widget.url}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (isLoading) {
          return SizedBox(
            height: videoHeight,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải video...'),
                ],
              ),
            ),
          );
        }

        // Sử dụng SingleChildScrollView nếu cần scroll
        if (needsScrolling) {
          return SizedBox(
            height: availableHeight,
            child: SingleChildScrollView(
              child: _buildVideoContent(),
            ),
          );
        }

        return _buildVideoContent();
      },
    );
  }

  Widget _buildVideoContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16/9,
          child: _c != null
              ? Chewie(controller: _c!)
              : Container(
            color: Colors.black,
            child: const Center(
              child: Text(
                'Video không khả dụng',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _c != null ? () {
              final sec = _v.value.position.inMilliseconds / 1000.0;
              widget.onClickAt(sec);
            } : null,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                'SPACE',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
          ),
        ),
        if (widget.bottom != null) ...[
          const SizedBox(height: 8),
          widget.bottom!,
        ],
      ],
    );
  }
}
