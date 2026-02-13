import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/data/models/app_config_model.dart';
import 'package:radio_nueva_esperanza/data/repositories/data_repository.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = DataRepository();
  bool _isLoading = true;
  bool _isSaving = false;

  late AppConfigModel _config;

  // Controllers
  final _streamUrlController = TextEditingController();
  final _stationNameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _facebookController = TextEditingController();
  final _youtubeController = TextEditingController();

  Map<String, bool> _activeSections = {};

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    setState(() => _isLoading = true);
    try {
      _config = await _repository.getAppConfig();
      _streamUrlController.text = _config.streamUrl;
      _stationNameController.text = _config.stationName;
      _whatsappController.text = _config.whatsappNumber;
      _facebookController.text = _config.facebookUrl;
      _youtubeController.text = _config.youtubeUrl;
      _activeSections = Map.from(_config.activeSections);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la configuración: $e')),
      );
      _config = AppConfigModel();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newConfig = _config.copyWith(
        streamUrl: _streamUrlController.text,
        stationName: _stationNameController.text,
        whatsappNumber: _whatsappController.text,
        facebookUrl: _facebookController.text,
        youtubeUrl: _youtubeController.text,
        activeSections: _activeSections,
      );

      await _repository.saveAppConfig(newConfig);
      _config = newConfig;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Configuración guardada correctamente'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _streamUrlController.dispose();
    _stationNameController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Background handled by shell
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveConfig,
        label: _isSaving
            ? const Text('Guardando...')
            : const Text('Guardar Cambios'),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.save),
        backgroundColor: const Color(0xFF142F30), // Dark Teal
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Información General'),
              _buildCard([
                _buildTextField('Nombre de la Estación', _stationNameController,
                    icon: Icons.radio),
                const SizedBox(height: 16),
                _buildTextField('URL del Streaming', _streamUrlController,
                    icon: Icons.link, hint: 'https://stream.zeno.fm/tu-stream'),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('Redes Sociales y Contacto'),
              _buildCard([
                _buildTextField('WhatsApp', _whatsappController,
                    icon: Icons.phone, hint: '+1234567890'),
                const SizedBox(height: 16),
                _buildTextField('Facebook URL', _facebookController,
                    icon: Icons.facebook),
                const SizedBox(height: 16),
                _buildTextField('YouTube URL', _youtubeController,
                    icon: Icons.video_library),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader('Sistema'),
              _buildCard([
                SwitchListTile(
                  title: const Text('Modo Mantenimiento',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                      'Si activas esto, la app mostrará una pantalla de mantenimiento a los usuarios.',
                      style: TextStyle(color: Colors.white70)),
                  value: _config.isMaintenanceMode,
                  activeThumbColor: Colors.red,
                  onChanged: (val) {
                    setState(() {
                      _config = _config.copyWith(isMaintenanceMode: val);
                    });
                  },
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Secciones Activas',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                CheckboxListTile(
                  title: const Text('Anuncios',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['announcements'] ?? true,
                  onChanged: (val) => setState(
                      () => _activeSections['announcements'] = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Actividades',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['activities'] ?? true,
                  onChanged: (val) => setState(
                      () => _activeSections['activities'] = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Sermones (Podcasts)',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['podcasts'] ?? true,
                  onChanged: (val) =>
                      setState(() => _activeSections['podcasts'] = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Pedidos de Oración',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['prayer_requests'] ?? true,
                  onChanged: (val) => setState(
                      () => _activeSections['prayer_requests'] = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Quiénes Somos',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['about'] ?? true,
                  onChanged: (val) =>
                      setState(() => _activeSections['about'] = val ?? true),
                ),
                CheckboxListTile(
                  title: const Text('Palabra Diaria (Versículo)',
                      style: TextStyle(color: Colors.white)),
                  value: _activeSections['daily_verse'] ?? true,
                  onChanged: (val) => setState(
                      () => _activeSections['daily_verse'] = val ?? true),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White Text
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground, // Dark Card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, String? hint}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // White Input Text
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9F8250))
            : null, // Gold Icon
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: AppColors.drawerBackground, // Darker Input Background
      ),
    );
  }
}
