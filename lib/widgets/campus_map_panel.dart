import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../core/constants/dimensions.dart';
import '../data/models/enums.dart';
import '../data/models/incident.dart';
import '../data/models/responder.dart';

class CampusMapPanel extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final Incident? activeIncident;
  final Responder? activeResponder;
  final List<Incident>? allIncidents;
  final List<Responder>? allResponders;
  final List<LatLng>? routePolyline;
  final bool showFloatingEta;
  final ValueChanged<Incident>? onIncidentTap;
  final double height;
  final bool forceStylizedCanvas;

  const CampusMapPanel({
    super.key,
    this.center = const LatLng(37.7750, -122.4190),
    this.zoom = 16.2,
    this.activeIncident,
    this.activeResponder,
    this.allIncidents,
    this.allResponders,
    this.routePolyline,
    this.showFloatingEta = true,
    this.onIncidentTap,
    this.height = 280,
    this.forceStylizedCanvas = false,
  });

  @override
  State<CampusMapPanel> createState() => _CampusMapPanelState();
}

class _CampusMapPanelState extends State<CampusMapPanel> with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _pulseController;
  bool _useOsm = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        children: [
          // Base map layer: either FlutterMap with OSM or Custom Painted Campus Map
          if (_useOsm && !widget.forceStylizedCanvas)
            _buildOsmMap()
          else
            _buildCustomCampusCanvas(),

          // Glassmorphic Map Control buttons (Layer toggle, Center, Zoom)
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              children: [
                _buildGlassIconButton(
                  icon: _useOsm ? PhosphorIconsRegular.buildings : PhosphorIconsRegular.globe,
                  tooltip: _useOsm ? 'Switch to Campus Plan' : 'Switch to Satellite/OSM',
                  onTap: () {
                    setState(() => _useOsm = !_useOsm);
                  },
                ),
                const SizedBox(height: 6),
                _buildGlassIconButton(
                  icon: PhosphorIconsRegular.crosshair,
                  tooltip: 'Center on Incident',
                  onTap: () {
                    if (widget.activeIncident != null) {
                      _mapController.move(
                        LatLng(
                          widget.activeIncident!.latitude,
                          widget.activeIncident!.longitude,
                        ),
                        widget.zoom,
                      );
                    } else {
                      _mapController.move(widget.center, widget.zoom);
                    }
                  },
                ),
              ],
            ),
          ),

          // Floating Glassmorphic ETA Pill (blur 12px, 1px border)
          if (widget.showFloatingEta &&
              widget.activeIncident != null &&
              widget.activeIncident!.status == IncidentStatus.enRoute)
            Positioned(
              top: 14,
              left: 14,
              child: _buildGlassEtaPill(),
            ),

          // Campus mode banner indicator
          Positioned(
            bottom: 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
                border: Border.all(color: RgColors.border, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: RgColors.success,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _useOsm ? 'Central Campus Grid Â· OSM' : 'Stylized Offline Campus Plan',
                    style: RgTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: RgColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsmMap() {
    final markers = <Marker>[];

    // All incidents markers
    if (widget.allIncidents != null) {
      for (final inc in widget.allIncidents!) {
        final isSelected = widget.activeIncident?.id == inc.id;
        markers.add(
          Marker(
            point: LatLng(inc.latitude, inc.longitude),
            width: isSelected ? 48 : 36,
            height: isSelected ? 48 : 36,
            child: GestureDetector(
              onTap: () => widget.onIncidentTap?.call(inc),
              child: _buildIncidentMarkerWidget(inc, isSelected),
            ),
          ),
        );
      }
    } else if (widget.activeIncident != null) {
      // Single active incident
      markers.add(
        Marker(
          point: LatLng(
            widget.activeIncident!.latitude,
            widget.activeIncident!.longitude,
          ),
          width: 50,
          height: 50,
          child: _buildIncidentMarkerWidget(widget.activeIncident!, true),
        ),
      );
    }

    // Active Responder marker
    if (widget.activeResponder != null) {
      markers.add(
        Marker(
          point: LatLng(
            widget.activeResponder!.latitude,
            widget.activeResponder!.longitude,
          ),
          width: 44,
          height: 44,
          child: _buildResponderMarkerWidget(widget.activeResponder!),
        ),
      );
    }

    // All other responders
    if (widget.allResponders != null) {
      for (final r in widget.allResponders!) {
        if (r.id != widget.activeResponder?.id) {
          markers.add(
            Marker(
              point: LatLng(r.latitude, r.longitude),
              width: 34,
              height: 34,
              child: _buildResponderMarkerWidget(r, isSmall: true),
            ),
          );
        }
      }
    }

    // Polylines
    final polylines = <Polyline>[];
    if (widget.routePolyline != null && widget.routePolyline!.isNotEmpty) {
      polylines.add(
        Polyline(
          points: widget.routePolyline!,
          strokeWidth: 4.5,
          color: RgColors.primaryAccent,
          pattern: const StrokePattern.solid(),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.activeIncident != null
            ? LatLng(widget.activeIncident!.latitude, widget.activeIncident!.longitude)
            : widget.center,
        initialZoom: widget.zoom,
        minZoom: 13.0,
        maxZoom: 18.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.rescuegrid.rescue_grid',
        ),
        if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildCustomCampusCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _StylizedCampusPainter(
            activeIncident: widget.activeIncident,
            activeResponder: widget.activeResponder,
            pulseValue: _pulseController.value,
          ),
        );
      },
    );
  }

  Widget _buildIncidentMarkerWidget(Incident inc, bool isPulsing) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            if (isPulsing)
              Container(
                width: 44 + (_pulseController.value * 12),
                height: 44 + (_pulseController.value * 12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inc.severity.color.withOpacity(
                    (1.0 - _pulseController.value) * 0.45,
                  ),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inc.severity.color,
                border: Border.all(color: Colors.white, width: 2.2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                inc.category.icon,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponderMarkerWidget(Responder r, {bool isSmall = false}) {
    final size = isSmall ? 28.0 : 36.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: RgColors.primary,
        border: Border.all(color: Colors.white, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          r.type.icon,
          size: size * 0.48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withOpacity(0.85),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 20, color: RgColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassEtaPill() {
    final inc = widget.activeIncident!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
            border: Border.all(
              color: Colors.white.withOpacity(0.95),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: RgColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                inc.responderEtaMinutes <= 0
                    ? 'Unit On Scene'
                    : 'Arriving in ${inc.responderEtaMinutes} min (${(inc.responderDistanceMeters / 1000).toStringAsFixed(1)} km)',
                style: RgTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RgColors.primary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom offline stylized campus map painter
class _StylizedCampusPainter extends CustomPainter {
  final Incident? activeIncident;
  final Responder? activeResponder;
  final double pulseValue;

  _StylizedCampusPainter({
    this.activeIncident,
    this.activeResponder,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Campus Ground
    final groundPaint = Paint()..color = const Color(0xFFE8EEF5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), groundPaint);

    // 2. Green Lawn zones
    final greenPaint = Paint()..color = const Color(0xFFD8EADA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.45),
        const Radius.circular(16),
      ),
      greenPaint,
    );

    // 3. Campus Roads and Walkways
    final roadPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(size.width * 0.35, size.height * 0.4)
      ..lineTo(size.width * 0.65, size.height * 0.25)
      ..lineTo(size.width, size.height * 0.25);
    canvas.drawPath(roadPath, roadPaint);

    final roadPath2 = Path()
      ..moveTo(size.width * 0.45, 0)
      ..lineTo(size.width * 0.45, size.height);
    canvas.drawPath(roadPath2, roadPaint);

    // 4. Campus Buildings
    _drawBuilding(canvas, Rect.fromLTWH(size.width * 0.1, size.height * 0.15, 80, 50), 'Science Hall');
    _drawBuilding(canvas, Rect.fromLTWH(size.width * 0.6, size.height * 0.1, 95, 60), 'Central Library');
    _drawBuilding(canvas, Rect.fromLTWH(size.width * 0.12, size.height * 0.55, 75, 70), 'West Dorms');
    _drawBuilding(canvas, Rect.fromLTWH(size.width * 0.62, size.height * 0.52, 90, 65), 'Student Union');

    // 5. Active route polyline
    final routePaint = Paint()
      ..color = RgColors.primaryAccent
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(size.width * 0.32, size.height * 0.4)
      ..lineTo(size.width * 0.45, size.height * 0.4)
      ..lineTo(size.width * 0.65, size.height * 0.25);
    canvas.drawPath(routePath, routePaint);

    // 6. Active Incident Marker (Pulsing pin at Central Library)
    final incidentPoint = Offset(size.width * 0.65, size.height * 0.25);
    final pulsePaint = Paint()
      ..color = RgColors.secondary.withOpacity((1.0 - pulseValue) * 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(incidentPoint, 16 + (pulseValue * 12), pulsePaint);

    final pinPaint = Paint()..color = RgColors.secondary;
    canvas.drawCircle(incidentPoint, 12, pinPaint);
    final whiteInner = Paint()..color = Colors.white;
    canvas.drawCircle(incidentPoint, 5, whiteInner);

    // 7. Active Responder Marker
    final respPoint = Offset(size.width * 0.38, size.height * 0.4);
    final respPaint = Paint()..color = RgColors.primary;
    canvas.drawCircle(respPoint, 11, respPaint);
    final respInner = Paint()..color = RgColors.primaryAccent;
    canvas.drawCircle(respPoint, 5, respInner);
  }

  void _drawBuilding(Canvas canvas, Rect rect, String label) {
    final bldgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), bldgPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), borderPaint);

    final textSpan = TextSpan(
      text: label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width - 8);

    textPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top + (rect.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _StylizedCampusPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue;
  }
}
