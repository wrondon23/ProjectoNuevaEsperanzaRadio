import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'metadata_registry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class CrudFormView extends StatefulWidget {
  final AdminModule module;
  final String? documentId; // If null, creating new. If set, editing.
  final Map<String, dynamic>? initialData;

  const CrudFormView(
      {super.key, required this.module, this.documentId, this.initialData});

  @override
  State<CrudFormView> createState() => _CrudFormViewState();
}

class _CrudFormViewState extends State<CrudFormView> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _formData.addAll(widget.initialData!);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final collection =
          FirebaseFirestore.instance.collection(widget.module.collectionPath);

      if (widget.documentId == null) {
        // Create
        await collection.add(_formData);
      } else {
        // Update
        await collection.doc(widget.documentId).update(_formData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guardado exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentId == null
            ? 'Crear ${widget.module.title}'
            : 'Editar ${widget.module.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...widget.module.fields.map(_buildField),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar",
                        style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldConfig field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field.label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 5),
          _buildInputWidget(field),
        ],
      ),
    );
  }

  Widget _buildInputWidget(FieldConfig field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.multiline:
        return TextFormField(
          initialValue: _formData[field.name]?.toString(),
          maxLines: field.type == FieldType.multiline ? 4 : 1,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade800),
            ),
            filled: true,
            fillColor: AppColors.drawerBackground,
            hintText: 'Ingrese ${field.label.toLowerCase()}',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
          ),
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return 'Este campo es obligatorio';
            }
            return null;
          },
          onSaved: (value) => _formData[field.name] = value,
        );

      case FieldType.date:
        // Date + Time Picker Trigger
        return FormField<DateTime>(
          initialValue: _formData[field.name] is Timestamp
              ? (_formData[field.name] as Timestamp).toDate()
              : null,
          validator: (value) {
            if (field.required && value == null) return 'Seleccione una fecha';
            return null;
          },
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final initial = state.value ?? DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      if (context.mounted) {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(initial),
                        );

                        if (pickedTime != null) {
                          final combined = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          state.didChange(combined);
                          _formData[field.name] = Timestamp.fromDate(combined);
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    state.value == null
                        ? 'Seleccionar Fecha y Hora'
                        : DateFormat('yyyy-MM-dd hh:mm a').format(state.value!),
                  ),
                ),
                if (state.hasError)
                  Text(state.errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            );
          },
        );

      case FieldType.image:
        return FormField<String>(
          initialValue: _formData[field.name]?.toString(),
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.value != null && state.value!.isNotEmpty)
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(state.value!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          state.didChange(null);
                          _formData[field.name] = null;
                        },
                        icon: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.drawerBackground,
                      border: Border.all(color: Colors.grey.shade800),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey.shade600),
                          const SizedBox(height: 10),
                          Text(
                            "Subir Imagen",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1024,
                      imageQuality: 80,
                    );

                    if (image != null) {
                      // Upload Logic
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Subiendo imagen...')),
                        );

                        final Uint8List fileBytes = await image.readAsBytes();
                        final String uuid = const Uuid().v4();
                        final String path =
                            'uploads/$uuid.${image.name.split('.').last}';
                        final Reference ref =
                            FirebaseStorage.instance.ref().child(path);

                        final metadata = SettableMetadata(
                          customMetadata: {'picked-file-path': image.path},
                        );

                        // Timeout logic for upload
                        final UploadTask uploadTask =
                            ref.putData(fileBytes, metadata);
                        final TaskSnapshot snapshot = await uploadTask.timeout(
                            const Duration(seconds: 120), onTimeout: () {
                          uploadTask.cancel();
                          throw Exception("La subida tardó demasiado.");
                        });

                        final String downloadUrl =
                            await snapshot.ref.getDownloadURL();

                        state.didChange(downloadUrl);
                        _formData[field.name] = downloadUrl;

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al subir: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text("Seleccionar Imagen"),
                ),
              ],
            );
          },
        );

      default:
        return const Text("Tipo de campo no soportado");
    }
  }
}
