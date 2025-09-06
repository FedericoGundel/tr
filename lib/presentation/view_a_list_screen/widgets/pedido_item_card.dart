import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PedidoItemCard extends StatelessWidget {
  final Map<String, dynamic> pedido;
  final VoidCallback? onTap;
  final VoidCallback? onIdentificar;
  final VoidCallback? onEntregar;
  final VoidCallback? onIncidencias;
  final VoidCallback? onFotos;
  const PedidoItemCard({
    super.key,
    required this.pedido,
    this.onTap,
    this.onIdentificar,
    this.onEntregar,
    this.onIncidencias,
    this.onFotos
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👉 Encabezado con número de pedido y empresa
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getEstadoColor(pedido["Estado"] ?? ""),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.local_shipping,
                        color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pedido #${pedido["NroPedido"] ?? "-"}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          pedido["NombreEmpresa"] ?? "Empresa desconocida",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(pedido["Estado"] ?? "")
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pedido["Estado"] ?? "Desconocido",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getEstadoColor(pedido["Estado"] ?? ""),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // 👉 Fecha arriba de pallets
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text(
                    pedido["Fecha"] ?? "-",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.h),

              // 👉 Info principal: palets, bultos, conductor
              Row(
                children: [
                  Icon(Icons.view_in_ar,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text(
                    "Palets: ${pedido["TotalPaletsIdentificados"] ?? 0} "
                        "(${pedido["TotalPaletsEntregados"] ?? 0} entregados)",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.inventory_2,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text(
                    "Bultos: ${pedido["TotalBultosIdentificados"] ?? 0} "
                        "(${pedido["TotalBultosEntregados"] ?? 0} entregados)",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.person,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text("Conductor: ${pedido["Conductor"] ?? "-"}",
                      style: theme.textTheme.bodySmall),
                ],
              ),

              SizedBox(height: 1.5.h),

              // 👉 Acciones
              Row(
                children: [
                  const Spacer(),
                  if (onIdentificar != null || onEntregar != null || onIncidencias != null)
                  // 👉 Acciones
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.photo, size: 14), // ícono más chico
                            label: const Text(
                              "Fotos",
                              style: TextStyle(fontSize: 12), // texto más chico
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.inversePrimary,
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), // menos padding
                              visualDensity: VisualDensity.compact, // compacta aún más
                            ),
                            onPressed: onFotos,
                          ),

                          if (onIdentificar != null)
                            TextButton.icon(
                              icon: const Icon(Icons.qr_code_scanner, size: 14), // ícono más chico
                              label: const Text(
                                "Identificar",
                                style: TextStyle(fontSize: 12), // texto más chico
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.secondary,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), // menos padding
                                visualDensity: VisualDensity.compact, // compacta aún más
                              ),
                              onPressed: onIdentificar,
                            ),
                          if (onEntregar != null)
                            TextButton.icon(
                              icon: const Icon(Icons.check_circle, size: 14),
                              label: const Text(
                                "Entregar",
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onEntregar,
                            ),
                          if (onIncidencias != null)
                            TextButton.icon(
                              icon: const Icon(Icons.report_problem, size: 14),
                              label: const Text(
                                "Incidencias",
                                style: TextStyle(fontSize: 12),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onIncidencias,
                            ),
                        ],
                      ),
                    ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case "pendiente":
        return AppTheme.warningLight;
      case "entregado":
        return AppTheme.lightTheme.colorScheme.primary;
      case "cancelado":
        return AppTheme.errorLight;
      case "en reparto":
        return Colors.blue;
      case "entrega incompleta":
        return Colors.orange;
      case "devuelto":
        return Colors.redAccent;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }
}
