import 'package:flutter/material.dart';

class OfflineDialog extends StatelessWidget {
  final VoidCallback? onContinuarOffline;
  final VoidCallback? onTentarNovamente;
  final bool isLoading;

  const OfflineDialog({
    super.key,
    this.onContinuarOffline,
    this.onTentarNovamente,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('Backend Indisponível'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Não foi possível conectar ao servidor. Você pode:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text(
            '• Continuar offline e visualizar seus treinos salvos',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Tentar novamente para conectar ao servidor',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        if (onTentarNovamente != null)
          TextButton(
            onPressed: isLoading ? null : onTentarNovamente,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Tentar Novamente'),
          ),
        if (onContinuarOffline != null)
          ElevatedButton(
            onPressed: isLoading ? null : onContinuarOffline,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF312E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Continuar Offline'),
          ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    VoidCallback? onContinuarOffline,
    VoidCallback? onTentarNovamente,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OfflineDialog(
        onContinuarOffline: onContinuarOffline,
        onTentarNovamente: onTentarNovamente,
        isLoading: isLoading,
      ),
    );
  }
}

