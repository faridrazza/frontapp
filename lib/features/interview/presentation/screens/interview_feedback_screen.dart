import 'package:flutter/material.dart';
import '../../domain/models/interview_feedback.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class InterviewFeedbackScreen extends StatelessWidget {
  final InterviewFeedback feedback;

  const InterviewFeedbackScreen({Key? key, required this.feedback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          title: Text(
            'Interview Feedback',
            style: GoogleFonts.inter(
              color: Color(0xFFC8F235),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                child: Text(
                  'End',
                  style: GoogleFonts.inter(
                    color: Color(0xFFC8F235),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallScore(),
              SizedBox(height: 24),
              _buildSummaryCard(),
              SizedBox(height: 24),
              _buildStrengthsCard(),
              SizedBox(height: 24),
              _buildImprovementCard(),
              SizedBox(height: 24),
              _buildTechnicalAssessment(),
              SizedBox(height: 24),
              _buildCommunicationSkills(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallScore() {
    return Center(
      child: CircularPercentIndicator(
        radius: 80,
        lineWidth: 12,
        percent: feedback.overallScore / 100,
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(feedback.overallScore).round()}%',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC8F235),
              ),
            ),
            Text(
              'Score',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        progressColor: Color(0xFFC8F235),
        backgroundColor: Colors.grey[800]!,
        animation: true,
        animationDuration: 1500,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildCard(
      'Overall Summary',
      Icons.assessment_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            feedback.overallSummary,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsCard() {
    return _buildCard(
      'Key Strengths',
      Icons.star_outline,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: feedback.strengths.map((strength) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Color(0xFFC8F235), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    strength,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildImprovementCard() {
    return _buildCard(
      'Areas for Improvement',
      Icons.trending_up,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: feedback.areasForImprovement.map((area) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.arrow_right,
                    color: Colors.orange[300], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    area,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTechnicalAssessment() {
    return _buildCard(
      'Technical Knowledge',
      Icons.code,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                feedback.technicalKnowledge.isAdequate
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: feedback.technicalKnowledge.isAdequate
                    ? Color(0xFFC8F235)
                    : Colors.orange[300],
              ),
              SizedBox(width: 8),
              Text(
                feedback.technicalKnowledge.isAdequate
                    ? 'Adequate Technical Knowledge'
                    : 'Needs Technical Improvement',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (feedback.technicalKnowledge.missingConcepts.isNotEmpty) ...[
            Text(
              'Areas to Review:',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ...feedback.technicalKnowledge.missingConcepts.map((concept) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        color: Colors.orange[300], size: 8),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        concept,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCommunicationSkills() {
    return _buildCard(
      'Communication Skills',
      Icons.record_voice_over_outlined,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSkillScore('Clarity', feedback.communicationSkills.clarityScore),
              _buildSkillScore('Confidence', feedback.communicationSkills.confidenceScore),
            ],
          ),
          SizedBox(height: 16),
          if (feedback.communicationSkills.improvements.isNotEmpty) ...[
            Text(
              'Suggestions for Improvement:',
              style: GoogleFonts.inter(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ...feedback.communicationSkills.improvements.map((improvement) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Color(0xFFC8F235), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        improvement,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillScore(String label, double score) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40,
          lineWidth: 8,
          percent: score / 100,
          center: Text(
            '${score.round()}%',
            style: GoogleFonts.inter(
              color: Color(0xFFC8F235),
              fontWeight: FontWeight.bold,
            ),
          ),
          progressColor: Color(0xFFC8F235),
          backgroundColor: Colors.grey[800]!,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFC8F235), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFFC8F235)),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC8F235),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
