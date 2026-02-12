import 'package:flutter/material.dart';

enum FieldType { text, multiline, date, image, toggle }

class FieldConfig {
  final String name; // Database field ID
  final String label; // UI Label
  final FieldType type;
  final bool required;

  const FieldConfig({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
  });
}

class AdminModule {
  final String id;
  final String title;
  final IconData icon;
  final String collectionPath; // Firestore collection
  final List<FieldConfig> fields;

  const AdminModule({
    required this.id,
    required this.title,
    required this.icon,
    required this.collectionPath,
    required this.fields,
  });
}

class MetadataRegistry {
  static final MetadataRegistry _instance = MetadataRegistry._internal();
  factory MetadataRegistry() => _instance;
  MetadataRegistry._internal();

  final List<AdminModule> _modules = [];

  List<AdminModule> get modules => List.unmodifiable(_modules);

  void register(AdminModule module) {
    _modules.add(module);
  }

  // Pre-register default modules
  void initializeDefaults() {
    _modules.clear();
    register(const AdminModule(
      id: 'anuncios',
      title: 'Anuncios',
      icon: Icons.campaign,
      collectionPath: 'announcements',
      fields: [
        FieldConfig(
            name: 'title',
            label: 'Título',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'description',
            label: 'Descripción',
            type: FieldType.multiline),
        FieldConfig(name: 'date', label: 'Fecha', type: FieldType.date),
        FieldConfig(
            name: 'imageUrl',
            label: 'Imagen de Cabecera',
            type: FieldType.image),
      ],
    ));

    register(const AdminModule(
      id: 'actividades',
      title: 'Actividades',
      icon: Icons.calendar_month,
      collectionPath: 'activities',
      fields: [
        FieldConfig(
            name: 'title',
            label: 'Nombre Actividad',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'description', label: 'Detalles', type: FieldType.multiline),
        FieldConfig(
            name: 'startDate',
            label: 'Inicio (Fecha/Hora)',
            type: FieldType.date,
            required: true),
        FieldConfig(
            name: 'endDate',
            label: 'Fin (Fecha/Hora)',
            type: FieldType.date,
            required: true),
        FieldConfig(name: 'location', label: 'Lugar', type: FieldType.text),
      ],
    ));

    register(const AdminModule(
      id: 'info',
      title: 'Quiénes Somos',
      icon: Icons.info,
      collectionPath: 'about_us',
      fields: [
        FieldConfig(
            name: 'content',
            label: 'Descripción General',
            type: FieldType.multiline,
            required: true),
        FieldConfig(
            name: 'pastorName',
            label: 'Nombre del Pastor',
            type: FieldType.text),
        FieldConfig(
            name: 'pastorBio',
            label: 'Biografía del Pastor',
            type: FieldType.multiline),
        FieldConfig(
            name: 'pastorImageUrl',
            label: 'URL Foto del Pastor',
            type: FieldType.text),
        FieldConfig(
            name: 'churchImageUrl',
            label: 'URL Foto de la Iglesia',
            type: FieldType.text),
        FieldConfig(name: 'address', label: 'Dirección', type: FieldType.text),
        FieldConfig(
            name: 'facebookUrl', label: 'URL Facebook', type: FieldType.text),
        FieldConfig(
            name: 'youtubeUrl', label: 'URL YouTube', type: FieldType.text),
      ],
    ));

    register(const AdminModule(
      id: 'sermones',
      title: 'Sermones',
      icon: Icons.podcasts,
      collectionPath: 'podcasts',
      fields: [
        FieldConfig(
            name: 'title',
            label: 'Título',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'speaker',
            label: 'Predicador',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'description',
            label: 'Descripción',
            type: FieldType.multiline),
        FieldConfig(
            name: 'audioUrl',
            label: 'URL del Audio',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'date', label: 'Fecha', type: FieldType.date, required: true),
      ],
    ));

    register(const AdminModule(
      id: 'oracion',
      title: 'Pedidos de Oración',
      icon: Icons.volunteer_activism,
      collectionPath: 'prayer_requests',
      fields: [
        FieldConfig(
            name: 'senderName',
            label: 'Nombre',
            type: FieldType.text,
            required: true),
        FieldConfig(
            name: 'content',
            label: 'Pedido',
            type: FieldType.multiline,
            required: true),
        FieldConfig(name: 'date', label: 'Fecha', type: FieldType.date),
        FieldConfig(name: 'isRead', label: 'Leído', type: FieldType.toggle),
      ],
    ));
  }
}
