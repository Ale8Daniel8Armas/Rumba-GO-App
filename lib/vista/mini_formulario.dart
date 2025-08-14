import 'package:flutter/material.dart';

class MiniFormulario {
  static void mostrar({
    required BuildContext context,
    required VoidCallback onResenaPressed,
    required VoidCallback onLocalPressed,
    Color? backgroundColor,
    Color? iconColor,
    Color? textColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.purple[900],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                context,
                icon: Icons.edit,
                text: 'Escribir reseña',
                color: iconColor ?? const Color(0xFFB1FBFF),
                textColor: textColor ?? Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  onResenaPressed();
                },
              ),
              Divider(color: Colors.purple[700]),
              _buildOptionTile(
                context,
                icon: Icons.add_business,
                text: 'Agregar local',
                color: iconColor ?? const Color(0xFFB1FBFF),
                textColor: textColor ?? Colors.white,
                onTap: () {
                  Navigator.pop(context);
                  onLocalPressed();
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
