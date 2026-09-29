import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildQuickAccessSection(context),
            _buildStatsSection(context),
            _buildChatbotSection(context),
            _buildFeaturesSection(context),
            _buildHowItWorksSection(context),
            _buildCallToActionSection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 600), // ~90vh approximation
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?q=80&w=1920&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF0a2540).withValues(alpha: 0.8),
            BlendMode.srcATop,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.centerLeft,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text('Next-Gen Campus Guide', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Navigate Your Academic Journey with AI',
                      style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.1),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Explore classrooms, track down professor offices, locate administrative sectors, and calculate the fastest campus routes instantly using intelligent datasets tailored just for your university.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 18, height: 1.5),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 400) {
                            return Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Icon(Icons.search, color: Colors.grey),
                                ),
                                const Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search classrooms, professors, buildings...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                  ),
                                  child: const Text('Find Location'),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Row(
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                                      child: Icon(Icons.search, color: Colors.grey),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText: 'Search...',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: const Text('Find Location'),
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                          ),
                          child: const Text('Start Exploring'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat),
                          label: const Text('Chat with AI'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (MediaQuery.of(context).size.width > 992)
                const Expanded(flex: 5, child: SizedBox()), // spacer for lg
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final items = [
      {'title': 'Campus Map', 'desc': 'Interactive 2D & 3D overview of all university property structures.', 'icon': Icons.map, 'action': 'View Map'},
      {'title': 'Professors Directory', 'desc': 'Locate office hours, locations, and contact details instantly.', 'icon': Icons.person, 'action': 'Find Professor'},
      {'title': 'Course Catalog', 'desc': 'Browse current schedules, descriptions, and structural requirements.', 'icon': Icons.book, 'action': 'View Catalog'},
      {'title': 'Lecture Halls', 'desc': 'Pinpoint specific modern operational classrooms and auditoriums.', 'icon': Icons.business, 'action': 'Locate Halls'},
      {'title': 'Laboratories', 'desc': 'Research labs, tech support hubs, and specialized equipment locations.', 'icon': Icons.science, 'action': 'Find Labs'},
      {'title': 'Library', 'desc': 'Quiet spaces, study room reservations, and operational hours.', 'icon': Icons.local_library, 'action': 'Check Status'},
      {'title': 'Student Affairs', 'desc': 'Extracurricular activities, club resources, and support personnel.', 'icon': Icons.people, 'action': 'Get Support'},
      {'title': 'Registration Office', 'desc': 'Process institutional entries, drop/add classes, and secure transcripts.', 'icon': Icons.assignment, 'action': 'Visit Office'},
      {'title': 'Financial Office', 'desc': 'Manage tuition fees, tracking scholarships, and processing payments.', 'icon': Icons.credit_card, 'action': 'Manage Fees'},
      {'title': 'Cafeteria', 'desc': 'Dining hall facilities, current menus, and daily schedules.', 'icon': Icons.restaurant, 'action': 'See Menus'},
      {'title': 'Parking', 'desc': 'Student, visitor, and faculty permitted zones across grounds.', 'icon': Icons.local_parking, 'action': 'Find Space'},
      {'title': 'Medical Clinic', 'desc': 'On-campus emergency care services, appointments, and mental wellness centers.', 'icon': Icons.medical_services, 'action': 'Get Help'},
    ];

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text(
              'Quick Campus Directories',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Direct access to essential university assets and operations. Select an area below to pinpoint its exact coordinates.',
              style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth >= 1200) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth >= 992) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth >= 768) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFf0f7ff),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(item['icon'] as IconData, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item['desc'] as String,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                item['action'] as String,
                                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
                            ],
                          )
                        ],
                      ),
                      ),
                    );
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatItem('150+', 'Expert Professors', constraints.maxWidth),
                  _buildStatItem('400+', 'Total Courses', constraints.maxWidth),
                  _buildStatItem('85+', 'Classrooms & Labs', constraints.maxWidth),
                  _buildStatItem('12K+', 'Students Supported', constraints.maxWidth),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, double maxWidth) {
    return SizedBox(
      width: maxWidth < 600 ? (maxWidth / 2) - 12 : (maxWidth / 4) - 24,
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildChatbotSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 992;
            final children = [
              Expanded(
                flex: isDesktop ? 1 : 0,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?q=80&w=600&auto=format&fit=crop',
                        height: 450,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 230,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                const Text('Assistant Online', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '"Dr. Ahmad\'s office is located in Building C, Floor 2, Room 204."',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) const SizedBox(width: 64),
              if (!isDesktop) const SizedBox(height: 48),
              Expanded(
                flex: isDesktop ? 1 : 0,
                child: Column(
                  crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    const Text('YOUR PERSONAL ASSISTANT', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    Text(
                      'The Intelligent Campus Chatbot At Your Service',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.darkBlue, height: 1.2),
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Powered by a distinct, specialized dataset, our contextual conversational AI doesn\'t approximate. It reads actual campus telemetry, providing real solutions immediately.',
                      style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.5),
                      textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildCheckItem('Natural language understanding (No rigid commands)'),
                    const SizedBox(height: 16),
                    _buildCheckItem('Direct integration with real-time class scheduling'),
                    const SizedBox(height: 16),
                    _buildCheckItem('Instant generation of point-to-point maps'),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Open Chatbot'),
                    ),
                  ],
                ),
              ),
            ];

            return isDesktop 
                ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: children)
                : Column(children: children);
          }
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: AppTheme.darkBlue, fontWeight: FontWeight.w500, fontSize: 16))),
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {'title': 'Smart AI Assistant', 'desc': 'Interact effortlessly using natural conversation workflows to find records, timelines, or precise campus layouts.', 'icon': Icons.chat},
      {'title': 'Interactive Campus Map', 'desc': 'A dynamically updated, visually accessible mapping interface designed for immediate localized indexing.', 'icon': Icons.location_on},
      {'title': 'Professor Information', 'desc': 'Instant structural mapping of office configurations, associated email profiles, and assigned schedules.', 'icon': Icons.person},
      {'title': 'Course Information', 'desc': 'Transparent directory outlining prerequisites, modular descriptors, and real-time schedule structures.', 'icon': Icons.collections},
      {'title': 'Building Navigation', 'desc': 'Automated structural calculations returning localized pathways to avoid traffic or campus obstacles.', 'icon': Icons.directions},
      {'title': 'Fast Search', 'desc': 'Global single-query index engineered to match and surface complex records with minimal structural delay.', 'icon': Icons.flash_on},
    ];

    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text(
              'Engineered for Academic Accessibility',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Every tool required to eliminate campus navigation friction, consolidated onto a modern web framework.',
              style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 1;
                if (constraints.maxWidth >= 992) {
                  crossAxisCount = 3;
                } else if (constraints.maxWidth >= 768) {
                  crossAxisCount = 2;
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: features.length,
                  itemBuilder: (context, index) {
                    final item = features[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item['icon'] as IconData, color: AppTheme.primary, size: 28),
                          const SizedBox(height: 16),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item['desc'] as String,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      ),
                    );
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text(
              'Getting Around Is Simple',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Follow three easy steps to optimize your transit across university grounds.',
              style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 768;
                return Wrap(
                  spacing: 24,
                  runSpacing: 40,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildStepItem('1', 'Search', 'Input any target destination, subject matter identifier, or instructor profile via the console entry field.', constraints.maxWidth, isDesktop),
                    _buildStepItem('2', 'Ask the AI', 'Receive optimized data responses instantly from the conversational model parsing the proprietary university mainframe.', constraints.maxWidth, isDesktop),
                    _buildStepItem('3', 'Reach Destination', 'Execute localized routes configured sequentially via the step-by-step vector path guide.', constraints.maxWidth, isDesktop),
                  ],
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String desc, double maxWidth, bool isDesktop) {
    return SizedBox(
      width: isDesktop ? (maxWidth / 3) - 24 : maxWidth,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkBlue)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: AppTheme.textMuted, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCallToActionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0a2540), AppTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: Column(
              children: [
                const Text(
                  'Ready to Transform Your Campus Experience?',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  'Gain immediate, continuous deployment access to location engines, operational analytics, and interactive assistance tools today.',
                  style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Get Started For Free'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
