import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterChipRow extends StatefulWidget {
  final List<String> filters;
  final Function(int selection, String selectionName) onSelected;
  final int defaultSelection;

  const FilterChipRow({
    super.key,
    required this.filters,
    required this.onSelected,
    this.defaultSelection = 0
  });

  @override
  State<StatefulWidget> createState() => _FilterChipRow();
}

class _FilterChipRow extends State<FilterChipRow> {
  List<Widget> items = [];
  List<bool> isSelected = [];
  List<Function(Function())> setters = [];

  @override
  void initState() {
    super.initState();

    for(int index = 0; index < widget.filters.length; index++) {
      isSelected.add((widget.defaultSelection == index));

      items.add(StatefulBuilder(
        builder: (BuildContext context, Function(Function()) setter) {
          setters.add(setter);

          return FilterChip(
            label: Text(widget.filters[index]),
            selected: isSelected[index],
            onSelected: (bool newValue) {
              if(newValue) {
                widget.onSelected(index, widget.filters[index]);
                for(int i = 0; i < isSelected.length; i++) {
                  if(isSelected[i]) setters[i]((){});
                  isSelected[i] = false;
                }
                isSelected[index] = true;
                setter((){});
              }
            }
          );
        }
       )
      );
      items.add(const SizedBox(width: 12));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items,
      ),
    );
  }
}