import 'package:collection/collection.dart';
import 'package:example/available_color_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:newton_particles/newton_particles.dart';

class ColorSelection extends StatefulWidget {
  const ColorSelection({required this.onChanged, required this.existingColors, super.key});

  final ValueChanged<ParticleColor> onChanged;
  final List<Color> existingColors;

  @override
  State<ColorSelection> createState() => _ColorSelectionState();
}

class _ColorSelectionState extends State<ColorSelection> {
  late final List<Color> _currentColors;

  late ColorType _colorType;

  @override
  void initState() {
    super.initState();
    final colors = widget.existingColors.toList(growable: true);
    _currentColors = colors.isEmpty ? [Colors.white] : colors;
    _colorType = widget.existingColors.length > 1 ? ColorType.linearInterpolation : ColorType.single;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Colors:'),
            Row(
              children: [colorTypeSelection(), ...currentColorWidgets()],
            ),
            if (_colorType == ColorType.linearInterpolation)
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentColors.add(Colors.white);
                        widget.onChanged(
                          LinearInterpolationParticleColor(
                            colors: _currentColors,
                          ),
                        );
                      });
                    },
                    child: const Text('Add'),
                  ),
                  if (_currentColors.length > 1)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_currentColors.length > 1) {
                            _currentColors.removeLast();
                            widget.onChanged(
                              LinearInterpolationParticleColor(
                                colors: _currentColors,
                              ),
                            );
                          }
                        });
                      },
                      child: const Text('Remove'),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> currentColorWidgets() {
    return _currentColors
        .mapIndexed(
          (index, color) => SizedBox(
            width: 30,
            height: 30,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.white),
                  ),
                ),
                onTap: () {
                  showDialog<dynamic>(
                    context: context,
                    builder: (buildContext) => AlertDialog(
                      title: const Text('Pick a color!'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: color,
                          onColorChanged: (newColor) {
                            changeColor(newColor, index);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        )
        .toList();
  }

  void changeColor(Color color, int index) {
    setState(() {
      _currentColors[index] = color;
      updateCurrentColor();
    });
  }

  Widget colorTypeSelection() {
    return SizedBox(
      width: 200,
      child: DropdownButton<String>(
        isExpanded: true,
        value: _colorType.label,
        icon: const Icon(Icons.arrow_drop_down),
        elevation: 16,
        onChanged: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            _colorType = ColorType.of(value!);
            updateCurrentColor();
          });
        },
        items: ColorType.values.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.label,
            child: Text(value.label),
          );
        }).toList(),
      ),
    );
  }

  void updateCurrentColor() {
    switch (_colorType) {
      case ColorType.single:
        if (_currentColors.length > 1) {
          _currentColors.removeRange(1, _currentColors.length - 1);
        }
        widget.onChanged(SingleParticleColor(color: _currentColors[0]));
      case ColorType.linearInterpolation:
        if (_currentColors.length == 1) {
          _currentColors.add(Colors.white);
        }
        widget.onChanged(
          LinearInterpolationParticleColor(
            colors: _currentColors,
          ),
        );
    }
  }
}
