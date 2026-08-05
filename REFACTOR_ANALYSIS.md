# Refactor Analysis

## Dependency Issues Found:
1. `google_mlkit_text_recognition: ^0.12.0` was upgraded to `^0.14.0` which may conflict with minSdk 21
2. `camera: ^0.11.0+1` requires minSdk 21 - OK
3. `go_router: ^14.0.0` requires Flutter 3.19+
4. `printing: ^5.12.0` needs minSdk 21 - OK
5. `intl: ^0.19.0` - compatibility with newer versions

## Key Issues to Fix:
1. minSdk should be 23 for ML Kit compatibility
2. The OCR screen references `databaseHelperProvider` which is a Provider, not the helper directly
3. Deduction screen had duplicate DeductionEntryEntity class - removed
4. Many screens use `GlassContainer` with opacity param that was removed
5. PDF service uses Printing.layoutPdf (print preview) - needs direct save
6. Daily deduction bug: allows duplicate deductions per date
7. No database indexes on frequently searched fields
8. No transaction safety for complex operations
9. UI lag from BackdropFilter - already fixed

## Files Modified:
- pubspec.yaml - fixed versions
- glass_widgets.dart - removed BackdropFilter
- database_helper.dart - v2 schema with migration, settings table, party_items table
- app_router.dart - added /settings and /party-items routes
- main.dart - added localization delegates
- dashboard_screen.dart - optimized
- deduction_screen.dart - fixed pop bug, clears form instead
- ocr_scan_screen.dart - improved table, 3-option dialog, party items save
- officer_list_screen.dart - navigation to party items
- officer_repository.dart/impl.dart - added getPartyItems method
- inventory_providers.dart - added aiServiceProvider, fixed loadItems

## New Files:
- app_localizations.dart
- ai_service.dart
- party_items_entity.dart
- party_items_screen.dart
- settings_screen.dart
