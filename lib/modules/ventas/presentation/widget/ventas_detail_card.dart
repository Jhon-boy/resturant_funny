import 'package:flutter/material.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';
import 'package:resturant_funny/modules/ventas/domain/entity/venta_entity.dart';
import 'package:resturant_funny/shared/widgets/custom_buttom.dart';

class VentaDetailCard extends StatefulWidget {
  final VentaEntity venta;
  final bool initiallyExpanded;
  final bool showInDialog;
  final VoidCallback? onTap;

  const VentaDetailCard({
    super.key,
    required this.venta,
    this.initiallyExpanded = false,
    this.showInDialog = false,
    this.onTap,
  });

  @override
  State<VentaDetailCard> createState() => _VentaDetailCardState();
}

class _VentaDetailCardState extends State<VentaDetailCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showInDialog) {
      return _buildDialogContent(context);
    }
    return _buildCardContent(context);
  }

  Widget _buildCardContent(BuildContext context) {
    final colorEstado = AppUtils.getStatusColor(widget.venta.estado);
    final venta = widget.venta;

    return Card(
      color: ThemeApp.cardColors,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: _buildCompactHeader(context, venta, colorEstado),
            secondChild: _buildExpandedInfo(context, venta, colorEstado),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final colorEstado = AppUtils.getStatusColor(widget.venta.estado);
    final venta = widget.venta;

    return Dialog(
      backgroundColor: ThemeApp.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeApp.primary,
                      ThemeApp.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeApp.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Venta #${venta.idVenta ?? '-'}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: ThemeApp.fontFamily),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          venta.totalFormateado,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: ThemeApp.background.withOpacity(0.7),
                                width: 1),
                            borderRadius: BorderRadius.circular(20),
                            color: ThemeApp.background,
                          ),
                          child: Text(
                            venta.estadoFormateado,
                            style: TextStyle(
                              color: colorEstado,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('Detalle de la venta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.textPrimary,
                      fontFamily: ThemeApp.fontFamily)),
              const SizedBox(height: 8),
              _buildExpandedInfo(context, venta, colorEstado,
                  compactHeader: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactHeader(
      BuildContext context, VentaEntity venta, Color colorEstado) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Venta #${venta.idVenta ?? '-'}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              venta.totalFormateado,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              venta.estadoFormateado,
              style: TextStyle(
                color: colorEstado,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (!widget.showInDialog)
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey[500],
            ),
          ),
      ],
    );
  }

  Widget _buildExpandedInfo(
    BuildContext context,
    VentaEntity venta,
    Color colorEstado, {
    bool compactHeader = true,
  }) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final labelStyle =
        textStyle?.copyWith(color: Colors.grey[600], fontSize: 13);

    final Map<String, String> info = {
      'Cliente': venta.cliente,
      if (venta.tipoVenta != null) 'Tipo': venta.tipoVentaFormateado,
      if (venta.subtotal != null) 'Subtotal': venta.subtotalFormateado,
      if (venta.idMesa != 0) 'Mesa': venta.idMesa.toString(),
      if (venta.idEmpleado != 0) 'Empleado': venta.idEmpleado.toString(),
      if (venta.fecha != null) 'Fecha': AppUtils.formatDate(venta.fecha),
      if (venta.delivery != null && venta.delivery! > 0)
        'Delivery': venta.deliveryFormateado,
      'Total': venta.totalFormateado,
      if (venta.conFactura != null)
        'Con factura': venta.conFactura! ? 'Sí' : 'No',
      if (venta.comentario?.isNotEmpty ?? false)
        'Comentario': venta.comentario!,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compactHeader) _buildCompactHeader(context, venta, colorEstado),
        if (compactHeader) const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        ...info.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildInfoRow(e.key, e.value, labelStyle, textStyle),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.showInDialog)
          Center(
            child: CustomButton(
                width: MediaQuery.of(context).size.width * 0.4,
                colorButton: ThemeApp.inputBorder.withOpacity(0.9),
                colorText: ThemeApp.apple,
                text: 'Cerrar',
                onPressed: () => Navigator.of(context).pop()),
          )
      ],
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    TextStyle? labelStyle,
    TextStyle? textStyle,
  ) {
    // Determinar si el valor es largo (más de 30 caracteres)
    // Si es largo, se muestra en columna (multilínea) automáticamente
    final isLongText = value.length > 30;

    if (isLongText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(
            value,
            style: textStyle,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: labelStyle),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: label == 'Total'
                ? textStyle?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.green)
                : textStyle,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
