class InterviewMessage {
  final String content;
  final bool isAI;
  final String? audioBuffer;
  final bool isPlaying;
  final bool isVideoPlaying;
  final Duration? duration;

  InterviewMessage({
    required this.content,
    required this.isAI,
    this.audioBuffer,
    this.isPlaying = false,
    this.isVideoPlaying = false,
    this.duration,
  });

  InterviewMessage copyWith({
    String? content,
    bool? isAI,
    String? audioBuffer,
    bool? isPlaying,
    bool? isVideoPlaying,
    Duration? duration,
  }) {
    return InterviewMessage(
      content: content ?? this.content,
      isAI: isAI ?? this.isAI,
      audioBuffer: audioBuffer ?? this.audioBuffer,
      isPlaying: isPlaying ?? this.isPlaying,
      isVideoPlaying: isVideoPlaying ?? this.isVideoPlaying,
      duration: duration ?? this.duration,
    );
  }
}
