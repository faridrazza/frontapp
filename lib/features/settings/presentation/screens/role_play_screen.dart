import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RolePlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                
                padding: const EdgeInsets.all(18.0), 
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Role play ideas',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC8F235),
                        
                      ),
                    ),
                  ],
                ),
              ),
              _buildRolePlayScenarios(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRolePlayScenarios() {
    final scenarios = [
      {
        'title': 'Customer Service Representative and an Angry Customer',
        'description': 'Situation: A customer is frustrated because they received a defective product. The representative has to calm the customer down and offer a satisfactory solution.',
      },
      {
        'title': 'Manager and Employee Discussing Performance Issues',
        'description': 'Situation: The manager has noticed that the employee is consistently missing deadlines. They need to have a constructive conversation about the issues and how they can be resolved.',
      },
      {
        'title': 'Job Interview: Interviewer and Candidate',
        'description': 'Situation: A job candidate is being interviewed for a position they really want. The interviewer needs to assess their skills and cultural fit.',
      },
      {
        'title': 'Doctor and Patient Discussing a Diagnosis',
        'description': 'Situation: A doctor needs to explain a serious diagnosis to a patient and discuss treatment options.',
      },
      {
        'title': 'Teacher and Parent Discussing a Student\'s Behavior',
        'description': 'Situation: A teacher needs to discuss a student\'s disruptive behavior with their parent and come up with a plan to improve it.',
      },
      {
        'title': 'Salesperson and Potential Client',
        'description': 'Situation: A salesperson is trying to convince a potential client to purchase their product or service.',
      },
      {
        'title': 'Roommates Discussing Household Chores',
        'description': 'Situation: Two roommates need to address issues with unequal distribution of household chores and create a fair system.',
      },
      {
        'title': 'Police Officer and Witness',
        'description': 'Situation: A police officer is interviewing a witness to gather information about a crime they observed.',
      },
      {
        'title': 'Waiter and Customer with Dietary Restrictions',
        'description': 'Situation: A customer with severe allergies is trying to order a meal, and the waiter needs to ensure their safety.',
      },
      {
        'title': 'Team Leader and Team Member in a Conflict',
        'description': 'Situation: A team leader needs to mediate a conflict between two team members that is affecting the group\'s productivity.',
      },
      {
        'title': 'Therapist and Client in a Counseling Session',
        'description': 'Situation: A therapist is helping a client work through a personal issue or trauma.',
      },
      {
        'title': 'Customer and Tech Support Representative',
        'description': 'Situation: A customer is having trouble with a technical product and needs assistance from a support representative.',
      },
      {
        'title': 'Real Estate Agent and Home Buyer',
        'description': 'Situation: A real estate agent is showing properties to a potential buyer with specific needs and budget constraints.',
      },
      {
        'title': 'Coach and Athlete Discussing Performance',
        'description': 'Situation: A coach needs to provide constructive feedback to an athlete who has been underperforming.',
      },
      {
        'title': 'HR Representative and Employee Discussing a Complaint',
        'description': 'Situation: An employee has filed a complaint about workplace harassment, and the HR representative needs to address the issue.',
      },
      {
        'title': 'Travel Agent and Client Planning a Vacation',
        'description': 'Situation: A client with specific preferences and budget constraints is working with a travel agent to plan their dream vacation.',
      },
      {
        'title': 'Lawyer and Client Preparing for a Court Case',
        'description': 'Situation: A lawyer is preparing their client for an upcoming court appearance and discussing the case strategy.',
      },
      {
        'title': 'Financial Advisor and Client Planning for Retirement',
        'description': 'Situation: A financial advisor is helping a client create a long-term plan for their retirement savings and investments.',
      },
      {
        'title': 'Wedding Planner and Couple Discussing Wedding Details',
        'description': 'Situation: A couple is working with a wedding planner to organize their upcoming wedding, balancing their vision with budget constraints.',
      },
      {
        'title': 'Mentor and Mentee Discussing Career Growth',
        'description': 'Situation: A mentor is providing guidance to their mentee about potential career paths and professional development opportunities.',
      },
      {
        'title': 'Project Manager and Team Member Discussing Project Delays',
        'description': 'Situation: A project manager needs to address delays in a critical project with a team member responsible for a key component.',
      },
    ];

    return Column(
      children: scenarios.map((scenario) {
        return Container(
          margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFFC8F235), width: 0.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scenario['title']!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC8F235),
                ),
              ),
              SizedBox(height: 8),
              Text(
                scenario['description']!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}