import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/settings_cubit.dart';
import '../widgets/settings_form_widget.dart';
import '../../data/models/app_settings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          // TODO: Add reset to defaults button
          IconButton(
            onPressed: () {
              // TODO: Implement reset to defaults
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
          ),
        ],
      ),
      body: BlocBuilder<SettingsCubit, AppSettings>(
        builder: (context, appSettings) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TODO: Add settings form sections
                Text(
                  'Export Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                // TODO: Add SettingsFormWidget
                // SettingsFormWidget(),
                
                SizedBox(height: 24),
                
                Text(
                  'Filter Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                // TODO: Add filter settings form
                
                SizedBox(height: 24),
                
                Text(
                  'Advanced Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                // TODO: Add advanced settings form
              ],
            ),
          );
        },
      ),
    );
  }
}