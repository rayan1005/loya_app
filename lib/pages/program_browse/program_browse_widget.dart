import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '/components/user_nav_bar.dart';
import 'program_browse_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

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
  Position? _currentPosition;
  bool _isGettingLocation = false;
  String? _locationError;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProgramBrowseModel());
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  final List<String> _filters = const [
    'All',
    'Trending',
    'Near you',
    'New',
    'Cafes',
    'Restaurants',
    'Desserts',
    'Services'
  ];
  String _activeFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _ensureLocation() async {
    if (_isGettingLocation) return;
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Location services are disabled.';
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isGettingLocation = false;
          _locationError = 'Location permission denied.';
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = pos;
        _isGettingLocation = false;
        _locationError = null;
      });
    } catch (_) {
      setState(() {
        _isGettingLocation = false;
        _locationError = 'Could not get location.';
      });
    }
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
                if (_activeFilter == 'Near you')
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Row(
                      children: [
                        if (_isGettingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        if (_isGettingLocation) const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _locationError ??
                                (_currentPosition != null
                                    ? 'Showing nearest programs (within 10km).'
                                    : 'Getting your location to show nearby programs...'),
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                ),
                          ),
                        ),
                        if (_locationError != null)
                          TextButton(
                            onPressed: _ensureLocation,
                            child: const Text('Enable'),
                          ),
                      ],
                    ),
                  ),
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
                    final now = DateTime.now();
                    final programs = snapshot.data!
                        .where((p) =>
                            !p.hasExpiryDate() ||
                            (p.expiryDate != null && p.expiryDate!.isAfter(now)))
                        .toList();

                    final term = _searchController.text.trim().toLowerCase();
                    final filtered = programs.where((p) {
                      final inTerm = term.isEmpty ||
                          p.title.toLowerCase().contains(term) ||
                          (p.description).toLowerCase().contains(term);

                      final filter = _activeFilter;
                      bool inFilter = true;
                      if (filter == 'Trending') {
                        inFilter = p.snapshotData['isTrending'] == true;
                      } else if (filter == 'Near you') {
                        final pos = _currentPosition;
                        if (pos == null) {
                          inFilter = _locationError != null ? false : true;
                        } else {
                          final lat = p.latitude;
                          final lng = p.longitude;
                          if (lat == 0 && lng == 0) {
                            inFilter = false;
                          } else {
                            final distance = Geolocator.distanceBetween(
                              pos.latitude,
                              pos.longitude,
                              lat,
                              lng,
                            );
                            inFilter = distance <= 10000; // 10km radius
                          }
                        }
                      } else if (filter == 'New') {
                        inFilter = p.createdAt != null &&
                            p.createdAt!.isAfter(now.subtract(const Duration(days: 30)));
                      } else if (filter == 'Cafes') {
                        inFilter =
                            p.title.toLowerCase().contains('cafe') ||
                                p.description.toLowerCase().contains('coffee');
                      } else if (filter == 'Restaurants') {
                        inFilter = p.title.toLowerCase().contains('restaurant') ||
                            p.description.toLowerCase().contains('restaurant');
                      } else if (filter == 'Desserts') {
                        inFilter = p.title.toLowerCase().contains('dessert') ||
                            p.description.toLowerCase().contains('sweet');
                      } else if (filter == 'Services') {
                        inFilter = p.title.toLowerCase().contains('service') ||
                            p.description.toLowerCase().contains('service');
                      } else {
                        inFilter = true;
                      }

                      return inTerm && inFilter;
                    }).toList();

                    if (_activeFilter == 'Near you' && _currentPosition != null) {
                      double distFor(ProgramsRecord p) {
                        final lat = p.latitude;
                        final lng = p.longitude;
                        if (lat == 0 && lng == 0) return double.maxFinite;
                        return Geolocator.distanceBetween(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                          lat,
                          lng,
                        );
                      }

                      filtered.sort((a, b) => distFor(a).compareTo(distFor(b)));
                    }
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
                        return _programCard(context, program, _currentPosition);
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
                  _activeFilter = v ? f : 'All';
                  if (_activeFilter == 'Near you') {
                    _ensureLocation();
                  }
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

  Widget _programCard(
      BuildContext context, ProgramsRecord program, Position? userPos) {
    Color bg0() {
      final raw = program.passBackgroundColor;
      if (raw.isEmpty) return const Color(0xFF4A90E2);
      try {
        final cleaned = raw.replaceAll('#', '');
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return const Color(0xFF4A90E2);
      }
    }

    Color fg0() {
      final raw = program.passForegroundColor;
      if (raw.isEmpty) return Colors.white;
      try {
        final cleaned = raw.replaceAll('#', '');
        return Color(int.parse('0xFF$cleaned'));
      } catch (_) {
        return Colors.white;
      }
    }

    final bg = bg0();
    final fg = fg0();
    final labelColor = fg.withOpacity(0.8);
    final iconUrl = program.passLogo.isNotEmpty
        ? program.passLogo
        : (program.businessIcon.isNotEmpty
            ? program.businessIcon
            : program.passIcon);
    final backgroundUrl =
        (program.snapshotData['program_background'] ?? '') as String? ?? '';
    double? distanceKm;
    if (userPos != null &&
        program.latitude != 0.0 &&
        program.longitude != 0.0) {
      distanceKm = Geolocator.distanceBetween(userPos.latitude,
              userPos.longitude, program.latitude, program.longitude) /
          1000;
    }

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
          image: backgroundUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(backgroundUrl),
                  fit: BoxFit.cover,
                  colorFilter:
                      ColorFilter.mode(bg.withOpacity(0.35), BlendMode.srcATop),
                )
              : null,
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
                  child: iconUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            iconUrl,
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
                            color: labelColor,
                          ),
                    ),
                    if (distanceKm != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place,
                              size: 14, color: labelColor.withOpacity(0.9)),
                          const SizedBox(width: 4),
                          Text(
                            '${distanceKm.toStringAsFixed(distanceKm < 10 ? 1 : 0)} km away',
                            style: FlutterFlowTheme.of(context)
                                .bodySmall
                                .override(
                                  font: GoogleFonts.inter(),
                                  color: labelColor,
                                ),
                          ),
                        ],
                      ),
                    ],
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
