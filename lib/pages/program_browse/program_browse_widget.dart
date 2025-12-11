import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/components/user_nav_bar.dart';
import 'program_browse_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProgramBrowseWidget extends StatefulWidget {
  const ProgramBrowseWidget({super.key});

  static String routeName = 'ProgramBrowse';
  static String routePath = 'programBrowse';

  @override
  State<ProgramBrowseWidget> createState() => _ProgramBrowseWidgetState();
}

class _ProgramBrowseWidgetState extends State<ProgramBrowseWidget> {
  late ProgramBrowseModel _model;
  late final TextEditingController _searchController;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramBrowseModel());
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  final List<String> _filters = const [
    'Trending',
    'Near you',
    'New',
    'Cafes',
    'Restaurants',
    'Services'
  ];
  String _activeFilter = '';

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF5F6FA),
        bottomNavigationBar: const UserNavBar(currentTab: UserNavTab.discover),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'Discover programs',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                _searchBar(context),
                const SizedBox(height: 10),
                _filterChips(context),
                const SizedBox(height: 14),
                StreamBuilder<List<ProgramsRecord>>(
                  stream: queryProgramsRecord(
                    queryBuilder: (programsRecord) => programsRecord
                        .where('status', isEqualTo: true)
                        .orderBy('created_at', descending: true),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final programs = snapshot.data!
                        .where((p) =>
                            !p.hasExpiryDate() ||
                            (p.expiryDate != null &&
                                p.expiryDate!.isAfter(DateTime.now())))
                        .toList();
                    final term = _searchController.text.trim().toLowerCase();
                    final filtered = programs.where((p) {
                      final inTerm = term.isEmpty ||
                          p.title.toLowerCase().contains(term) ||
                          (p.description).toLowerCase().contains(term);
                      final inFilter = _activeFilter.isEmpty ||
                          p.title
                              .toLowerCase()
                              .contains(_activeFilter.toLowerCase()) ||
                          (p.description)
                              .toLowerCase()
                              .contains(_activeFilter.toLowerCase());
                      return inTerm && inFilter;
                    }).toList();
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No programs available now.',
                            style: FlutterFlowTheme.of(context).bodyLarge,
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final program = filtered[index];
                        return _programCard(context, program);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search for loyalty programs...',
        prefixIcon: const Icon(Icons.search, size: 22),
        filled: true,
        fillColor: const Color(0xFFF4F4F6),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _filters
          .map(
            (f) => ChoiceChip(
              label: Text(
                f,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      color: _activeFilter == f
                          ? FlutterFlowTheme.of(context).primary
                          : FlutterFlowTheme.of(context).secondaryText,
                    ),
              ),
              selected: _activeFilter == f,
              onSelected: (v) {
                setState(() {
                  _activeFilter = v ? f : '';
                });
              },
              backgroundColor: const Color(0xFFF4F4F6),
              selectedColor:
                  FlutterFlowTheme.of(context).primary.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _activeFilter == f
                      ? FlutterFlowTheme.of(context).primary
                      : const Color(0xFFE3E5EB),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _programCard(BuildContext context, ProgramsRecord program) {
    Color _bg() {
      final raw = program.passBackgroundColor;
      if (raw.isEmpty) return const Color(0xFF4A90E2);
      try {
        final cleaned = raw.replaceAll('#', '');
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return const Color(0xFF4A90E2);
      }
    }

    Color _fg() {
      final raw = program.passForegroundColor;
      if (raw.isEmpty) return Colors.white;
      try {
        final cleaned = raw.replaceAll('#', '');
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return Colors.white;
      }
    }

    final bg = _bg();
    final fg = _fg();
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        context.pushNamed(
          ProgramDetailsWidget.routeName,
          queryParameters: {
            'programRef': serializeParam(
              program.reference,
              ParamType.DocumentReference,
            ),
          }.withoutNulls,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 12,
              color: Color(0x14000000),
              offset: Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: program.businessIcon.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            program.businessIcon,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(Icons.storefront, color: fg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  color: fg,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        program.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.inter(),
                              color: fg.withOpacity(0.85),
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stamps required',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.inter(),
                            color: fg.withOpacity(0.75),
                          ),
                    ),
                    Text(
                      '${program.stampsRequired}',
                      style:
                          FlutterFlowTheme.of(context).headlineSmall.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.w800,
                                ),
                                color: fg,
                              ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (program.rewardDetails.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      program.rewardDetails,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FFButtonWidget(
                onPressed: () {
                  context.pushNamed(
                    ProgramDetailsWidget.routeName,
                    queryParameters: {
                      'programRef': serializeParam(
                        program.reference,
                        ParamType.DocumentReference,
                      ),
                    }.withoutNulls,
                  );
                },
                text: 'View details',
                options: FFButtonOptions(
                  height: 40,
                  color: Colors.white,
                  textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.interTight(
                          fontWeight: FontWeight.w700,
                        ),
                        color: bg,
                      ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
