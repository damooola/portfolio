import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/sfx.dart';
import '../theme/app_theme.dart';

/// Event marketplace map, rebuilt from scratch on mock data.
///
/// Tap a vendor pin: the route draws from the client to the vendor, then a
/// car drives it back while distance and ETA count down. Tiles are Esri's
/// keyless dark-gray basemap, tinted navy, so no API key ships to the web.
class RouteMapDemo extends StatefulWidget {
  const RouteMapDemo({super.key});

  @override
  State<RouteMapDemo> createState() => _RouteMapDemoState();
}

class _Vendor {
  final String name;
  final String category;
  final IconData icon;

  /// Road-ish route from the vendor to the client, hand-placed.
  final List<LatLng> route;

  const _Vendor(this.name, this.category, this.icon, this.route);

  LatLng get location => route.first;
}

const _client = LatLng(6.4474, 3.4720); // Lekki Phase 1
const _cityKmh = 22.0; // Lagos traffic, being generous

/// Turns the gray basemap navy: roads stay light, land goes deep blue.
const _navyTint = ColorFilter.matrix([
  0.55, 0, 0, 0, 0, //
  0, 0.65, 0, 0, 2, //
  0, 0, 1.05, 0, 18, //
  0, 0, 0, 1, 0, //
]);

const _vendors = [
  _Vendor('Bloom & Co.', 'Décor', Icons.local_florist_outlined, [
    LatLng(6.4335, 3.4430),
    LatLng(6.4370, 3.4500),
    LatLng(6.4410, 3.4580),
    LatLng(6.4440, 3.4650),
    _client,
  ]),
  _Vendor('Smoke & Spice', 'Catering', Icons.restaurant_outlined, [
    LatLng(6.4420, 3.4930),
    LatLng(6.4395, 3.4860),
    LatLng(6.4400, 3.4790),
    LatLng(6.4440, 3.4745),
    _client,
  ]),
  _Vendor('Frame Lagos', 'Photography', Icons.photo_camera_outlined, [
    LatLng(6.4560, 3.4500),
    LatLng(6.4520, 3.4540),
    LatLng(6.4490, 3.4600),
    LatLng(6.4480, 3.4660),
    _client,
  ]),
];

class _RouteMapDemoState extends State<RouteMapDemo>
    with TickerProviderStateMixin {
  static const _distance = Distance();

  final _map = MapController();
  late final _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late final _drive = AnimationController(vsync: this);
  _Vendor? _vendor;
  List<double> _cumulative = const [0];

  @override
  void initState() {
    super.initState();
    _draw.addStatusListener((s) {
      if (s == AnimationStatus.completed) _drive.forward(from: 0);
    });
    _drive.addStatusListener((s) {
      if (s == AnimationStatus.completed) Sfx.play(Sound.ding);
    });
  }

  @override
  void dispose() {
    _draw.dispose();
    _drive.dispose();
    _map.dispose();
    super.dispose();
  }

  double get _totalKm => _cumulative.last / 1000;

  void _select(_Vendor v) {
    Sfx.play(Sound.click);
    final route = v.route;
    final cumulative = <double>[0];
    for (var i = 1; i < route.length; i++) {
      cumulative.add(cumulative.last + _distance(route[i - 1], route[i]));
    }
    setState(() {
      _vendor = v;
      _cumulative = cumulative;
    });
    _drive
      ..stop()
      ..value = 0
      // Real drive time scaled down: about a second per kilometre.
      ..duration = Duration(
        milliseconds: (cumulative.last * 1.1).round().clamp(3000, 9000),
      );
    _draw.forward(from: 0);
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(route),
        padding: const EdgeInsets.fromLTRB(40, 90, 40, 190),
      ),
    );
  }

  /// Point a fraction [t] of the way along the route, measured by distance.
  LatLng _along(List<LatLng> route, double t) {
    final target = _cumulative.last * t;
    for (var i = 1; i < route.length; i++) {
      if (_cumulative[i] >= target) {
        final seg = _cumulative[i] - _cumulative[i - 1];
        final f = seg == 0 ? 0.0 : (target - _cumulative[i - 1]) / seg;
        final a = route[i - 1], b = route[i];
        return LatLng(
          a.latitude + (b.latitude - a.latitude) * f,
          a.longitude + (b.longitude - a.longitude) * f,
        );
      }
    }
    return route.last;
  }

  /// The route from the vertex nearest [from] up to [to] (fractions).
  List<LatLng> _slice(List<LatLng> route, double from, double to) {
    final start = _along(route, from);
    final end = _along(route, to);
    final points = [start];
    for (var i = 1; i < route.length - 1; i++) {
      final d = _cumulative[i] / _cumulative.last;
      if (d > from && d < to) points.add(route[i]);
    }
    return points..add(end);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_draw, _drive]),
          builder: (context, _) {
            final v = _vendor;
            return FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints([
                    _client,
                    for (final v in _vendors) v.location,
                  ]),
                  padding: const EdgeInsets.fromLTRB(30, 100, 30, 60),
                ),
                backgroundColor: AppColors.night,
                interactionOptions: const InteractionOptions(
                  flags:
                      InteractiveFlag.drag |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://services.arcgisonline.com/arcgis/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                  maxNativeZoom: 16,
                  userAgentPackageName: 'dev.damolanelson.portfolio',
                  tileBuilder: (context, tile, _) =>
                      ColorFiltered(colorFilter: _navyTint, child: tile),
                ),
                if (v != null)
                  PolylineLayer(
                    polylines: [
                      // Drawn client → vendor, then eaten up as the car drives.
                      Polyline(
                        points: _slice(
                          v.route,
                          1 - _draw.value,
                          1,
                        ).reversed.toList(),
                        strokeWidth: 9,
                        color: AppColors.blue.withValues(alpha: 0.25),
                      ),
                      Polyline(
                        points: _drive.value > 0
                            ? _slice(v.route, _drive.value, 1)
                            : _slice(v.route, 1 - _draw.value, 1),
                        strokeWidth: 4,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _client,
                      width: 34,
                      height: 34,
                      child: const _ClientPin(),
                    ),
                    for (final vendor in _vendors)
                      Marker(
                        point: vendor.location,
                        width: 40,
                        height: 40,
                        child: _VendorPin(
                          vendor: vendor,
                          selected: vendor == v,
                          onTap: () => _select(vendor),
                        ),
                      ),
                    if (v != null && _draw.isCompleted)
                      Marker(
                        point: _along(v.route, _drive.value),
                        width: 30,
                        height: 30,
                        child: const _Car(),
                      ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      '© Esri · OpenStreetMap contributors',
                      style: AppText.mono.copyWith(
                        fontSize: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          top: 10,
          left: 12,
          right: 12,
          child: _TopCard(hasVendor: _vendor != null),
        ),
        if (_vendor != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 34,
            child: AnimatedBuilder(
              animation: _drive,
              builder: (context, _) => _TripCard(
                vendor: _vendor!,
                totalKm: _totalKm,
                progress: _drive.value,
              ),
            ),
          ),
      ],
    );
  }
}

class _TopCard extends StatelessWidget {
  final bool hasVendor;

  const _TopCard({required this.hasVendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.celebration_outlined,
            size: 18,
            color: AppColors.blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sat · Wedding reception',
                  style: AppText.body.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                Text(
                  hasVendor
                      ? 'Tap another vendor to switch'
                      : 'Tap a vendor pin to track them',
                  style: AppText.bodyMuted.copyWith(fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final _Vendor vendor;
  final double totalKm;
  final double progress;

  const _TripCard({
    required this.vendor,
    required this.totalKm,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final leftKm = totalKm * (1 - progress);
    final etaMin = (leftKm / _cityKmh * 60).ceil();
    final arrived = progress >= 1;

    return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.blueDeep,
                    child: Icon(vendor.icon, size: 18, color: AppColors.text),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: AppText.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          vendor.category.toUpperCase(),
                          style: AppText.monoLabel.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (arrived ? AppColors.online : AppColors.blue)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      arrived
                          ? 'ARRIVED'
                          : (progress == 0 ? 'ROUTING' : 'EN ROUTE'),
                      style: AppText.mono.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: arrived ? AppColors.online : AppColors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Figure(
                    label: 'DISTANCE',
                    value: '${leftKm.toStringAsFixed(1)} km',
                  ),
                  _Figure(label: 'ETA', value: arrived ? 'now' : '$etaMin min'),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: AppColors.raised,
                  color: arrived ? AppColors.online : AppColors.blue,
                ),
              ),
            ],
          ),
        )
        .animate(key: ValueKey(vendor.name))
        .fadeIn(duration: 200.ms)
        .slideY(
          begin: 0.3,
          end: 0,
          duration: AppMotion.big,
          curve: AppMotion.spring,
        );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final String value;

  const _Figure({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.monoLabel.copyWith(fontSize: 9)),
          Text(
            value,
            style: AppText.mono.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientPin extends StatelessWidget {
  const _ClientPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: AppColors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
      ),
    );
  }
}

class _VendorPin extends StatelessWidget {
  final _Vendor vendor;
  final bool selected;
  final VoidCallback onTap;

  const _VendorPin({
    required this.vendor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${vendor.name}, ${vendor.category}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedScale(
            scale: selected ? 1.15 : 1,
            duration: AppMotion.hover,
            curve: AppMotion.spring,
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppColors.blue : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : AppColors.blue,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(vendor.icon, size: 18, color: AppColors.text),
            ),
          ),
        ),
      ),
    );
  }
}

class _Car extends StatelessWidget {
  const _Car();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.7),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car_filled,
        size: 18,
        color: AppColors.blueDeep,
      ),
    );
  }
}
