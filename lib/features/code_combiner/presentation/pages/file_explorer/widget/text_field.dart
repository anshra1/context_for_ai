import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_design_system/material_design_system.dart';

enum IconPosition { left, right, none }

typedef ValidatorFunction = String? Function(String value);

class ValidationBuilder {
  final List<ValidatorFunction> _validators = [];

  void required([String message = 'This field is required']) {
    _validators.add((value) => value.trim().isEmpty ? message : null);
  }

  void minLength(int min, [String? message]) {
    _validators.add(
      (value) => value.trim().length < min
          ? (message ?? 'Minimum $min characters required')
          : null,
    );
  }

  void maxLength(int max, [String? message]) {
    _validators.add(
      (value) => value.trim().length > max
          ? (message ?? 'Maximum $max characters allowed')
          : null,
    );
  }

  List<ValidatorFunction> build() => _validators;
}

class TextFieldButtonWithLabel extends HookWidget {
  const TextFieldButtonWithLabel(
    this.textFieldHeight, {
    required this.labelText,
    required this.iconData,
    required this.startingText,
    required this.onTextSubmitted,
    this.validators,
    this.inputFormatters,
    this.tooltipText = '',
    this.iconPosition = IconPosition.right,
    this.textAlign = TextAlign.left,
    this.iconSize = 20.0,
    super.key,
  });

  final String labelText;
  final IconData iconData;
  final String startingText;
  final void Function(String) onTextSubmitted;
  final List<ValidatorFunction>? validators;
  final List<TextInputFormatter>? inputFormatters;
  final String tooltipText;
  final IconPosition iconPosition;
  final TextAlign textAlign;
  final double textFieldHeight;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final md = MdTheme.of(context);
    final isEditing = useState(false);
    final currentText = useState(startingText);
    final validationMessage = useState<String?>(null);
    final textController = useTextEditingController(text: currentText.value);
    final focusNode = useFocusNode();

    useEffect(
      () {
        currentText.value = startingText;
        textController.text = startingText;
        return null;
      },
      [startingText],
    );

    void handleTap() {
      if (!isEditing.value) {
        isEditing.value = true;
        textController.text = currentText.value;
        Future.delayed(const Duration(milliseconds: 100), focusNode.requestFocus);
      }
    }

    String? validate(String value) {
      if (validators == null || validators!.isEmpty) return null;
      for (final validator in validators!) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    }

    void handleSave() {
      final newText = textController.text.trim();
      final validation = validate(newText);
      if (validation != null) {
        validationMessage.value = validation;
        return;
      }
      validationMessage.value = null;
      if (newText != currentText.value) {
        currentText.value = newText;
        onTextSubmitted(newText);
      }
      isEditing.value = false;
      focusNode.unfocus();
    }

    final labelTextStyle = md.typ
        .getLabelLarge(context)
        .copyWith(color: md.sys.onSurfaceVariant);
    final textFieldTextStyle = md.typ
        .getBodyLarge(context)
        .copyWith(color: md.sys.onSurface);
    final validationTextStyle = md.typ
        .getBodySmall(context)
        .copyWith(color: md.sys.error);

    final contentPadding = md.space
        .hLarge(context)
        .copyWith(
          top: md.space.medium(context),
          bottom: md.space.medium(context),
        );

    final unfocusedBorder = OutlineInputBorder(
      borderRadius: md.sha.borderRadiusMedium,
      borderSide: BorderSide(color: md.sys.outline),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: md.sha.borderRadiusMedium,
      borderSide: BorderSide(color: md.sys.primary, width: 2),
    );

    return AnimatedContainer(
      duration: md.motion.durationMedium,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (labelText.isNotEmpty) ...[
            Text(labelText, style: labelTextStyle),
            SizedBox(height: md.space.small(context)),
          ],
          Tooltip(
            message: tooltipText,
            child: SizedBox(
              width: double.infinity,
              height: textFieldHeight,
              child: TextField(
                controller: textController,
                inputFormatters: inputFormatters,
                focusNode: focusNode,
                onTap: handleTap,
                style: textFieldTextStyle,
                textAlign: textAlign,
                textAlignVertical: TextAlignVertical.center,
                onEditingComplete: handleSave,
                decoration: InputDecoration(
                  contentPadding: contentPadding,
                  enabledBorder: unfocusedBorder,
                  focusedBorder: focusedBorder,
                  filled: true,
                  fillColor: md.com.textField.backgroundColor,
                  prefixIcon: iconPosition == IconPosition.left
                      ? Padding(
                          padding: EdgeInsets.only(right: md.space.medium(context)),
                          child: Icon(
                            iconData,
                            size: iconSize,
                            color: md.sys.onSurfaceVariant,
                          ),
                        )
                      : null,
                  suffixIcon: iconPosition == IconPosition.right
                      ? IconButton(
                          icon: Icon(
                            isEditing.value ? Icons.check : iconData,
                            size: iconSize,
                            color: md.sys.onSurfaceVariant,
                          ),
                          onPressed: isEditing.value ? handleSave : handleTap,
                        )
                      : null,
                ),
              ),
            ),
          ),
          if (validationMessage.value != null) ...[
            SizedBox(height: md.space.extraSmall(context)),
            Text(
              validationMessage.value!,
              style: validationTextStyle,
            ),
          ],
        ],
      ),
    );
  }
}
