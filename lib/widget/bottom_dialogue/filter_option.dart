import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/filter/filter_options.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/date/date_item.dart';
import 'package:web_flutter/widget/filtered/checkbox_zone.dart';
import 'package:web_flutter/widget/filtered/custom_range.dart';
import 'package:web_flutter/widget/filtered/quantity_information.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class FilterOption extends StatefulWidget {
  final FilterCriteria? initialCriteria;
  final Function(FilterCriteria)? onApplyFilter;
  final Function()? onResetFilter;

  const FilterOption({
    super.key,
    this.initialCriteria,
    this.onApplyFilter,
    this.onResetFilter,
  });

  @override
  State<FilterOption> createState() => _FilterOptionState();
}

class _FilterOptionState extends State<FilterOption> {
  double max = 10000000;
  double min = 0;
  int litqte = 0;
  int chambeqte = 0;
  int doucheqte = 0;
  DateTimeRange? selectedRange;
  List<String> commodite = [];
  List<String> preference = [];
  List<String> regle = [];
  FilterOptions? filterOptions;

  late RangeValues range;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadFilterOptions();
  }

  void _loadInitialData() {
    final criteria = widget.initialCriteria;
    if (criteria != null) {
      litqte = criteria.nbLits ?? 0;
      chambeqte = criteria.nbChambres ?? 0;
      doucheqte = criteria.nbDouches ?? 0;
      selectedRange = criteria.dateDebut != null && criteria.dateFin != null
          ? DateTimeRange(start: criteria.dateDebut!, end: criteria.dateFin!)
          : null;
      commodite = List.from(criteria.commodites ?? []);
      preference = List.from(criteria.preferences ?? []);
      regle = List.from(criteria.regles ?? []);

      final prixMin = criteria.prixMin ?? min;
      final prixMax = criteria.prixMax ?? max;
      range = RangeValues(prixMin, prixMax);
    } else {
      range = RangeValues(min, max);
    }
  }

  void _loadFilterOptions() {
    context.read<AppartementBloc>().add(LoadFilterOptions());
  }

  @override
  Widget build(BuildContext context) {
    final start = range.start.ceil();
    final end = range.end.ceil();
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Style.containerColor3,
            boxShadow: [
              BoxShadow(
                color: Style.shadowColor,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconBoutton(icon: Icons.close, onPressed: () => back(context)),
              Spacer(),
              PlainButton(
                value: "Reset",
                plain: false,
                color: Style.white,
                onPress: _resetFilters,
              ),
              Gap(Espacement.gapSection),
              BlocConsumer<AppartementBloc, AppartementState>(
                listener: (context, state) {
                  if (state is FilterOptionsLoaded) {
                    setState(() {
                      filterOptions = state.options;
                      max = state.options.prixMax;
                      min = state.options.prixMin;
                      if (widget.initialCriteria == null) {
                        range = RangeValues(min, max);
                      }
                    });
                  } else if (state is FilteredAppartementsLoaded) {
                    back(context);
                  } else if (state is AppartementError) {
                    // Gestion d'erreur : revenir aux données par défaut
                    setState(() {
                      filterOptions = null;
                      max = 10000000;
                      min = 0;
                      if (widget.initialCriteria == null) {
                        range = RangeValues(min, max);
                      }
                    });

                    // Afficher un message d'erreur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Impossible de charger les options de filtre"),
                        backgroundColor: Colors.orange,
                        action: SnackBarAction(
                          label: "Réessayer",
                          onPressed: _loadFilterOptions,
                        ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AppartementLoading;
                  return PlainButton(
                    value: isLoading ? "Chargement..." : "Save",
                    onPress: isLoading ? null : _applyFilters,
                  );
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Espacement.gapSection,
                      children: [
                        TextSeed("Prix"),
                        Gap(Espacement.gapSection),
                        TextSeed(
                          "${helpAmountFormate(start)} FCFA - ${helpAmountFormate(end)} FCFA",
                        ),
                        CustomRange(
                          range: range,
                          onChange: onChange,
                          max: max,
                          min: min,
                        ),
                        Gap(Espacement.gapItem),
                        Divider(),
                        DateItem(
                          selectedRange: selectedRange,
                          onSelectRange:
                              (p0) => setState(() {
                                selectedRange = p0;
                              }),
                        ),
                        Divider(),
                        Gap(Espacement.gapSection),
                        TextSeed("Lit et Chambre"),
                        Gap(Espacement.gapSection),
                        QuantityInformation(
                          title: "Lit",
                          maxValue: 5,
                          selectedValue: litqte,
                          onSelectedValue:
                              (value) => setState(() {
                                litqte = value;
                              }),
                        ),
                        QuantityInformation(
                          title: "Chambre",
                          maxValue: 5,
                          selectedValue: chambeqte,
                          onSelectedValue:
                              (value) => setState(() {
                                chambeqte = value;
                              }),
                        ),
                        QuantityInformation(
                          title: "Douche",
                          maxValue: 5,
                          selectedValue: doucheqte,
                          onSelectedValue:
                              (value) => setState(() {
                                doucheqte = value;
                              }),
                        ),
                        _buildCheckboxSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onChange(RangeValues ranges) {
    deboger(ranges);
    setState(() {
      range = ranges;
    });
  }

  void _applyFilters() {
    final criteria = FilterCriteria(
      prixMin: range.start == min ? null : range.start,
      prixMax: range.end == max ? null : range.end,
      dateDebut: selectedRange?.start,
      dateFin: selectedRange?.end,
      nbLits: litqte > 0 ? litqte : null,
      nbChambres: chambeqte > 0 ? chambeqte : null,
      nbDouches: doucheqte > 0 ? doucheqte : null,
      commodites: commodite.isNotEmpty ? commodite : null,
      preferences: preference.isNotEmpty ? preference : null,
      regles: regle.isNotEmpty ? regle : null,
    );

    // Sauvegarder dans AppData
    final appData = Provider.of<AppData>(context, listen: false);
    appData.setFilterCriteria(criteria);

    // Callback personnalisé si fourni
    if (widget.onApplyFilter != null) {
      widget.onApplyFilter!(criteria);
    } else {
      // Appliquer les filtres via le bloc
      if (criteria.hasFilters) {
        context.read<AppartementBloc>().add(LoadFilteredAppartements(criteria));
      } else {
        context.read<AppartementBloc>().add(ClearFilters());
      }
    }
  }

  Widget _buildCheckboxSection() {
    final appData = Provider.of<AppData>(context, listen: false);
    final options = filterOptions ?? appData.defaultFilterOptions;

    return Column(
      children: [
        CheckboxZone(
          title: "Commodite",
          values: options.commodites,
          selectedValues: commodite,
        ),
        CheckboxZone(
          title: "Preference",
          values: options.preferences,
          selectedValues: preference,
        ),
        CheckboxZone(
          title: "Règle",
          values: options.regles,
          selectedValues: regle,
        ),
      ],
    );
  }

  void _resetFilters() {
    setState(() {
      commodite = [];
      preference = [];
      regle = [];
      litqte = 0;
      chambeqte = 0;
      doucheqte = 0;
      selectedRange = null;
      range = RangeValues(min, max);
    });

    // Callback personnalisé si fourni
    if (widget.onResetFilter != null) {
      widget.onResetFilter!();
    } else {
      // Effacer les filtres
      final appData = Provider.of<AppData>(context, listen: false);
      appData.clearFilters();
      context.read<AppartementBloc>().add(ClearFilters());
    }
  }
}
