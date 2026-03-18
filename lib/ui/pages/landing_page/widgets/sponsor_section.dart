import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart'; 

class SponsorSection extends StatelessWidget {
  const SponsorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF1DAC1),
      constraints: BoxConstraints(minHeight: isMobile ? 0 : screenWidth * (210 / 1440)),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 40 : 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- TEXTO 1: TÍTULO ---
          Text(
            '¿Quieres patrocinar Pizzathon?',
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              fontWeight: FontWeight.w900, 
              fontSize: 24,
              height: 26 / 24, 
              letterSpacing: 0.15,
              color: const Color(0xFF7E4F15), 
            ),
          ),
          
          const SizedBox(height: 10), 
          
          // --- TEXTO 2: SUBTÍTULO (Lo he recuperado) ---
          Text(
            'Un evento único donde mostrar\ntu producto',
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              fontWeight: FontWeight.w400, 
              fontSize: 16,
              height: 20 / 16, 
              letterSpacing: 0.15,
              color: const Color(0xFF7E4F15), 
            ),
          ),
          
          const SizedBox(height: 30),
          
          // --- TEXTO 3: BOTÓN ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onPressed: () => _showContactDialog(context),
            child: Text(
              'Me interesa', 
              style: GoogleFonts.archivoBlack(
                fontWeight: FontWeight.w400,
                fontSize: 16, 
                height: 24 / 16,
                letterSpacing: 0.15, 
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Contacto para Patrocinadores', 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: colorScheme.secondary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Escríbenos directamente a esta dirección:', 
                style: TextStyle(color: Colors.black87), 
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.5), 
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        'salvapizzalover@gmail.com', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: colorScheme.primary, 
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, color: colorScheme.primary), 
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'salvapizzalover@gmail.com')).then((_) {
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                '¡Correo copiado!', 
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ), 
                              backgroundColor: colorScheme.secondary, 
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}