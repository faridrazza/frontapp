class FeedbackParser {
  static Map<String, dynamic> parseFeedbackString(String feedbackString) {
    try {
      final Map<String, dynamic> parsedFeedback = {
        'overallScore': 0.0,
        'overallSummary': '',
        'strengths': <String>[],
        'areasForImprovement': <String>[],
        'technicalKnowledge': {
          'isAdequate': false,
          'missingConcepts': <String>[],
          'learningResources': <String>[],
        },
        'communicationSkills': {
          'clarityScore': 0.0,
          'confidenceScore': 0.0,
          'improvements': <String>[],
        },
      };

      // Parse overall score
      final scoreRegex = RegExp(r'Overall Performance Score: (\d+)');
      final scoreMatch = scoreRegex.firstMatch(feedbackString);
      if (scoreMatch != null) {
        parsedFeedback['overallScore'] = double.parse(scoreMatch.group(1)!);
      }

      // Parse sections using regex
      final strengthsRegex = RegExp(r'Strengths Highlighted:\n((?:(?:[-\d\.\s]*)[^\n]+\n)+)');
      final improvementsRegex = RegExp(r'Areas for Improvement:\n((?:(?:[-\d\.\s]*)[^\n]+\n)+)');
      final technicalRegex = RegExp(r'Technical Knowledge Assessment:\n((?:(?:[-\d\.\s]*)[^\n]+\n)+)');
      final communicationRegex = RegExp(r'Communication Skills Evaluation:\n((?:(?:[-\d\.\s]*)[^\n]+\n)+)');

      // Extract lists
      List<String> extractItems(String text, RegExp regex) {
        final match = regex.firstMatch(text);
        if (match != null) {
          return match.group(1)!
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), '').trim())
              .toList();
        }
        return [];
      }

      parsedFeedback['strengths'] = extractItems(feedbackString, strengthsRegex);
      parsedFeedback['areasForImprovement'] = extractItems(feedbackString, improvementsRegex);
      
      // Parse technical assessment
      final technicalPoints = extractItems(feedbackString, technicalRegex);
      if (technicalPoints.isNotEmpty) {
        parsedFeedback['overallSummary'] = technicalPoints.first;
        parsedFeedback['technicalKnowledge'] = {
          'isAdequate': parsedFeedback['overallScore'] >= 70,
          'missingConcepts': technicalPoints.skip(1).toList(),
          'learningResources': <String>[],
        };
      }

      // Parse communication skills
      final communicationPoints = extractItems(feedbackString, communicationRegex);
      if (communicationPoints.isNotEmpty) {
        final score = parsedFeedback['overallScore'] as double;
        parsedFeedback['communicationSkills'] = {
          'clarityScore': score * 0.8,
          'confidenceScore': score * 0.8,
          'improvements': communicationPoints,
        };
      }

      return parsedFeedback;
    } catch (e) {
      throw Exception('Error parsing feedback: $e');
    }
  }
} 