import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/conductor_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ScannerScreen extends StatefulWidget {
  final Map<String, dynamic>? pedidoInicial;

  const ScannerScreen({super.key, this.pedidoInicial});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}


class _ScannerScreenState extends State<ScannerScreen> {
  Map<String, dynamic>? _conductor;
  List<dynamic> _pedidos = [];
  Map<String, dynamic>? _pedido;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedidoInicial; // 👈 si viene seteado, lo guardo
    _fetchConductorData();
  }


  Future<void> _fetchConductorData() async {
    try {
      final data = await ConductorService.getPedidosConductor();
      if (data != null && data['user'] != null) {
        final pedidos = data['user']['pedidos'] as List<dynamic>? ?? [];

        setState(() {
          _conductor = data['user'];
          _pedidos = pedidos;

          // 👇 mantener seleccionado el mismo pedido si todavía existe
          if (_pedido != null) {
            final idActual = _pedido!['idRegistro'];
            final coincide = pedidos.firstWhere(
                  (p) => p['idRegistro'] == idActual,
              orElse: () => pedidos.isNotEmpty ? pedidos.last : null,
            );
            _pedido = coincide;
          } else {
            _pedido = pedidos.isNotEmpty ? pedidos.last : null;
          }

          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      setState(() => _loading = false);
    }
  }

  void _openManualEntry() {
    final numeroController = TextEditingController();
    String tipo = "palet"; // default

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text("Entrada manual"),
          contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 📌 Ya no pedimos HOST, lo sacamos del pedido seleccionado
              DropdownButtonFormField<String>(
                value: tipo,
                items: const [
                  DropdownMenuItem(value: "palet", child: Text("Palet")),
                  DropdownMenuItem(value: "bulto", child: Text("Bulto")),
                ],
                onChanged: (value) => tipo = value!,
                decoration: const InputDecoration(labelText: "Tipo"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: numeroController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Número palet/bulto",
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final numero = int.tryParse(numeroController.text);
                      final idRegistro = int.tryParse(
                          _pedido?['idRegistro'].toString() ?? '');

                      if (idRegistro == null || numero == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Datos inválidos")),
                        );
                        return;
                      }

                      Navigator.pop(context); // cerrar dialogo

                      try {
                        final uri = Uri.parse(
                            "https://transportes.factura-plataformakitdigital.com/api/apk.php");
                        final response = await http.post(uri, body: {
                          "tipo": tipo,
                          "numero": numero.toString(),
                          "idRegistro": idRegistro.toString(),
                        });

                        debugPrint("Manual STATUS: ${response.statusCode}");
                        debugPrint("Manual BODY: ${response.body}");

                        if (!context.mounted) return;

                        final data = jsonDecode(response.body);

                        if (response.statusCode == 200 &&
                            data is Map &&
                            data["success"] == true) {
                          if (data["completo"] == true) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                title: const Text("🎉 Pedido completo"),
                                content: Text(data["info"] ??
                                    "Todos los elementos fueron identificados."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _fetchConductorData();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                title: const Text("✅ Éxito"),
                                content: Text(data['message'] ??
                                    "Registro guardado correctamente."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _fetchConductorData();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                          }
                        } else {
                          final msg = (data is Map && data["error"] != null)
                              ? data["error"].toString()
                              : response.body;

                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              title: const Text("⚠️ Error"),
                              content: Text(msg),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cerrar"),
                                ),
                              ],
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            title: const Text("❌ Error inesperado"),
                            content: Text(e.toString()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cerrar"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Confirmar"),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Escanear")),
          body: MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.back,
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture) async {
              // 👇 Validación de seguridad
              if (capture.barcodes.isEmpty) return;

              final raw = capture.barcodes.first.rawValue ?? '';
              if (raw.isEmpty) return;

              debugPrint("📸 Código leído: $raw");
              if (!context.mounted) return;
              Navigator.pop(context);

              try {
                if (raw.length < 13) throw Exception("Código inválido");

                final idRegistro = int.tryParse(raw.substring(0, 10));
                final tipoDigit = raw.substring(10, 11);
                final numero = int.tryParse(raw.substring(11, 13));
                final tipo = (tipoDigit == "0") ? "palet" : "bulto";

                if (idRegistro == null || numero == null) {
                  throw Exception("Código malformado");
                }

                debugPrint("👉 Pedido escaneado: $idRegistro, Tipo: $tipo, Nº: $numero");

                final pedidoAsignado =
                int.tryParse(_pedido?['idRegistro'].toString() ?? '');
                if (pedidoAsignado == null || pedidoAsignado != idRegistro) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("⚠️ Pedido no asignado"),
                        content: Text(
                          "El código escaneado ($idRegistro) no corresponde a tu pedido asignado (${_pedido?['NroPedido']}).",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Aceptar"),
                          ),
                        ],
                      ),
                    );
                  }
                  return;
                }

                final uri = Uri.parse(
                    "https://transportes.factura-plataformakitdigital.com/api/apk.php");
                final response = await http.post(uri, body: {
                  "tipo": tipo,
                  "numero": numero.toString(),
                  "idRegistro": idRegistro.toString(),
                });

                debugPrint("STATUS: ${response.statusCode}");
                debugPrint("BODY: ${response.body}");

                if (!context.mounted) return;

                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  if (data is Map && data["success"] == true) {
                    if (data["completo"] == true) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("🎉 Pedido completo"),
                          content: Text(data["info"] ??
                              "Todos los elementos fueron identificados."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _fetchConductorData();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("✅ Éxito"),
                          content: Text(data['message'] ??
                              "Registro guardado correctamente."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _fetchConductorData();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    final msg = data["error"] ?? "Error desconocido";
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("⚠️ Error"),
                        content: Text(msg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  try {
                    final data = jsonDecode(response.body);
                    final msg = (data is Map && data['error'] != null)
                        ? data['error'].toString()
                        : response.body;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("❌ Error de servidor"),
                        content: Text(msg),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      ),
                    );
                  } catch (_) {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("❌ Error de servidor"),
                        content: Text(response.body),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("❌ Error inesperado"),
                      content: Text(e.toString()),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_conductor == null || _pedido == null) {
      return const Scaffold(
        body: Center(child: Text("No hay datos disponibles")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Identificar bultos / palets")),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📌 Card de datos del conductor con selector de pedidos
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Conductor: ${_conductor!['Nombre']}",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2.h),
                      Text("🚛 Empresa: ${_pedido!['NombreEmpresa'] ?? 'N/D'}"),
                      SizedBox(height: 3.h),
                      DropdownButtonFormField<Map<String, dynamic>>(
                        value: _pedido,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Pedidos asignados",
                        ),
                        items: _pedidos.map((p) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: p,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Pedido Nº ${p['NroPedido']}"),
                                const SizedBox(width: 10),
                                Text(
                                  p['Estado'] ?? 'Sin estado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: (p['Estado'] == 'Entregado')
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (nuevoPedido) {
                          setState(() {
                            _pedido = nuevoPedido;
                          });
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),

            // 📌 Card de entregas
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📦 Palets identificados",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "${_pedido!['TotalPaletsIdentificados']} / ${_pedido!['NroPalets']}"),
                      Text("${_pedido!['PaletsIdentificados'] ?? ''}"),
                      SizedBox(height: 1.h),
                      Text("📦 Bultos identificados",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "${_pedido!['TotalBultosIdentificados']} / ${_pedido!['NroBultos']}"),
                      Text("${_pedido!['BultosIdentificados'] ?? ''}"),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),

            // 📌 Botones bien distribuidos
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openScanner,
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Escanear"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openManualEntry,
                    label: const Text("Entrada manual"),
                    icon: const Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
