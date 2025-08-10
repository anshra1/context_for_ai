import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/settings_cubit.dart';
import '../../data/models/app_settings.dart';

class SettingsFormWidget extends StatefulWidget {
  const SettingsFormWidget({Key? key}) : super(key: key);

  @override
  State<SettingsFormWidget> createState() => _SettingsFormWidgetState();
}

class _SettingsFormWidgetState extends State<SettingsFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _splitSizeController;
  late TextEditingController _tokenLimitController;
  late TextEditingController _exportLocationController;
  
  @override
  void initState() {
    super.initState();
    _splitSizeController = TextEditingController();
    _tokenLimitController = TextEditingController();
    _exportLocationController = TextEditingController();
  }
  
  @override
  void dispose() {
    _splitSizeController.dispose();
    _tokenLimitController.dispose();
    _exportLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, AppSettings>(
      builder: (context, settings) {
        // Update controllers with current settings
        _splitSizeController.text = settings.fileSplitSizeInMB.toString();
        _tokenLimitController.text = settings.maxTokenWarningLimit.toString();
        _exportLocationController.text = settings.defaultExportLocation ?? '';
        
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO: Add export settings section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Export Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // TODO: Add file split size setting
                      TextFormField(
                        controller: _splitSizeController,
                        decoration: const InputDecoration(
                          labelText: 'File Split Size (MB)',
                          hintText: 'Enter size in MB',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a split size';
                          }
                          final size = int.tryParse(value);
                          if (size == null || size < 1 || size > 100) {
                            return 'Size must be between 1 and 100 MB';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final size = int.tryParse(value);
                          if (size != null && size >= 1 && size <= 100) {
                            context.read<SettingsCubit>().updateFileSplitSize(size);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // TODO: Add token warning limit setting
                      TextFormField(
                        controller: _tokenLimitController,
                        decoration: const InputDecoration(
                          labelText: 'Token Warning Limit',
                          hintText: 'Enter token count',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a token limit';
                          }
                          final limit = int.tryParse(value);
                          if (limit == null || limit < 1000 || limit > 50000) {
                            return 'Limit must be between 1000 and 50000 tokens';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final limit = int.tryParse(value);
                          if (limit != null && limit >= 1000 && limit <= 50000) {
                            context.read<SettingsCubit>().updateTokenWarningLimit(limit);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // TODO: Add default export location setting
                      TextFormField(
                        controller: _exportLocationController,
                        decoration: InputDecoration(
                          labelText: 'Default Export Location',
                          hintText: 'Optional default save location',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: _pickDefaultLocation,
                            icon: const Icon(Icons.folder_open),
                            tooltip: 'Browse for folder',
                          ),
                        ),
                        readOnly: true,
                        onTap: _pickDefaultLocation,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // TODO: Add behavior settings section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Behavior Settings',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      // TODO: Add warn on token exceed setting
                      SwitchListTile(
                        title: const Text('Warn when token limit exceeded'),
                        subtitle: const Text('Show warning dialog when export exceeds token limit'),
                        value: settings.warnOnTokenExceed,
                        onChanged: (value) {
                          context.read<SettingsCubit>().updateWarnOnTokenExceed(value);
                        },
                      ),
                      
                      // TODO: Add strip comments setting
                      SwitchListTile(
                        title: const Text('Strip comments from code'),
                        subtitle: const Text('Remove comments to reduce token count'),
                        value: settings.stripCommentsFromCode,
                        onChanged: (value) {
                          context.read<SettingsCubit>().updateStripComments(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _pickDefaultLocation() {
    // TODO: Implement default location picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Default Export Location'),
        content: const Text('Feature coming soon: Browse for default export folder'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}