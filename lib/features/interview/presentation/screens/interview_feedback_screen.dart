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
      'Detail Feedback',
      Icons.star_outline,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...feedback.strengths.map((strength) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '- ',
                    style: GoogleFonts.inter(
                      color: Color(0xFFC8F235),
                      fontSize: 16,
                    ),
                  ),
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
        ],
      ),
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
