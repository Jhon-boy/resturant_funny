import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resturant_funny/core/app_constants.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/core/utils/parameter_util.dart';
import 'package:resturant_funny/core/utils/snack_helper.dart';
import 'package:resturant_funny/modules/authentication/domain/providers/user_provider.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/modules/ventas/domain/models/card_item_model.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FacturaPage extends ConsumerStatefulWidget {
  final VentaEntity venta;
  final List<CartProduct> carrito;

  const FacturaPage({super.key, required this.venta, required this.carrito});

  @override
  ConsumerState<FacturaPage> createState() => _FacturaPageState();
}

class _FacturaPageState extends ConsumerState<FacturaPage> {
  Timer? _autoReturnTimer;
  ScreenshotController screenshotController = ScreenshotController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startAutoReturnTimer();
  }

  @override
  void dispose() {
    _autoReturnTimer?.cancel();
    super.dispose();
  }

  void _startAutoReturnTimer() {
    _autoReturnTimer =
        Timer(Duration(minutes: ParameterUtil.getTimeAutoReturn()), () {
      if (mounted) {
        AppUtils.backToHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        AppUtils.backToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                _buildCarritoSection(),
                Screenshot(
                  controller: screenshotController,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildVentaSection(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeApp.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 25,
          ),
          const SizedBox(width: 20),
          Text(
            AppConstants.APP_NAME,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarritoSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_cart, color: ThemeApp.primary),
              SizedBox(width: 10),
              Text(
                'Productos Comprados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildColumnHeaders(),
          const SizedBox(height: 10),
          ...widget.carrito.map((item) => _buildCarritoItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    const double letterWidth = 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeApp.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ThemeApp.primary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              'PRODUCTO',
              style: TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.bold,
                color: ThemeApp.primary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              '#',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.bold,
                color: ThemeApp.primary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'C/U',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.bold,
                color: ThemeApp.primary,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              'TOTAL',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.bold,
                color: ThemeApp.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarritoItem(CartProduct item) {
    const double letterWidth = 10;
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              item.producto.nombre,
              style: const TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 1,
            child: Text(
              '${item.cantidad}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Text(
              '\$${item.producto.precio.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: letterWidth,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Text(
              '\$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVentaSection() {
    final user = ref.read(userProvider).user;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt, color: ThemeApp.primary),
              SizedBox(width: 10),
              Text(
                'Datos de la Factura',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildVentaInfo('ID Venta', '#${widget.venta.idVenta ?? 'N/A'}'),
          _buildVentaInfo('RUC', ParameterUtil.getRucCompany()),
          _buildVentaInfo('Beneficiario', widget.venta.cliente),
          _buildVentaInfo('Fecha', AppUtils.formatDate(widget.venta.fecha)),
          _buildVentaInfo('Tipo de Venta', widget.venta.tipoVentaFormateado),
          _buildVentaInfo('Estado', widget.venta.estadoFormateado),
          _buildVentaInfo('# Productos', widget.carrito.length.toString()),
          _buildVentaInfo(
              'Usuario Venta', widget.venta.usuarioIngreso ?? 'N/A'),
          _buildVentaInfo('Sucursal', user?.idSucursal?.toString() ?? 'N/A'),
          if (widget.venta.comentario != null &&
              widget.venta.comentario!.isNotEmpty)
            _buildVentaInfo('Comentario', widget.venta.comentario!),
          const SizedBox(height: 2),
          const Divider(height: 15),
          const SizedBox(height: 15),
          _buildVentaInfo(
              'Subtotal', AppUtils.formatMoney(widget.venta.subtotal ?? 0.00)),
          _buildVentaInfo(
              'Total', AppUtils.formatMoney(widget.venta.total ?? 0.00),
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildVentaInfo(String label, String value, {bool isTotal = false}) {
    const double letterWidth = 14;
    const double letterWidth2 = 10;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? letterWidth : letterWidth2,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? letterWidth : letterWidth2,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Compartir",
              icon: Icons.share,
              isLoading: _isLoading,
              colorButton: ThemeApp.apple,
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                await _compartirFactura();
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: "Volver al Inicio",
              isLoading: _isLoading,
              icon: Icons.home,
              onPressed: () {
                AppUtils.backToHome();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _compartirFactura() async {
    try {
      final Uint8List? image = await screenshotController.capture(
        delay: const Duration(milliseconds: 500),
      );

      if (image != null) {
        final XFile file = XFile.fromData(
          image,
          name:
              'factura_${widget.venta.idVenta}_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        );

        await Share.shareXFiles(
          [file],
          text:
              'Factura de Venta #${widget.venta.idVenta} - ${AppConstants.APP_NAME}',
        );
      } else {
        if (mounted) {
          SnackHelper.show(context,
              message: 'Error al capturar la factura', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        SnackHelper.show(context,
            message: 'Error al compartir: $e', isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
