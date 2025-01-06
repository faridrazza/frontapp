class InterviewMessage {
  final String content;
  final bool isAI;
  final String? audioBuffer;

  InterviewMessage({
    required this.content,
    required this.isAI,
    this.audioBuffer,
  });

  InterviewMessage copyWith({
    String? content,
    bool? isAI,
    String? audioBuffer,
  }) {
    return InterviewMessage(
      content: content ?? this.content,
      isAI: isAI ?? this.isAI,
      audioBuffer: audioBuffer ?? this.audioBuffer,
    );
  }
}
