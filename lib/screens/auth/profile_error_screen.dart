import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kipgo/controllers/profile_provider.dart';
import 'package:provider/provider.dart';

class ProfileErrorScreen extends StatelessWidget {
  const ProfileErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await profileProvider.reloadProfile();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 80),

              Icon(
                Icons.cloud_off_rounded,
                size: 100,
                color: Colors.grey.shade400,
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  "Unable to load your profile",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Please check your internet connection or try again.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await profileProvider.reloadProfile();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text("Sign out"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
