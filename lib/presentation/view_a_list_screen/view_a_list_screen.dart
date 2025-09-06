import 'package:web/web.dart' as web;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/pedido_item_card.dart';
import './widgets/empty_state_widget.dart';
import './widgets/loading_skeleton.dart';
import './widgets/search_filter_bar.dart';
import '../../services/conductor_service.dart';
import '../entrega_screen/entrega_screen.dart';
import '../scanner_screen/scanner_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' show Platform; // para Android/iOS
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ViewAListScreen extends StatefulWidget {
  const ViewAListScreen({super.key});

  @override
  State<ViewAListScreen> createState() => _ViewAListScreenState();
}

class _ViewAListScreenState extends State<ViewAListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Map<String, dynamic>? _conductor;
  List<dynamic> _pedidos = [];
  Map<String, dynamic>? _pedido;

  bool _loading = true;
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  List<dynamic> _filteredPedidos = [];
  void _onIdentificar(Map<String, dynamic> pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerScreen(pedidoInicial: pedido),
      ),
    );
  }

  void _verFoto(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(10),
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    try {
      if (kIsWeb) {
        // 👉 Versión Web usando package:web
        final anchor = web.HTMLAnchorElement();
        anchor.href = url;
        anchor.download = url.split('/').last;
        anchor.target = "_blank";
        anchor.click();
        return;
      }

      // 👉 Versión Android/iOS
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last.split('?').first;
      final filePath = "${dir.path}/$fileName";

      await Dio().download(url, filePath);

      print("✅ Foto descargada en: $filePath");
    } catch (e) {
      print("❌ Error al descargar: $e");
    }
  }

  Future<void> _deleteFile(String url, Map<String, dynamic> pedido) async {
    try {
      final filename = url.split('/').last.split('?').first;

      final response = await http.post(
        Uri.parse(
            "https://transportes.factura-plataformakitdigital.com/api/apk.php"),
        body: {
          "modo": "eliminar_foto",
          "idRegistro": pedido["idRegistro"].toString(),
          "filename": filename,
        },
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        debugPrint("✅ Foto eliminada: $filename");
        // refrescá la lista
      } else {
        debugPrint("❌ Error al eliminar: ${data['error']}");
      }
    } catch (e) {
      debugPrint("❌ Error al eliminar: $e");
    }
  }

  Future<void> _onFotos(Map<String, dynamic> pedido) async {
    final ImagePicker picker = ImagePicker();

    // 👉 1. Traer fotos existentes
    List<String> fotosExistentes = [];
    try {
      final response = await http.post(
        Uri.parse(
            "https://transportes.factura-plataformakitdigital.com/api/apk.php"),
        body: {
          "modo": "obtener_fotos",
          "idRegistro": pedido["idRegistro"].toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: ${response.body}');
        if (data['success'] == true) {
          fotosExistentes = List<String>.from(data['fotos']);
        }
      }
    } catch (e) {
      debugPrint("❌ Error al traer fotos: $e");
    }

    // 👉 2. Mostrar diálogo
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Fotos del pedido"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grid con fotos existentes
                fotosExistentes.isNotEmpty
                    ? Expanded(
                        child: GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: fotosExistentes.length,
                          itemBuilder: (context, index) {
                            final url =
                                "${fotosExistentes[index]}?v=${DateTime.now().millisecondsSinceEpoch}";

                            return GestureDetector(
                              /*  onTap: () => _abrirGaleria(
                                  context, index, fotosExistentes),*/
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 200),
                                    ),
                                  ),

                                  // 🔘 Overlay con botones
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.download,
                                              color: Colors.green),
                                          onPressed: () => _downloadFile(
                                              fotosExistentes[index]),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            await _deleteFile(
                                                fotosExistentes[index], pedido);
                                            setState(() {
                                              fotosExistentes.removeAt(
                                                  index); // quita de la lista local
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.visibility,
                                              color: Colors.blueAccent),
                                          onPressed: () => _verFoto(
                                              context, fotosExistentes[index]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No hay fotos cargadas."),
                      ),
              ],
            ),
          ),
          actions: [
            // 👉 Cámara
            TextButton(
              child: const Text("Abrir cámara"),
              onPressed: () async {
                final XFile? photo =
                    await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  try {
                    final urls = await _uploadFile(
                        photo, pedido, "Foto tomada con cámara");
                    debugPrint('urls: ${urls}');
                    setState(() {
                      fotosExistentes
                          .addAll(urls); // 👉 ya viene la URL real del server
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Foto de cámara subida")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
            ),

            // 👉 Galería múltiple
            TextButton(
              child: const Text("Seleccionar fotos"),
              onPressed: () async {
                final List<XFile> images = await picker.pickMultiImage();
                if (images.isNotEmpty) {
                  for (final img in images) {
                    try {
                      final urls = await _uploadFile(
                          img, pedido, "Foto subida desde galería");
                      setState(() {
                        fotosExistentes.addAll(urls);
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${images.length} fotos subidas")),
                  );
                }
              },
            ),

            TextButton(
              child: const Text("Cerrar"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 👉 Función auxiliar para subir un archivo
  Future<List<String>> _uploadFile(
    XFile file,
    Map<String, dynamic> pedido,
    String comentario,
  ) async {
    final uri = Uri.parse(
      "https://transportes.factura-plataformakitdigital.com/api/apk.php",
    );

    final request = http.MultipartRequest("POST", uri)
      ..fields['modo'] = 'subir_fotos'
      ..fields['idRegistro'] = pedido["idRegistro"].toString()
      ..fields['Comentario'] = comentario
      ..files.add(await http.MultipartFile.fromPath('foto[]', file.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();

    final data = json.decode(body);

    if (data["success"] == true) {
      // 🔥 Devuelvo la lista de URLs reales
      return List<String>.from(data["uploaded"]);
    } else {
      throw Exception(data["error"] ?? "Error al subir la foto");
    }
  }

  Future<void> _onIncidencias(Map<String, dynamic> pedido) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://transportes.factura-plataformakitdigital.com/api/apk.php"),
        body: {
          "modo": "obtener_incidencias",
          "idRegistro": pedido["idRegistro"].toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final incidencias = data['incidencias'] as List<dynamic>;

          if (incidencias.isEmpty) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Incidencias"),
                content: const Text("No hay incidencias registradas."),
                actions: [
                  TextButton(
                    child: const Text("Cerrar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Incidencias"),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: incidencias.length,
                    itemBuilder: (context, index) {
                      final inc = incidencias[index];
                      final comentario = inc['Comentario'] ?? '';
                      final fecha = inc['FechaHoraCreacion'] ?? '';
                      final foto = (inc['LinkFoto'] != null)
                          ? 'https://transportes.factura-plataformakitdigital.com/api/${inc['LinkFoto']}'
                          : '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto arriba ocupando todo el ancho
                            if (foto.isNotEmpty)
                              Image.network(
                                foto,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    size: 50),
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.grey.shade300,
                                child:
                                    const Icon(Icons.report_problem, size: 50),
                              ),

                            // Texto debajo
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comentario.isNotEmpty
                                        ? comentario
                                        : "Sin comentario",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    fecha,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Cerrar"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${data['error']}")),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error en incidencias: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _onEntregar(Map<String, dynamic> pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EntregaScreen(pedidoInicial: pedido),
      ),
    );
  }

/*
  void _abrirGaleria(BuildContext context, int index, List<String> fotos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: fotos.length,
                pageController: PageController(initialPage: index),
                builder: (context, i) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(fotos[i]),
                    // minScale: PhotoViewComputedScale.contained,
                    // maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),

              // Botón cerrar arriba a la izquierda
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
*/
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchConductorData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Si más adelante querés paginar, podés enganchar acá
  }

  Future<void> _fetchConductorData() async {
    try {
      final data = await ConductorService.getPedidosConductor();
      if (data != null && data['user'] != null) {
        final pedidos = data['user']['pedidos'] as List<dynamic>? ?? [];
        if (!mounted) return;
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
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint("❌ Error: $e");
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchConductorData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pedidos actualizados correctamente'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _applyFilters() {
    List<dynamic> filtered = List.from(_pedidos);

    // 👉 Filtro por estado
    if (_selectedFilter != 'Todos') {
      filtered = filtered
          .where((pedido) =>
              (pedido['Estado'] as String? ?? '').toLowerCase() ==
              _selectedFilter.toLowerCase())
          .toList();
    }

    // 👉 Búsqueda
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((pedido) {
        final nroPedido = (pedido['NroPedido'] as String? ?? '').toLowerCase();
        final empresa =
            (pedido['NombreEmpresa'] as String? ?? '').toLowerCase();
        final conductor = (pedido['Conductor'] as String? ?? '').toLowerCase();

        return nroPedido.contains(query) ||
            empresa.contains(query) ||
            conductor.contains(query);
      }).toList();
    }
    if (!mounted) return;
    setState(() {
      _filteredPedidos = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
    });
    _applyFilters();
  }

  void _onItemTap(Map<String, dynamic> pedido) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viendo detalles del pedido #${pedido['idRegistro']}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAddNewPedido() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad para agregar pedido próximamente'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pedidos',
      ),
      body: Column(
        children: [
          SearchFilterBar(
            searchQuery: _searchQuery,
            selectedFilter: _selectedFilter,
            onSearchChanged: _onSearchChanged,
            onFilterChanged: _onFilterChanged,
            onClearSearch: _onClearSearch,
          ),
          Expanded(
            child: _loading
                ? const LoadingSkeleton()
                : _filteredPedidos.isEmpty
                    ? EmptyStateWidget(
                        title: _searchQuery.isNotEmpty ||
                                _selectedFilter != 'Todos'
                            ? 'No se encontraron pedidos'
                            : 'No hay pedidos disponibles',
                        description: _searchQuery.isNotEmpty ||
                                _selectedFilter != 'Todos'
                            ? 'Probá ajustando tu búsqueda o filtros'
                            : 'Agregá tu primer pedido para empezar',
                        buttonText: 'Agregar Pedido',
                        onButtonPressed: _onAddNewPedido,
                        iconName: _searchQuery.isNotEmpty ||
                                _selectedFilter != 'Todos'
                            ? 'search_off'
                            : 'inbox',
                      )
                    : RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: _onRefresh,
                        color: colorScheme.primary,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.only(bottom: 10.h),
                          itemCount: _filteredPedidos.length,
                          itemBuilder: (context, index) {
                            final pedido = _filteredPedidos[index];
                            return Slidable(
                              key: ValueKey(pedido['idRegistro']),
                              startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        _onIdentificar(pedido),
                                    backgroundColor: colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.qr_code_scanner,
                                    label: 'Identificar',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) => _onEntregar(pedido),
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.check_circle,
                                    label: 'Entregar',
                                  ),
                                ],
                              ),
                              child: PedidoItemCard(
                                pedido: pedido,
                                onTap: () => _onItemTap(pedido),
                                onIdentificar: () => _onIdentificar(pedido),
                                onEntregar: () => _onEntregar(pedido),
                                onIncidencias: () => _onIncidencias(pedido),
                                onFotos: () => _onFotos(pedido),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
