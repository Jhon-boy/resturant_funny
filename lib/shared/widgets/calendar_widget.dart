import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:resturant_funny/core/theme_app.dart';
import 'package:resturant_funny/core/utils/app_util.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  final String title;
  final String hint;
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final IconData? icon;
  final String? Function(DateTime?)? validator;
  final Function(DateTime?) onDateSelected;
  final bool enabled;

  const CalendarWidget({
    super.key,
    required this.title,
    required this.onDateSelected,
    this.hint = 'Seleccionar fecha',
    this.selectedDate,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.icon,
    this.validator,
    this.enabled = true,
  });

  /// Método estático para mostrar el selector de fecha como diálogo usando calendar_date_picker2
  static Future<DateTime?> showDatePickerDialog({
    required BuildContext context,
    String title = 'Seleccionar Fecha',
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTime>(
      context: context,
      builder: (context) => _DatePickerDialog(
        title: title,
        initialDate: initialDate ?? AppUtils.getFechaActual(),
        firstDate: firstDate ?? DateTime(1900),
        lastDate: lastDate ??
            AppUtils.getFechaActual().add(const Duration(days: 365)),
      ),
    );
  }

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  DateTime? _selectedDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
  }

  Future<void> _selectDate() async {
    if (!widget.enabled) return;

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _DatePickerDialog(
        title: 'Seleccionar Fecha',
        initialDate: _selectedDate ?? widget.initialDate ?? DateTime.now(),
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate:
            widget.lastDate ?? DateTime.now().add(const Duration(days: 365)),
      ),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _errorMessage = null;
      });

      // Validar si hay validador
      if (widget.validator != null) {
        final error = widget.validator!(picked);
        setState(() {
          _errorMessage = error;
        });
      }

      // Notificar al padre
      widget.onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con estilo mejorado
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeApp.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Campo de fecha con diseño moderno
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Material(
            elevation: _selectedDate != null ? 2 : 0,
            borderRadius: BorderRadius.circular(16),
            shadowColor: ThemeApp.primary.withOpacity(0.2),
            child: InkWell(
              onTap: widget.enabled ? _selectDate : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  gradient: _selectedDate != null
                      ? LinearGradient(
                          colors: [
                            ThemeApp.primary.withOpacity(0.05),
                            ThemeApp.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _selectedDate != null
                      ? null
                      : (widget.enabled ? Colors.white : Colors.grey.shade100),
                  border: Border.all(
                    color: _errorMessage != null
                        ? ThemeApp.error
                        : (_selectedDate != null
                            ? ThemeApp.primary.withOpacity(0.3)
                            : Colors.grey.shade300),
                    width: _selectedDate != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _selectedDate != null
                      ? [
                          BoxShadow(
                            color: ThemeApp.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Icono con animación
                    _selectedDate == null
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _selectedDate != null
                                  ? ThemeApp.primary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.icon ?? Icons.calendar_today,
                              color: widget.enabled
                                  ? (_selectedDate != null
                                      ? ThemeApp.primary
                                      : Colors.grey.shade600)
                                  : Colors.grey.shade400,
                              size: 20,
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(width: 16),

                    // Texto de fecha
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: _selectedDate != null
                              ? ThemeApp.textPrimary
                              : Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: _selectedDate != null
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        child: Text(
                          _selectedDate != null
                              ? _formatDate(_selectedDate!)
                              : widget.hint,
                        ),
                      ),
                    ),

                    // Botón de limpiar con animación
                    if (_selectedDate != null && widget.enabled)
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                                _errorMessage = null;
                              });
                              widget.onDateSelected(null);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Indicador de estado
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.enabled
                          ? ThemeApp.primary.withOpacity(0.7)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Mensaje de error con mejor diseño
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ThemeApp.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemeApp.error.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: ThemeApp.error,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: ThemeApp.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget para rango de fechas usando calendar_date_picker2
class DateRangeWidget extends ConsumerStatefulWidget {
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final bool enabled;

  const DateRangeWidget({
    super.key,
    required this.title,
    required this.onDateRangeSelected,
    this.startDate,
    this.endDate,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  @override
  ConsumerState<DateRangeWidget> createState() => _DateRangeWidgetState();
}

class _DateRangeWidgetState extends ConsumerState<DateRangeWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _selectDateRange() async {
    if (!widget.enabled) return;

    final List<DateTime?>? picked = await showDialog<List<DateTime?>>(
      context: context,
      builder: (context) => _DateRangePickerDialog(
        title: 'Seleccionar Rango',
        startDate: _startDate,
        endDate: _endDate,
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime.now(),
      ),
    );

    if (picked != null && picked.isNotEmpty) {
      setState(() {
        _startDate = picked.first;
        _endDate = picked.length > 1 ? picked.last : null;
      });
      widget.onDateRangeSelected(_startDate, _endDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedRange = _startDate != null && _endDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label con estilo mejorado
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeApp.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Campo de rango con diseño moderno
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Material(
            elevation: hasSelectedRange ? 2 : 0,
            borderRadius: BorderRadius.circular(16),
            shadowColor: ThemeApp.primary.withOpacity(0.2),
            child: InkWell(
              onTap: widget.enabled ? _selectDateRange : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: hasSelectedRange
                      ? LinearGradient(
                          colors: [
                            ThemeApp.primary.withOpacity(0.05),
                            ThemeApp.primary.withOpacity(0.02),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: hasSelectedRange
                      ? null
                      : (widget.enabled ? Colors.white : Colors.grey.shade100),
                  border: Border.all(
                    color: hasSelectedRange
                        ? ThemeApp.primary.withOpacity(0.3)
                        : Colors.grey.shade300,
                    width: hasSelectedRange ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: hasSelectedRange
                      ? [
                          BoxShadow(
                            color: ThemeApp.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Icono con animación
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: hasSelectedRange
                            ? ThemeApp.primary.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.date_range,
                        color: widget.enabled
                            ? (hasSelectedRange
                                ? ThemeApp.primary
                                : Colors.grey.shade600)
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Texto de rango
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: hasSelectedRange
                              ? ThemeApp.textPrimary
                              : Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: hasSelectedRange
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        child: Text(
                          hasSelectedRange
                              ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                              : 'Seleccionar rango de fechas',
                        ),
                      ),
                    ),

                    // Botón de limpiar con animación
                    if (hasSelectedRange && widget.enabled)
                      AnimatedScale(
                        scale: 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              widget.onDateRangeSelected(null, null);
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.grey.shade600,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Indicador de estado
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.enabled
                          ? ThemeApp.primary.withOpacity(0.7)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Diálogo personalizado para selección de fecha única
class _DatePickerDialog extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DatePickerDialog({
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: ThemeApp.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ThemeApp.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Calendar
            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.single,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDayHighlightColor: ThemeApp.primary,
                weekdayLabelTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                controlsTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                dayTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                disabledDayTextStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                selectedDayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: _selectedDate != null ? [_selectedDate!] : [],
              onValueChanged: (dates) {
                if (dates.isNotEmpty) {
                  setState(() {
                    _selectedDate = dates.first;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeApp.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Seleccionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRangePickerDialog extends StatefulWidget {
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DateRangePickerDialog({
    required this.title,
    this.startDate,
    this.endDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_DateRangePickerDialog> createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    if (widget.startDate != null && widget.endDate != null) {
      _selectedDates = [widget.startDate, widget.endDate];
    } else if (widget.startDate != null) {
      _selectedDates = [widget.startDate];
    } else {
      _selectedDates = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: ThemeApp.white,
              child: // Header
                  Row(
                children: [
                  const Icon(
                    Icons.date_range,
                    color: ThemeApp.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: ThemeApp.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: ThemeApp.textPrimary),
                  ),
                ],
              ),
            ),
            const Divider(
              color: ThemeApp.textPrimary,
              thickness: 1,
            ),
            const SizedBox(height: 20),

            CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                selectedDayHighlightColor: ThemeApp.primary,
                selectedRangeHighlightColor: ThemeApp.primary.withOpacity(0.3),
                weekdayLabelTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                controlsTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                dayTextStyle: const TextStyle(
                  color: ThemeApp.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                disabledDayTextStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                selectedDayTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              value: _selectedDates,
              onValueChanged: (dates) {
                setState(() {
                  _selectedDates = dates;
                });
              },
            ),
            const SizedBox(height: 20),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDates),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeApp.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Seleccionar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
