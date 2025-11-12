import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/singleton/singleton_app.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/authentication/domain/entity/rol_entity.dart';
import 'package:resturant_funny/modules/authentication/domain/model/user_model.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/user/presentation/edit_credentials_page.dart';

class PerfilPage extends ConsumerStatefulWidget {
  const PerfilPage({super.key});
  @override
  ConsumerState<PerfilPage> createState() => _PerfilStatePage();
}

class _PerfilStatePage extends ConsumerState<PerfilPage> {
  late UserModel user;
  late List<RolEntity> roles;
  bool isLoading = true;
  bool hasUser = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    final singletonUser = SingletonApp.getUser();
    final singletonRoles = SingletonApp.getRoles();
    if (singletonUser != null) {
      setState(() {
        user = singletonUser;
        hasUser = true;
      });
      debugPrint("User loaded from Singleton");
    } else {
      final providerUser = ref.read(userProvider).user;
      if (providerUser != null) {
        setState(() {
          user = providerUser;
          hasUser = true;
        });
        debugPrint("User loaded from Provider");
      }
    }

    if (singletonRoles.isNotEmpty) {
      setState(() {
        roles = singletonRoles;
      });
      debugPrint("Roles loaded from Singleton");
    } else {
      final providerRoles = ref.read(userProvider).roles;
      if (providerRoles.isNotEmpty) {
        setState(() {
          roles = providerRoles;
        });
        debugPrint("Roles loaded from Provider");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeApp.background,
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Encabezado con avatar y nombre
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: ThemeApp.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: ThemeApp.baseText,
                          child: Text(
                            AppUtils.getInitialsName(user),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: ThemeApp.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${user.nombres} ${user.apellidos}",
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeApp.baseText),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.usuario ?? "-",
                                style: const TextStyle(
                                    fontSize: 14, color: ThemeApp.baseText),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Información en secciones con fondo ligero
                const Text("Información usuario", style: TextStyle(color: ThemeApp.apple),),
                SizedBox(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    color: ThemeApp.background,
                     child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () async {
                      final updated = await Navigator.of(context).push<UserModel>(
                        MaterialPageRoute(
                          builder: (_) => EditCredentialsPage(user: user),
                        ),
                      );
                      if (updated != null && mounted) {
                        setState(() {
                          user = updated;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _infoRow(Icons.email, 'Correo', user.correo ?? "-"),
                          const SizedBox(height: 10),
                          _infoRow(
                              Icons.person, 'Usuario', user.usuario ?? "-"),
                          const SizedBox(height: 10),
                          _infoRow(Icons.email, 'Sucursal',
                              user.idSucursal.toString()),
                          const SizedBox(height: 10),
                          _infoRow(Icons.calendar_month, 'Creado',
                              AppUtils.formatDate(user.fCreacionUsuario)),
                          const SizedBox(height: 10),
                          _infoRow(Icons.calendar_month, 'Ult. Actualización',
                              AppUtils.formatDate(user.fModificacionUsuario)),
                        ],
                      ),
                    ),
                    )
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                // Información en secciones con fondo ligero
                const Text("Información Persona", style: TextStyle(color: ThemeApp.apple),),
                SizedBox(
                    child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  color: ThemeApp.background,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _infoRow(Icons.badge, 'Nombres', user.nombres),
                        const SizedBox(height: 10),
                        _infoRow(Icons.badge, 'Apellidos', user.apellidos),
                        const SizedBox(height: 10),
                        _infoRow(Icons.badge, 'Identificación:',
                            user.identificacion ?? "-"),
                        const SizedBox(height: 10),
                        _infoRow(Icons.phone, 'Teléfono', user.telefono ?? "-"),
                        const SizedBox(height: 10),
                        _infoRow(
                            Icons.home, 'Dirección', user.direccion ?? "-"),
                        const SizedBox(height: 10),
                        _infoRow(Icons.person, 'Género', user.genero ?? "-"),
                        const SizedBox(height: 10),
                        _infoRow(Icons.credit_card, 'Tipo',
                            user.tipoIdentificacion ?? "-"),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          )),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: ThemeApp.primary.withOpacity(0.2),
              child: Icon(icon, size: 18, color: ThemeApp.primary),
            ),
            const SizedBox(width: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.headerBackground,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Flexible(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: ThemeApp.textSecondary,
                    fontSize: 14,
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
