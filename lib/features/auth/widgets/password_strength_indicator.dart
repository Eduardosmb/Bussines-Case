import 'package:flutter/material.dart';
import '../../../core/utils/string_utils.dart';
import '../../../core/theme/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    final strength = StringUtils.getPasswordStrength(password);
    final strengthText = StringUtils.getPasswordStrengthText(strength);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strength bars
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: _getStrengthColor(strength, index),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: 8),
        
        // Strength text and requirements
        Row(
          children: [
            Text(
              'Password strength: ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              strengthText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getStrengthTextColor(strength),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Requirements checklist
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRequirement(
              'At least 8 characters',
              password.length >= 8,
            ),
            _buildRequirement(
              'Contains uppercase letter',
              RegExp(r'[A-Z]').hasMatch(password),
            ),
            _buildRequirement(
              'Contains lowercase letter',
              RegExp(r'[a-z]').hasMatch(password),
            ),
            _buildRequirement(
              'Contains number',
              RegExp(r'\d').hasMatch(password),
            ),
            _buildRequirement(
              'Contains special character',
              RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isMet ? AppTheme.successColor : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? AppTheme.successColor : Colors.grey[600],
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(int strength, int index) {
    if (index >= strength) {
      return Colors.grey[300]!;
    }

    switch (strength) {
      case 1:
        return AppTheme.errorColor;
      case 2:
        return AppTheme.warningColor;
      case 3:
        return AppTheme.accentColor;
      case 4:
        return AppTheme.successColor;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getStrengthTextColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppTheme.errorColor;
      case 2:
        return AppTheme.warningColor;
      case 3:
        return AppTheme.accentColor;
      case 4:
        return AppTheme.successColor;
      default:
        return Colors.grey[600]!;
    }
  }
}
