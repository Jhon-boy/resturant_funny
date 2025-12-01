// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/main/domain/entity/sucursal_entity.dart';
import 'package:resturant_funny/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:resturant_funny/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/domain/sucursal_repository.dart';
import 'package:resturant_funny/modules/sucursales/presentation/widgets/sucursal_map_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class SucursalesListaPage extends ConsumerStatefulWidget {
  const SucursalesListaPage({super.key});

  @override
  ConsumerState<SucursalesListaPage> createState() =>
      _SucursalesListaPageState();
}

class _SucursalesListaPageState extends ConsumerState<SucursalesListaPage> {
  late SucursalRepository _sucursalRepository;
  List<SucursalEntity> _sucursales = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sucursalRepository = SucursalRemoteRepository(
        SucursalRemoteDataSource(ref: ref),
      );
      _loadSucursales();
    });
  }

  Future<void> _loadSucursales() async {
    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final result = await _sucursalRepository.getSucursalesEntityFree();
      result.fold(
        (failure) {
          appState.setLoading(false);
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar sucursales: ${failure.message}',
              isError: true,
            );
          }
        },
        (sucursales) {
          setState(() {
            _sucursales = sucursales.where((s) => s.isActiva).toList();
            _isLoading = false;
          });
          appState.setLoading(false);
        },
      );
    } catch (e) {
      appState.setLoading(false);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error inesperado: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _openWhatsapp(SucursalEntity sucursal) async {
    final contacto = sucursal.contacto?.trim() ?? '';
    if (contacto.isEmpty) {
      SnackHelper.show(
        context,
        message: 'Esta sucursal no tiene un número de contacto configurado.',
        isError: true,
      );
      return;
    }

    String phone = contacto.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phone.startsWith('593')) {
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      phone = '593$phone';
    }

    final lat = sucursal.latitud;
    final lng = sucursal.longitud;

    final buffer = StringBuffer()
      ..write('Hola, me interesa la sucursal ${sucursal.nombre}');

    if (lat != null && lng != null) {
      final mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      buffer.write('\nUbicación: $mapsUrl');
    }

    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(buffer.toString())}',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _openGoogleMaps(SucursalEntity sucursal) async {
    try {
      final lat = sucursal.latitud;
      final lng = sucursal.longitud;
      if (lat == null || lng == null) {
        SnackHelper.show(
          context,
          message: 'Esta sucursal no tiene coordenadas configuradas.',
          isError: true,
        );
        return;
      }

      final mapsUrl =
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
      await launchUrl(
        Uri.parse(mapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      SnackHelper.show(
        context,
        message: 'Error al abrir Google Maps: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sucursales'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: ThemeApp.primary,
        onRefresh: _loadSucursales,
        child: _isLoading
            ? Center(child: ThemeApp.buildShimmerLoading())
            : _sucursales.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 80),
                      Icon(
                        Icons.store_outlined,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'No hay sucursales disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: ThemeApp.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sucursales.length,
                    itemBuilder: (context, index) {
                      final sucursal = _sucursales[index];
                      return _SucursalItem(
                        sucursal: sucursal,
                        onWhatsapp: () => _openWhatsapp(sucursal),
                        onGoogleMaps: () => _openGoogleMaps(sucursal),
                      );
                    },
                  ),
      ),
    );
  }
}

class _SucursalItem extends StatelessWidget {
  final SucursalEntity sucursal;
  final VoidCallback onWhatsapp;
  final VoidCallback onGoogleMaps;
  const _SucursalItem({
    required this.sucursal,
    required this.onWhatsapp,
    required this.onGoogleMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: sucursal.isActiva
                        ? ThemeApp.primary
                        : Colors.grey.shade400,
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sucursal.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (sucursal.direccion != null &&
                            sucursal.direccion!.isNotEmpty)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  sucursal.direccion!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        if (sucursal.contacto != null &&
                            sucursal.contacto!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sucursal.contacto!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SucursalMapWidget(
              latitud: sucursal.latitud,
              longitud: sucursal.longitud,
              sucursalNombre: sucursal.nombre,
              sucursalContacto: sucursal.contacto,
              enableSelection: false,
              height: 180,
              showShareButton: false,
            ),
            if (sucursal.contacto != null &&
                sucursal.contacto!.trim().isNotEmpty)
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: onWhatsapp,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              backgroundColor: ThemeApp.success,
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.whatsapp,
                                  color: ThemeApp.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Whatsapp',
                                  style: TextStyle(color: ThemeApp.white),
                                )
                              ],
                            )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                          child: TextButton(
                              onPressed: () {
                                onGoogleMaps();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                backgroundColor: ThemeApp.cardColors,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.locationDot,
                                    color: ThemeApp.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Como llegar',
                                    style:
                                        TextStyle(color: ThemeApp.textPrimary),
                                  )
                                ],
                              )))
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}
