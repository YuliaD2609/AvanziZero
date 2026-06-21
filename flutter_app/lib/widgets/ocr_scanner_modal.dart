import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_state.dart';
import '../services/ai_scanner_service.dart';
import '../theme/app_colors.dart';

/// Modale avanzato per l'acquisizione di scontrini tramite Intelligenza Artificiale.
/// Integra l'accesso nativo all'hardware del dispositivo (Fotocamera e Galleria)
/// tramite il pacchetto ufficiale [image_picker], predisponendo l'immagine
/// per l'invio al backend di inferenza OCR e classificazione LLM.
class OcrScannerModal extends StatefulWidget {
  final AppState state;
  const OcrScannerModal({super.key, required this.state});

  @override
  State<OcrScannerModal> createState() => _OcrScannerModalState();

  static void show(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OcrScannerModal(state: state),
    );
  }
}

class _OcrScannerModalState extends State<OcrScannerModal> {
  File? _capturedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  /// Avvia l'acquisizione di un'immagine nativa dalla sorgente desiderata
  Future<void> _captureImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85, // Compressione ottimale per OCR via rete
        maxWidth: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _capturedImage = File(pickedFile.path);
          // Rimosso finto caricamento qui. Lo spostiamo sul pulsante di invio.
        });
      }
    } catch (e) {
      print("Errore nell'acquisizione dell'immagine: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Impossibile accedere alla sorgente: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Barra superiore di trascinamento
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Intestazione Modale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.document_scanner_rounded,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      "IA Scanning Scontrini",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon:
                      Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),

          // Contenuto Principale
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Area Anteprima Fotocamera / Scontrino Reale
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background, // Avorio soft
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _capturedImage != null
                            ? AppColors.primary
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _capturedImage != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  _capturedImage!,
                                  fit: BoxFit.cover,
                                ),
                                // Overlay scuro durante l'analisi
                                if (_isAnalyzing)
                                  Container(
                                    color: Colors.black.withOpacity(0.6),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                            color: AppColors.primary),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Estrazione OCR ed Elaborazione LLM...",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Outfit',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    color: AppColors.textSecondary, size: 54),
                                const SizedBox(height: 12),
                                Text(
                                  "Nessuno scontrino inquadrato",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Usa i pulsanti in basso per scattare",
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Descrizione e coerenza con il feedback utente sul modello
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight, // Menta chiaro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: AppColors.textPrimary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "L'immagine acquisita permetterà di riconoscere gli elementi acquistati e inserirli automaticamente in dispensa.",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Pulsanti di Azione
                  if (_capturedImage == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _captureImage(ImageSource.gallery),
                            icon: Icon(Icons.photo_library_rounded,
                                color: AppColors.primary),
                            label: Text(
                              "Galleria",
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                  color: AppColors.primary, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () => _captureImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_rounded,
                                color: Colors.white),
                            label: Text(
                              "Scatta Foto",
                              style: TextStyle(
                                  fontFamily: 'Outfit',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary, // Verde Salvia Intenso
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        IconButton(
                          onPressed: _isAnalyzing
                              ? null
                              : () {
                                  setState(() {
                                    _capturedImage = null;
                                  });
                                },
                          icon: Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isAnalyzing
                                ? null
                                : () async {
                                    setState(() {
                                      _isAnalyzing = true;
                                    });
                                    try {
                                      final items =
                                          await AIScannerService.scanReceipt(
                                              XFile(_capturedImage!.path));
                                      if (context.mounted) {
                                        // Passiamo la lista di prodotti indietro al chiamante
                                        Navigator.pop(context, items);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        setState(() {
                                          _isAnalyzing = false;
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text("Errore: $e"),
                                            backgroundColor: AppColors.error,
                                            duration:
                                                const Duration(seconds: 5),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors
                                  .primaryDark, // Accento Verde Scuro/Teal
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              "Inserisci elementi dallo scontrino",
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
