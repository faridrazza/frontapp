class InterviewFeedback {
  final double overallScore;
  final String overallSummary;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final TechnicalAssessment technicalKnowledge;
  final CommunicationAssessment communicationSkills;

  InterviewFeedback({
    required this.overallScore,
    required this.overallSummary,
    required this.strengths,
    required this.areasForImprovement,
    required this.technicalKnowledge,
    required this.communicationSkills,
  });

  factory InterviewFeedback.fromJson(Map<String, dynamic> json) {
    return InterviewFeedback(
      overallScore: json['overallScore']?.toDouble() ?? 0.0,
      overallSummary: json['overallSummary'] ?? '',
      strengths: List<String>.from(json['strengths'] ?? []),
      areasForImprovement: List<String>.from(json['areasForImprovement'] ?? []),
      technicalKnowledge: TechnicalAssessment.fromJson(
          json['technicalKnowledge'] ?? {}),
      communicationSkills: CommunicationAssessment.fromJson(
          json['communicationSkills'] ?? {}),
    );
  }
}

class TechnicalAssessment {
  final bool isAdequate;
  final List<String> missingConcepts;
  final List<String> learningResources;

  TechnicalAssessment({
    required this.isAdequate,
    required this.missingConcepts,
    required this.learningResources,
  });

  factory TechnicalAssessment.fromJson(Map<String, dynamic> json) {
    return TechnicalAssessment(
      isAdequate: json['isAdequate'] ?? false,
      missingConcepts: List<String>.from(json['missingConcepts'] ?? []),
      learningResources: List<String>.from(json['learningResources'] ?? []),
    );
  }
}

class CommunicationAssessment {
  final double clarityScore;
  final double confidenceScore;
  final List<String> improvements;

  CommunicationAssessment({
    required this.clarityScore,
    required this.confidenceScore,
    required this.improvements,
  });

  factory CommunicationAssessment.fromJson(Map<String, dynamic> json) {
    return CommunicationAssessment(
      clarityScore: json['clarityScore']?.toDouble() ?? 0.0,
      confidenceScore: json['confidenceScore']?.toDouble() ?? 0.0,
      improvements: List<String>.from(json['improvements'] ?? []),
    );
  }
}
