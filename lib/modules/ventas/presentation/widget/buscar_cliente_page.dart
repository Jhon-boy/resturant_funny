import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/app/providers/provider.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/persona_entity.dart';
import 'package:resturant_funny/modules/common/widgets/persona_card.dart';
import 'package:resturant_funny/modules/user/data/datasource/persona_data_source.dart';
import 'package:resturant_funny/modules/user/data/repository/persona_repository_impl.dart';
import 'package:resturant_funny/modules/user/domain/repository/persona_repository.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:resturant_funny/shared/widgets/input_search_widget.dart';

class BuscarClienteWidget extends ConsumerStatefulWidget {
  final Function(PersonaEntity)? onClienteSeleccionado;
  final String? titulo;

  const BuscarClienteWidget({
    super.key,
    this.onClienteSeleccionado,
    this.titulo,
  });

  @override
  ConsumerState<BuscarClienteWidget> createState() =>
      _BuscarClienteWidgetState();

  /// Método estático para mostrar el diálogo de búsqueda de cliente
  static Future<PersonaEntity?> show({
    required BuildContext context,
    String? titulo,
  }) {
    return showDialog<PersonaEntity>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BuscarClienteWidget(
        titulo: titulo,
      ),
    );
  }
}

class _BuscarClienteWidgetState extends ConsumerState<BuscarClienteWidget> {
  final TextEditingController _identificacionController =
      TextEditingController();
  final List<PersonaEntity> _clientesEncontrados = [];
  bool _sinResultados = false;
  String? _errorCedula;
  late final PersonasRepository _personasRepository;

  @override
  void initState() {
    super.initState();
    _personasRepository = PersonaRepositoryImpl(
      PersonasRemoteDataSource(ref: ref),
    );
  }

  @override
  void dispose() {
    _identificacionController.dispose();
    super.dispose();
  }

  Future<void> _buscarCliente() async {
    if (_identificacionController.text.trim().isEmpty) {
      SnackHelper.show(
        context,
        message: "Ingrese un número de cédula",
        isError: true,
      );
      return;
    }

    setState(() {
      ref.read(appStateProvider).setProcessLoading(true);
      _sinResultados = false;
      _clientesEncontrados.clear();
    });

    try {
      debugPrint("Cédula: ${_identificacionController.text.trim()}");
      final result = await _personasRepository
          .getPersonaByIdentificacion(_identificacionController.text.trim());

      result.fold(
        (failure) {
          setState(() {
            ref.read(appStateProvider).setProcessLoading(false);
            _sinResultados = true;
          });
          SnackHelper.show(
            context,
            message: "Cliente no encontrado",
            isError: true,
          );
        },
        (persona) {
          setState(() {
            ref.read(appStateProvider).setProcessLoading(false);
            _clientesEncontrados.add(persona);
          });
          SnackHelper.show(
            context,
            message: "Cliente encontrado",
            isSuccess: true,
          );
        },
      );
    } catch (e) {
      setState(() {
        ref.read(appStateProvider).setProcessLoading(false);
        _sinResultados = true;
      });
      SnackHelper.show(
        // ignore: use_build_context_synchronously
        context,
        message: "Error al buscar cliente: $e",
        isError: true,
      );
    }
  }

  void _seleccionarCliente(PersonaEntity cliente) {
    if (widget.onClienteSeleccionado != null) {
      widget.onClienteSeleccionado!(cliente);
    }
    Navigator.of(context).pop(cliente);
  }

  void _crearNuevoCliente() {
    Navigator.of(context).pushNamed('/crear-cliente');
  }

  void _limpiarBusqueda() {
    setState(() {
      _identificacionController.clear();
      _clientesEncontrados.clear();
      _sinResultados = false;
      _errorCedula = null;
      ref.read(appStateProvider).setProcessLoading(false);
    });
  }

  void _validarCedulaEnTiempoReal(String value) {
    if (value.isEmpty) {
      _errorCedula = null;
    } else if (value.length < 10) {
      _errorCedula = 'La cédula debe tener 10 dígitos';
    } else {
      _errorCedula = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: ThemeApp.background,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: ThemeApp.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_search,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.titulo ?? "Buscar Cliente",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InputSearchWidget(
                                    label: "Cédula",
                                    hint: "1234567890",
                                    onSubmitted: (value) {
                                      _identificacionController.text = value;
                                      _buscarCliente();
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        _identificacionController.text = value;
                                        _validarCedulaEnTiempoReal(value);
                                      });
                                    },
                                    maxLength: 10,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese un número de cédula';
                                      }
                                      if (value.length < 10) {
                                        return 'La cédula debe tener 10 dígitos';
                                      }
                                      if (!AppUtils.validarCedula(value)) {
                                        return 'Cédula inválida';
                                      }
                                      return null;
                                    },
                                    errorMessage: _errorCedula),
                              ),
                            ],
                          ),
                          if (_clientesEncontrados.isNotEmpty ||
                              _sinResultados) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _limpiarBusqueda,
                                  icon: const Icon(Icons.clear, size: 18),
                                  label: const Text("Limpiar"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Resultados de búsqueda
                    if (ref.read(appStateProvider).isProcessLoading) ...[
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Buscando cliente..."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ] else if (_sinResultados) ...[
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.person_search,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Cliente no encontrado",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "No se encontró un cliente con la cédula ingresada",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              CustomButton(
                                text: "Crear Nuevo Cliente",
                                icon: Icons.person_add,
                                onPressed: _crearNuevoCliente,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_clientesEncontrados.isNotEmpty) ...[
                      Text(
                        "Cliente Encontrado",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._clientesEncontrados.map((cliente) => PersonaCard(
                          cliente: cliente,
                          onTap: () => _seleccionarCliente(cliente))),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
