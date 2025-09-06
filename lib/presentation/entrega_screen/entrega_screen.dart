import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/conductor_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:signature/signature.dart';

class IncidenciaScreen extends StatefulWidget {
  final Map<String, dynamic> pedido;
  final Map<String, dynamic> conductor;

  const IncidenciaScreen(
      {super.key, required this.pedido, required this.conductor});

  @override
  State<IncidenciaScreen> createState() => _IncidenciaScreenState();
}

class _IncidenciaScreenState extends State<IncidenciaScreen> {
  final comentarioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _fotoBytes;

  int _fotoIndex = 1;

  Future<void> _capturarFoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      final bytes =
          await picked.readAsBytes(); // ✅ funciona en Web y Android/iOS
      setState(() {
        _fotoBytes = bytes;
      });
    }
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );
  }

  Future<void> _enviarIncidencia() async {
    if (_fotoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe capturar una foto")),
      );
      return;
    }

    final pos = await _getCurrentPosition();
    final uri = Uri.parse(
        "https://transportes.factura-plataformakitdigital.com/api/apk.php");

    var request = http.MultipartRequest("POST", uri);
    request.fields["modo"] = "incidencia";
    request.fields["idRegistro"] = widget.pedido['idRegistro'].toString();
    request.fields["NroPedido"] = widget.pedido['NroPedido'].toString();
    request.fields["NroEmpresa"] = widget.pedido['NroEmpresa'].toString();
    request.fields["Conductor"] = widget.conductor['Nombre'].toString();
    request.fields["Comentario"] = comentarioController.text;
    request.fields["latitud"] = pos.latitude.toString();
    request.fields["longitud"] = pos.longitude.toString();
    request.fields["nroFoto"] = _fotoIndex.toString();

// 👇 Diferencia: en Web no hay .path, se envía desde memoria
    request.files.add(
      http.MultipartFile.fromBytes(
        "foto",
        _fotoBytes!,
        filename: "foto_${DateTime.now().millisecondsSinceEpoch}.jpg",
        contentType: MediaType("image",
            "jpeg"), // necesitas importar: import 'package:http_parser/http_parser.dart';
      ),
    );

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    debugPrint("Incidencia STATUS: ${response.statusCode}");
    debugPrint("Incidencia BODY: $respStr");

    if (response.statusCode == 200) {
      setState(() {
        _fotoBytes = null;
        _fotoIndex++;
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("📌 Incidencia registrada"),
          content: Text("Se guardó correctamente la foto Nº $_fotoIndex"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedido = widget.pedido;

    return Scaffold(
      appBar: AppBar(title: const Text("Incidencias pedidos")),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Empresa: ${pedido['NombreEmpresa']}"),
            Text("N° Pedido: ${pedido['NroPedido']}"),
            SizedBox(height: 2.h),
            TextField(
              controller: comentarioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Comentario",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: _fotoBytes == null
                      ? const Center(
                          child: Text("FOTO", style: TextStyle(fontSize: 30)))
                      : Image.memory(_fotoBytes!, fit: BoxFit.cover)),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _capturarFoto,
                  child: const Text("Capturar foto"),
                ),
                ElevatedButton(
                  onPressed: _enviarIncidencia,
                  child: const Text("Siguiente foto"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Salir"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class EntregaScreen extends StatefulWidget {
  final Map<String, dynamic>? pedidoInicial;

  const EntregaScreen({super.key, this.pedidoInicial});

  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

Future<bool> abrirDialogoFirma(BuildContext context, Map pedido) async {
  final SignatureController controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final String? firmaUrl = pedido['Firma'];
  bool mostrarPad = (firmaUrl == null || firmaUrl.isEmpty);

  return await showDialog<bool>(
        context: context,
        builder: (_) => StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8), // 👈 menos borde redondeado
              ),
              title: const Text("Firma Cliente"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Empresa: ${pedido['NombreEmpresa']}"),
                      Text("N° Pedido: ${pedido['NroPedido']}"),
                      const SizedBox(height: 10),
                      if (!mostrarPad && firmaUrl != null) ...[
                        const Text("Firma actual:"),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: Image.network(firmaUrl, fit: BoxFit.contain),
                        ),
                      ],
                      if (mostrarPad) ...[
                        const SizedBox(height: 20),
                        const Text("Nueva firma:"),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          width: double.infinity,
                          child: Container(
                            color: Colors.grey.shade200,
                            child: Signature(
                              controller: controller,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              actions: [
                if (!mostrarPad && firmaUrl != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        mostrarPad = true;
                      });
                    },
                    child: const Text("Borrar firma"),
                  ),
                if (mostrarPad)
                  TextButton(
                    onPressed: () => controller.clear(),
                    child: const Text("Limpiar"),
                  ),
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(
                        "https://transportes.factura-plataformakitdigital.com/api/apk.php");
                    var request = http.MultipartRequest("POST", uri);

                    request.fields["modo"] = "guardar_firma";
                    request.fields["idRegistro"] =
                        pedido['idRegistro'].toString();

                    if (mostrarPad && controller.isNotEmpty) {
                      final bytes = await controller.toPngBytes();
                      if (bytes != null) {
                        request.files.add(
                          http.MultipartFile.fromBytes(
                            "firma",
                            bytes,
                            filename:
                                "firma_${DateTime.now().millisecondsSinceEpoch}.png",
                            contentType: MediaType("image", "png"),
                          ),
                        );
                      }
                    } else if (mostrarPad && controller.isEmpty) {
                      request.fields["firma_empty"] = "1";
                    }

                    final response = await request.send();
                    final respStr = await response.stream.bytesToString();
                    debugPrint("RESP FIRMA: $respStr");

                    if (response.statusCode == 200) {
                      Navigator.pop(
                          context, true); // ✅ avisamos que hubo cambios
                    }
                  },
                  child: const Text("Guardar"),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false), // ❌ no hubo cambios
                  child: const Text("Salir"),
                ),
              ],
            );
          },
        ),
      ) ??
      false;
}

class _EntregaScreenState extends State<EntregaScreen> {
  Map<String, dynamic>? _conductor;
  List<dynamic> _pedidos = [];
  Map<String, dynamic>? _pedido;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _pedido = widget.pedidoInicial;
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

  Future<void> _registrarEntrega(
      String tipo, int numero, int idRegistro) async {
    try {
      final uri = Uri.parse(
          "https://transportes.factura-plataformakitdigital.com/api/apk.php");
      final response = await http.post(uri, body: {
        "tipo": tipo,
        "numero": numero.toString(),
        "idRegistro": idRegistro.toString(),
        "modo": "entrega",
      });

      debugPrint("Entrega STATUS: ${response.statusCode}");
      debugPrint("Entrega BODY: ${response.body}");

      if (!context.mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data is Map &&
          data["success"] == true) {
        if (data["completo"] == true) {
          final pos = await _getCurrentPosition();

          // 📌 Mostrar popup de firma
          final actualizado = await abrirDialogoFirma(context, _pedido!);

          if (actualizado == true) {
            // 🔄 Refrescamos los datos de conductor/pedido
            await _fetchConductorData();

            // (opcional) podés también mandar coordenadas si hace falta
            final uriCoords = Uri.parse(
                "https://transportes.factura-plataformakitdigital.com/api/apk.php");
            var request = http.MultipartRequest("POST", uriCoords);

            request.fields["idRegistro"] = idRegistro.toString();
            request.fields["modo"] = "finalizar_entrega";
            request.fields["latitud"] = pos.latitude.toString();
            request.fields["longitud"] = pos.longitude.toString();

            final resp = await request.send();
            final respStr = await resp.stream.bytesToString();
            debugPrint("Finalizar entrega: $respStr");
          }

          // Confirmación final
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("🎉 Pedido entregado"),
              content: const Text(
                  "Se registró la entrega y la firma correctamente."),
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
          // ✅ Entrega parcial
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("✅ Entrega registrada"),
              content: Text(data['message'] ?? "Entrega guardada"),
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

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    );
  }

  void _openManualEntryEntrega() {
    final numeroController = TextEditingController();
    String tipo = "palet";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // 👈 menos borde redondeado
          ),
          title: const Text("Entrada manual de entrega"),
          contentPadding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    onPressed: () {
                      final idRegistro =
                          int.tryParse(_pedido?['idRegistro'].toString() ?? '');

                      final numero = int.tryParse(numeroController.text);

                      if (idRegistro == null || numero == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Datos inválidos")),
                        );
                        return;
                      }

                      Navigator.pop(context);
                      _registrarEntrega(tipo, numero, idRegistro);
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

  void _abrirFormularioIncidencia() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IncidenciaScreen(
          pedido: _pedido!,
          conductor: _conductor!,
        ),
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Escanear Entrega")),
          body: MobileScanner(
            controller: MobileScannerController(
              facing: CameraFacing.back,
              detectionSpeed: DetectionSpeed.noDuplicates,
            ),
            onDetect: (capture) async {
              if (capture.barcodes.isEmpty) return; // 👈 evita Bad state
              final barcode = capture.barcodes.first;
              final raw = barcode.rawValue ?? '';

              if (raw.isEmpty) return; // 👈 evita null o string vacío

              debugPrint("📸 Código leído: $raw");
              if (!context.mounted) return;
              Navigator.pop(context);

              if (raw.length < 13) {
                debugPrint("⚠️ Código inválido: demasiado corto");
                return;
              }

              final idRegistro = int.tryParse(raw.substring(0, 10));
              final tipoDigit = raw.substring(10, 11);
              final numero = int.tryParse(raw.substring(11, 13));
              final tipo = (tipoDigit == "0") ? "palet" : "bulto";

              if (idRegistro == null || numero == null) {
                debugPrint("⚠️ Código inválido: no se pudo parsear");
                return;
              }

              final pedidoAsignado =
                  int.tryParse(_pedido?['idRegistro'].toString() ?? '');
              if (pedidoAsignado == null || pedidoAsignado != idRegistro) {
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("⚠️ Pedido no asignado"),
                      content: Text(
                        "El código escaneado ($idRegistro) no corresponde a tu pedido (${_pedido?['NroPedido']}).",
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

              _registrarEntrega(tipo, numero, idRegistro);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_conductor == null || _pedido == null) {
      return const Scaffold(
          body: Center(child: Text("No hay datos disponibles")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Entregar pedido")),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
            SizedBox(height: 2.h),

            // 📌 Card de entregas
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("📦 Palets entregados",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "${_pedido!['TotalPaletsEntregados']} / ${_pedido!['NroPalets']}"),
                      Text("${_pedido!['PaletsEntregados'] ?? ''}"),
                      SizedBox(height: 1.h),
                      Text("📦 Bultos entregados",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                          "${_pedido!['TotalBultosEntregados']} / ${_pedido!['NroBultos']}"),
                      Text("${_pedido!['BultosEntregados'] ?? ''}"),
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
                    onPressed: _openManualEntryEntrega,
                    label: const Text("Entrada manual"),
                    icon: const Icon(Icons.report_problem, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _abrirFormularioIncidencia,
                    icon: const Icon(Icons.report_problem, color: Colors.white),
                    label: const Text("Incidencia"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                if (_pedido!['Estado'] == 'Entregado')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final actualizado =
                            await abrirDialogoFirma(context, _pedido!);
                        if (actualizado == true) {
                          _fetchConductorData();
                        }
                      },
                      icon: const Icon(Icons.border_color),
                      label: const Text("Firmar"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
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
