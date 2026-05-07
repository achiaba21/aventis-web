import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/phone/country.dart';
import 'package:asfar/service/phone/countries_service.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class CountrySelector extends StatelessWidget {
  const CountrySelector({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  final Country selectedCountry;
  final Function(Country) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCountryModal(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextSeed(
              selectedCountry.flag,
              fontSize: 16,
            ),
            SizedBox(width: 4),
            TextSeed(
              selectedCountry.dialCode,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.background,
            ),
            SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountrySelectionModal(
        selectedCountry: selectedCountry,
        onCountrySelected: onCountrySelected,
      ),
    );
  }
}

class CountrySelectionModal extends StatefulWidget {
  const CountrySelectionModal({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  final Country selectedCountry;
  final Function(Country) onCountrySelected;

  @override
  State<CountrySelectionModal> createState() => _CountrySelectionModalState();
}

class _CountrySelectionModalState extends State<CountrySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = [];
  List<Country> _allCountries = [];

  @override
  void initState() {
    super.initState();
    _allCountries = CountriesService.getAllCountries();
    _filteredCountries = _allCountries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    setState(() {
      _filteredCountries = CountriesService.searchCountries(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Espacement.radius * 2),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          _buildPopularCountries(),
          Expanded(child: _buildCountriesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextSeed(
              "Sélectionner un pays",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      child: InputField(
        controller: _searchController,
        placeHolder: "Rechercher un pays...",
        leftIcon: Icon(Icons.search, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildPopularCountries() {
    final popularCountries = CountriesService.getPopularCountries();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: Espacement.paddingBloc),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            "Pays populaires",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: popularCountries.map((country) {
                return Container(
                  margin: EdgeInsets.only(right: 8),
                  child: _buildCountryChip(country, isPopular: true),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: Espacement.gapSection),
          Divider(color: AppColors.border),
        ],
      ),
    );
  }

  Widget _buildCountriesList() {
    return ListView.builder(
      itemCount: _filteredCountries.length,
      itemBuilder: (context, index) {
        final country = _filteredCountries[index];
        return _buildCountryItem(country);
      },
    );
  }

  Widget _buildCountryChip(Country country, {bool isPopular = false}) {
    final isSelected = country == widget.selectedCountry;

    return InkWell(
      onTap: () => _selectCountry(country),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.divider,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextSeed(country.flag, fontSize: 14),
            SizedBox(width: 4),
            TextSeed(
              country.dialCode,
              fontSize: 12,
              color: isSelected ? AppColors.white : AppColors.background,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryItem(Country country) {
    final isSelected = country == widget.selectedCountry;

    return InkWell(
      onTap: () => _selectCountry(country),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : null,
        ),
        child: Row(
          children: [
            TextSeed(country.flag, fontSize: 20),
            SizedBox(width: Espacement.gapSection),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSeed(
                    country.name,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.background,
                  ),
                  TextSeed(
                    country.dialCode,
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: AppColors.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _selectCountry(Country country) {
    widget.onCountrySelected(country);
    Navigator.pop(context);
  }
}