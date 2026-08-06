class PreloadedInventoryAsset {
  final String assetKey;
  final String name;
  final String category;
  final String unit;
  final double openingStock;
  final double reorderLevel;

  const PreloadedInventoryAsset({
    required this.assetKey,
    required this.name,
    required this.category,
    required this.unit,
    this.openingStock = 0,
    this.reorderLevel = 0,
  });
}

class InventoryCatalog {
  static const List<String> supportedUnits = [
    'Kg',
    'Gram',
    'Quintal',
    'Litre',
    'Millilitre',
    'Piece',
    'Packet',
    'Dozen',
    'Bottle',
    'Tin',
    'Box',
    'Bag',
    'Sack',
    'Bundle',
    'Roll',
  ];

  static const List<String> preloadedCategories = [
    'Anaaj',
    'Dal',
    'Tel & Ghee',
    'Masale',
    'Sabzi',
    'Dairy',
    'Dry Items',
    'Non Veg',
    'Fruits',
    'Cleaning',
    'Packaging',
  ];

  static const List<PreloadedInventoryAsset> assets = [
    PreloadedInventoryAsset(assetKey: 'anaaj_chawal', name: 'Chawal', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_atta', name: 'Atta', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_maida', name: 'Maida', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_suji', name: 'Suji', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_besan', name: 'Besan', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_daliya', name: 'Daliya', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_poha', name: 'Poha', category: 'Anaaj', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'anaaj_sevai', name: 'Sevai', category: 'Anaaj', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'dal_arhar_dal', name: 'Arhar Dal', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_chana_dal', name: 'Chana Dal', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_masoor_dal', name: 'Masoor Dal', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_moong_dal', name: 'Moong Dal', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_urad_dal', name: 'Urad Dal', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_rajma', name: 'Rajma', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_chole', name: 'Chole', category: 'Dal', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dal_lobia', name: 'Lobia', category: 'Dal', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'tel_ghee_sarson_tel', name: 'Sarson Tel', category: 'Tel & Ghee', unit: 'Litre'),
    PreloadedInventoryAsset(assetKey: 'tel_ghee_refined_tel', name: 'Refined Tel', category: 'Tel & Ghee', unit: 'Litre'),
    PreloadedInventoryAsset(assetKey: 'tel_ghee_soyabean_tel', name: 'Soyabean Tel', category: 'Tel & Ghee', unit: 'Litre'),
    PreloadedInventoryAsset(assetKey: 'tel_ghee_sunflower_tel', name: 'Sunflower Tel', category: 'Tel & Ghee', unit: 'Litre'),
    PreloadedInventoryAsset(assetKey: 'tel_ghee_ghee', name: 'Ghee', category: 'Tel & Ghee', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'tel_ghee_butter', name: 'Butter', category: 'Tel & Ghee', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'masale_haldi_powder', name: 'Haldi Powder', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_mirch_powder', name: 'Mirch Powder', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_dhaniya_powder', name: 'Dhaniya Powder', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_jeera', name: 'Jeera', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_rai', name: 'Rai', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_ajwain', name: 'Ajwain', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_garam_masala', name: 'Garam Masala', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_chaat_masala', name: 'Chaat Masala', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_kali_mirch', name: 'Kali Mirch', category: 'Masale', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'masale_tej_patta', name: 'Tej Patta', category: 'Masale', unit: 'Gram'),
    PreloadedInventoryAsset(assetKey: 'masale_dalchini', name: 'Dalchini', category: 'Masale', unit: 'Gram'),
    PreloadedInventoryAsset(assetKey: 'masale_laung', name: 'Laung', category: 'Masale', unit: 'Gram'),
    PreloadedInventoryAsset(assetKey: 'masale_elaichi', name: 'Elaichi', category: 'Masale', unit: 'Gram'),
    PreloadedInventoryAsset(assetKey: 'masale_hing', name: 'Hing', category: 'Masale', unit: 'Gram'),
    PreloadedInventoryAsset(assetKey: 'masale_kasuri_methi', name: 'Kasuri Methi', category: 'Masale', unit: 'Gram'),

    PreloadedInventoryAsset(assetKey: 'sabzi_aloo', name: 'Aloo', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_pyaz', name: 'Pyaz', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_tamatar', name: 'Tamatar', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_adrak', name: 'Adrak', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_lahsun', name: 'Lahsun', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_hari_mirch', name: 'Hari Mirch', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_gobhi', name: 'Gobhi', category: 'Sabzi', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'sabzi_band_gobhi', name: 'Band Gobhi', category: 'Sabzi', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'sabzi_shimla_mirch', name: 'Shimla Mirch', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_gajar', name: 'Gajar', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_mooli', name: 'Mooli', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_baingan', name: 'Baingan', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_bhindi', name: 'Bhindi', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_lauki', name: 'Lauki', category: 'Sabzi', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'sabzi_tori', name: 'Tori', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_kaddu', name: 'Kaddu', category: 'Sabzi', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'sabzi_karela', name: 'Karela', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_matar', name: 'Matar', category: 'Sabzi', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'sabzi_palak', name: 'Palak', category: 'Sabzi', unit: 'Bundle'),
    PreloadedInventoryAsset(assetKey: 'sabzi_methi', name: 'Methi', category: 'Sabzi', unit: 'Bundle'),
    PreloadedInventoryAsset(assetKey: 'sabzi_dhaniya_patti', name: 'Dhaniya Patti', category: 'Sabzi', unit: 'Bundle'),
    PreloadedInventoryAsset(assetKey: 'sabzi_pudina', name: 'Pudina', category: 'Sabzi', unit: 'Bundle'),
    PreloadedInventoryAsset(assetKey: 'sabzi_nimbu', name: 'Nimbu', category: 'Sabzi', unit: 'Piece'),

    PreloadedInventoryAsset(assetKey: 'dairy_doodh', name: 'Doodh', category: 'Dairy', unit: 'Litre'),
    PreloadedInventoryAsset(assetKey: 'dairy_dahi', name: 'Dahi', category: 'Dairy', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dairy_paneer', name: 'Paneer', category: 'Dairy', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dairy_cheese', name: 'Cheese', category: 'Dairy', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'dry_namak', name: 'Namak', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_cheeni', name: 'Cheeni', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_gud', name: 'Gud', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_chai_patti', name: 'Chai Patti', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_coffee', name: 'Coffee', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_soya_bari', name: 'Soya Bari', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_corn_flour', name: 'Corn Flour', category: 'Dry Items', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'dry_vermicelli', name: 'Vermicelli', category: 'Dry Items', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'non_veg_anda', name: 'Anda', category: 'Non Veg', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'non_veg_chicken', name: 'Chicken', category: 'Non Veg', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'non_veg_mutton', name: 'Mutton', category: 'Non Veg', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'non_veg_machhli', name: 'Machhli', category: 'Non Veg', unit: 'Kg'),

    PreloadedInventoryAsset(assetKey: 'fruits_kela', name: 'Kela', category: 'Fruits', unit: 'Dozen'),
    PreloadedInventoryAsset(assetKey: 'fruits_seb', name: 'Seb', category: 'Fruits', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'fruits_santara', name: 'Santara', category: 'Fruits', unit: 'Kg'),
    PreloadedInventoryAsset(assetKey: 'fruits_papita', name: 'Papita', category: 'Fruits', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'fruits_tarbooj', name: 'Tarbooj', category: 'Fruits', unit: 'Piece'),

    PreloadedInventoryAsset(assetKey: 'cleaning_lpg_cylinder', name: 'LPG Cylinder', category: 'Cleaning', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'cleaning_dish_wash', name: 'Dish Wash', category: 'Cleaning', unit: 'Bottle'),
    PreloadedInventoryAsset(assetKey: 'cleaning_phenyl', name: 'Phenyl', category: 'Cleaning', unit: 'Bottle'),
    PreloadedInventoryAsset(assetKey: 'cleaning_hand_wash', name: 'Hand Wash', category: 'Cleaning', unit: 'Bottle'),
    PreloadedInventoryAsset(assetKey: 'cleaning_jhaadu', name: 'Jhaadu', category: 'Cleaning', unit: 'Piece'),
    PreloadedInventoryAsset(assetKey: 'cleaning_pocha', name: 'Pocha', category: 'Cleaning', unit: 'Piece'),

    PreloadedInventoryAsset(assetKey: 'packaging_plastic_bag', name: 'Plastic Bag', category: 'Packaging', unit: 'Packet'),
    PreloadedInventoryAsset(assetKey: 'packaging_foil', name: 'Foil', category: 'Packaging', unit: 'Roll'),
    PreloadedInventoryAsset(assetKey: 'packaging_tissue', name: 'Tissue', category: 'Packaging', unit: 'Packet'),
    PreloadedInventoryAsset(assetKey: 'packaging_cling_film', name: 'Cling Film', category: 'Packaging', unit: 'Roll'),
  ];
}
