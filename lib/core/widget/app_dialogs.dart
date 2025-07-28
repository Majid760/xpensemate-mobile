// import 'package:flutter/material.dart';
// import 'package:xpensemate/core/localization/locale_manager.dart';
// import 'package:xpensemate/core/localization/supported_locales.dart';
// import 'package:xpensemate/core/service/storage_service.dart';
// import 'package:xpensemate/core/theme/theme_context_extension.dart';
 
 
 
//  void _showLanguageDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text(context.selectLanguage),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: SupportedLocales.supportedLocales.map((locale) {
//               final isSelected = dialogContext.locale.languageCode == locale.languageCode;
//               return ListTile(
//                 leading: Icon(
//                   Icons.language,
//                   color: isSelected ? dialogContext.primaryColor : null,
//                 ),
//                 title: Text(SupportedLocales.getDisplayName(locale)),
//                 subtitle: Text(locale.toString()),
//                 trailing: isSelected ? Icon(Icons.check, color: dialogContext.primaryColor) : null,
//                 selected: isSelected,
//                 onTap: () async {
//                   await LocaleManager().setLocale(locale);
//                   if (dialogContext.mounted) {
//                     Navigator.of(dialogContext).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(context.languageChanged),
//                         backgroundColor: context.colorScheme.primary,
//                       ),
//                     );
//                   }
//                 },
//               );
//             }).toList(),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(dialogContext.cancel),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showThemeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text(dialogContext.themeMode),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.light_mode),
//                 title: Text(dialogContext.lightTheme),
//                 onTap: () {
//                   // Here you would implement theme switching
//                   Navigator.of(dialogContext).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.dark_mode),
//                 title: Text(dialogContext.darkTheme),
//                 onTap: () {
//                   // Here you would implement theme switching
//                   Navigator.of(dialogContext).pop();
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.settings_system_daydream),
//                 title: Text(dialogContext.systemTheme),
//                 onTap: () {
//                   // Here you would implement theme switching
//                   Navigator.of(dialogContext).pop();
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(dialogContext.cancel),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showConfirmDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text(dialogContext.confirm),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(dialogContext.confirmDelete),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 dialogContext.deleteWarning,
//                 style: dialogContext.bodySmall?.copyWith(
//                   color: dialogContext.errorColor,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(dialogContext.cancel),
//             ),
//             FilledButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 _showSuccessSnackBar(context, isDelete: true);
//               },
//               style: FilledButton.styleFrom(
//                 backgroundColor: dialogContext.errorColor,
//               ),
//               child: Text(dialogContext.delete),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showInfoDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           title: Text(dialogContext.about),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 dialogContext.appTitle,
//                 style: dialogContext.titleMedium,
//               ),
//               const SizedBox(height: AppSpacing.sm),
//               Text('Version: 1.0.0'),
//               const SizedBox(height: AppSpacing.sm),
//               Text(
//                 'This app demonstrates Flutter localization with Material 3 theming.',
//                 style: dialogContext.bodyMedium,
//               ),
//               const SizedBox(height: AppSpacing.md),
//               Text(
//                 'Supported Languages:',
//                 style: dialogContext.titleSmall,
//               ),
//               const SizedBox(height: AppSpacing.xs),
//               ...SupportedLocales.supportedLocales.map(
//                 (locale) => Padding(
//                   padding: const EdgeInsets.only(left: AppSpacing.md),
//                   child: Text(
//                     '• ${SupportedLocales.getDisplayName(locale)}',
//                     style: dialogContext.bodySmall,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: Text(dialogContext.close),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showSuccessSnackBar(BuildContext context, {bool isDelete = false}) {
//     final message = isDelete ? context.deleteSuccess : context.saveSuccess;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: context.colorScheme.primary,
//         action: SnackBarAction(
//           label: context.close,
//           textColor: context.colorScheme.onPrimary,
//           onPressed: () {
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//       ),
//     );
//   }