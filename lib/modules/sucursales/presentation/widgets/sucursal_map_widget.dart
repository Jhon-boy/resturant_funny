import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:share_plus/share_plus.dart';
import 'package:resturant_funny/core/theme_app.dart';

/// Widget de mapa para mostrar y/o seleccionar la ubicación de una sucursal.
///
/// - Si [enableSelection] es true, permite seleccionar la ubicación tocando el mapa
///   y notifica vía [onLocationSelected].
/// - Siempre inicia centrado en Riobamba, y opcionalmente intenta obtener
///   la ubicación actual (solo para mejorar la experiencia).
class SucursalMapWidget extends ConsumerStatefulWidget {
  final double? latitud;
  final double? longitud;
  final bool enableSelection;
  final void Function(double lat, double lng)? onLocationSelected;
  final double height;
  final String? sucursalNombre;
  final String? sucursalContacto;
  final bool showShareButton;

  const SucursalMapWidget({
    super.key,
    this.latitud,
    this.longitud,
    this.enableSelection = false,
    this.onLocationSelected,
    this.height = 220,
    this.sucursalNombre,
    this.sucursalContacto,
    this.showShareButton = true,
  });

  @override
  ConsumerState<SucursalMapWidget> createState() => _SucursalMapWidgetState();
}

class _SucursalMapWidgetState extends ConsumerState<SucursalMapWidget> {
  // Coordenadas de Riobamba como centro inicial
  static const LatLng _riobambaCenter = LatLng(-1.664, -78.654);

  LatLng? _markerPosition;
  LatLng _mapCenter = _riobambaCenter;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Si la sucursal ya tiene coordenadas, usarlas
    if (widget.latitud != null && widget.longitud != null) {
      _markerPosition = LatLng(widget.latitud!, widget.longitud!);
      _mapCenter = _markerPosition!;
    }

    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      // Sin permisos, mantenemos Riobamba como centro.
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      setState(() {
        // Solo cambiamos el centro si no había una coordenada previa.
        if (_markerPosition == null) {
          _mapCenter = LatLng(position.latitude, position.longitude);
        }
        _mapController.move(_mapCenter, _mapController.camera.zoom);
      });
    } catch (_) {
      // Si falla obtener ubicación, no pasa nada; seguimos con Riobamba.
    }
  }

  void _onTapMap(TapPosition tapPosition, LatLng latLng) {
    if (!widget.enableSelection) return;

    setState(() {
      _markerPosition = latLng;
    });
    widget.onLocationSelected?.call(latLng.latitude, latLng.longitude);
  }

  Future<void> _goToRiobamba() async {
    setState(() {
      _mapCenter = _riobambaCenter;
      if (widget.enableSelection && _markerPosition == null) {
        _markerPosition = _riobambaCenter;
      }
    });
    _mapController.move(_mapCenter, _mapController.camera.zoom);
  }

  Future<void> _goToCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final target = LatLng(position.latitude, position.longitude);
      setState(() {
        _mapCenter = target;
        if (widget.enableSelection) {
          _markerPosition = target;
        }
      });
      _mapController.move(target, _mapController.camera.zoom);
    } catch (_) {
      // Silenciar errores de ubicación, mantenemos el mapa como está.
    }
  }

  void _zoom(double delta) {
    final camera = _mapController.camera;
    final newZoom = (camera.zoom + delta).clamp(3.0, 19.0);
    _mapController.move(camera.center, newZoom);
  }

  String _buildShareMessage() {
    if (_markerPosition == null) {
      return 'Ubicación no disponible';
    }

    final lat = _markerPosition!.latitude;
    final lng = _markerPosition!.longitude;

    final nombre = (widget.sucursalNombre != null &&
            widget.sucursalNombre!.trim().isNotEmpty)
        ? widget.sucursalNombre!.trim()
        : 'Sucursal';

    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    return 'Hola, te comparto la ubicación de nuestra sucursal $nombre\n$googleMapsUrl';
  }

  Future<void> _shareLocation() async {
    if (_markerPosition == null) return;

    final nombre = (widget.sucursalNombre != null &&
            widget.sucursalNombre!.trim().isNotEmpty)
        ? widget.sucursalNombre!.trim()
        : 'Sucursal';

    final message = _buildShareMessage();

    await Share.share(
      message,
      subject: 'Ubicación de $nombre',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map,
              size: 20,
              color: ThemeApp.primary,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                widget.enableSelection
                    ? 'Ubicación en el mapa (toque para seleccionar)'
                    : 'Ubicación de la sucursal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.visible,
                  color: ThemeApp.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _mapCenter,
                    initialZoom: 15,
                    onTap: _onTapMap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.resturant_funny',
                    ),
                    if (_markerPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _markerPosition!,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 60,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.sucursalNombre != null &&
                                    widget.sucursalNombre!.trim().isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: ThemeApp.primary,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.sucursalNombre!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: ThemeApp.baseText,
                                      ),
                                    ),
                                  ),
                                if (widget.sucursalNombre != null &&
                                    widget.sucursalNombre!.trim().isNotEmpty)
                                  const SizedBox(height: 4),
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Column(
                    children: [
                      _MapControlButton(
                        icon: Icons.my_location,
                        tooltip: 'Mi ubicación',
                        onPressed: _goToCurrentLocation,
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.location_city,
                        tooltip: 'Centro Riobamba',
                        onPressed: _goToRiobamba,
                      ),
                      const SizedBox(height: 40),
                      _MapControlButton(
                        icon: Icons.add,
                        tooltip: 'Acercar',
                        onPressed: () => _zoom(1),
                      ),
                      const SizedBox(height: 8),
                      _MapControlButton(
                        icon: Icons.remove,
                        tooltip: 'Alejar',
                        onPressed: () => _zoom(-1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.enableSelection &&
            _markerPosition != null &&
            widget.showShareButton)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      icon: Icons.share,
                      colorText: ThemeApp.baseText,
                      colorButton: ThemeApp.primary,
                      text: 'Compartir ubicación',
                      onPressed: _shareLocation,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 20,
              color: ThemeApp.primary,
            ),
          ),
        ),
      ),
    );
  }
}
