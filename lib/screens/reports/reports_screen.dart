import 'package:flutter/material.dart';

import '../../auth/app_user.dart';
import '../../auth/auth_repository.dart';
import '../../reports/condition_report.dart';
import '../../reports/report_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/message_banner.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/windgate_logo.dart';
import 'condition_report_screen.dart';
import 'report_details_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.authRepository,
    required this.reportRepository,
    required this.user,
  });

  final AuthRepository authRepository;
  final ReportRepository reportRepository;
  final AppUser user;

  static const logoutButtonKey = Key('reports_logout');
  static const newReportButtonKey = Key('reports_new_report');
  static const mineFilterKey = Key('reports_filter_mine');

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final Stream<List<ConditionReport>> _reports = widget.reportRepository
      .watchReports();

  bool _onlyMine = false;

  Future<void> _logOut() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    try {
      await widget.authRepository.signOut();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openNewReport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConditionReportScreen(
          user: widget.user,
          reportRepository: widget.reportRepository,
        ),
      ),
    );
  }

  void _openReport(ConditionReport report) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailsScreen(
          report: report,
          reportRepository: widget.reportRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const WindgateLogo(
          variant: WindgateLogoVariant.horizontal,
          height: 22,
        ),
        actions: [
          TextButton.icon(
            key: ReportsScreen.logoutButtonKey,
            onPressed: _logOut,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text('Log out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.user.greetingName}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Condition reports', style: textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: !_onlyMine,
                        onSelected: (_) => setState(() => _onlyMine = false),
                      ),
                      ChoiceChip(
                        key: ReportsScreen.mineFilterKey,
                        label: const Text('Mine'),
                        selected: _onlyMine,
                        onSelected: (_) => setState(() => _onlyMine = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ConditionReport>>(
                stream: _reports,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: MessageBanner(
                        message:
                            "Couldn't load reports. Check your internet "
                            'connection and try again.',
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var reports = snapshot.data!;
                  if (_onlyMine) {
                    reports = reports
                        .where((r) => r.createdByUid == widget.user.uid)
                        .toList();
                  }

                  if (reports.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          _onlyMine
                              ? "You haven't made any reports yet."
                              : 'No reports yet. Tap NEW REPORT to make '
                                    'the first one.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: reports.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) => _ReportTile(
                      report: reports[index],
                      onTap: () => _openReport(reports[index]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                key: ReportsScreen.newReportButtonKey,
                label: 'NEW REPORT',
                onPressed: _openNewReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report, required this.onTap});

  final ConditionReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final artist = report.artist.isEmpty ? 'Unknown artist' : report.artist;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(
        report.hasPhoto ? Icons.photo_outlined : Icons.description_outlined,
        color: AppColors.orange,
      ),
      title: Text(report.displayTitle),
      subtitle: Text(
        '$artist · ${report.condition}\n'
        'by ${report.createdByName} · ${report.dateLabel}',
        style: const TextStyle(color: AppColors.mutedText, height: 1.4),
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
    );
  }
}
