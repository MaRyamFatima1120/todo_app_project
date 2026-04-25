import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // Table name
  final String _tableName = 'tasks';

  // Get all tasks
  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from(_tableName)
          .select('id, title, description, "timeStamp", completed, user_id')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return [];
    }
  }

  // Add a task
  Future<Map<String, dynamic>?> addTask(Map<String, dynamic> task) async {
    try {
      final response =
          await _supabase.from(_tableName).insert(task).select().single();
      return response;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return null;
    }
  }

  // Update a task
  Future<void> updateTask(String id, Map<String, dynamic> updates) async {
    try {
      await _supabase.from(_tableName).update(updates).eq('id', id);
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Auth: Sign Up
  Future<AuthResponse> signUp(
      String email, String password, String username) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  // Auth: Sign In
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Auth: Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Auth: Reset Password
  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-callback/',
    );
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Log User Events (Login, Logout, Register)
  Future<void> logEvent(String eventType, String email) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase.from('user_logs').insert({
          'user_id': user.id,
          'email': email,
          'event_type': eventType,
        });
      }
    } catch (e) {
      debugPrint('Error logging event: $e');
    }
  }

  // Create User Profile in 'profiles' table
  Future<void> createProfile(
      String userId, String username, String email, String? avatarUrl) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'username': username,
        'email': email,
        'avatar_url': avatarUrl,
      });
      debugPrint('Profile created successfully for $username');
    } catch (e) {
      debugPrint('CRITICAL: Error creating profile: $e');
      // Agar yahan error aa raha hai toh check karein ke 'profiles' table bani hai ya nahi
    }
  }

  // Upload Profile Image to Supabase Storage
  Future<String?> uploadAvatar(String userId, File file) async {
    try {
      final String path = '$userId.png';

      // Upload bytes to 'avatars' bucket
      final bytes = await file.readAsBytes();

      await _supabase.storage.from('avatars').upload(
            path,
            file, // Try passing the file directly again with the correct path
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final String publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(path);
      debugPrint('UPLOAD SUCCESS: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('UPLOAD FAILED: $e');
      // Agar yahan '403' ya 'Permission Denied' aa raha hai toh Dashboard mein Policy check karein
      return null;
    }
  }

  // Get Signed URL for private avatar (valid for 1 hour)
  Future<String?> getAvatarUrl(String userId) async {
    try {
      final String path = 'avatars/$userId.png';
      final signedUrl =
          await _supabase.storage.from('avatars').createSignedUrl(path, 3600);
      return signedUrl;
    } catch (e) {
      debugPrint('Error getting signed URL: $e');
      return null;
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', userId).single();
      return data;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  // Update profile avatar URL in database
  Future<void> updateProfileAvatar(String userId, String url) async {
    try {
      await _supabase
          .from('profiles')
          .update({'avatar_url': url}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating profile avatar: $e');
    }
  }

  // Upload Cover Image to Supabase Storage
  Future<String?> uploadCover(String userId, File file) async {
    try {
      final String path = 'covers/$userId.png';
      await _supabase.storage.from('avatars').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      final String publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('UPLOAD COVER FAILED: $e');
      return null;
    }
  }

  // Update profile cover URL in database
  Future<void> updateProfileCover(String userId, String url) async {
    try {
      await _supabase
          .from('profiles')
          .update({'cover_url': url}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating profile cover: $e');
    }
  }

  // Update profile Name in database
  Future<void> updateProfileName(String userId, String name) async {
    try {
      await _supabase
          .from('profiles')
          .update({'username': name}).eq('id', userId);
    } catch (e) {
      debugPrint('Error updating profile name: $e');
    }
  }

  // Get About Us content
  Future<List<Map<String, dynamic>>> getAboutUs() async {
    try {
      final response = await _supabase
          .from('about_us')
          .select()
          .order('order_index', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching About Us content: $e');
      return [];
    }
  }

  // Get About Us content Stream (Real-time)
  Stream<List<Map<String, dynamic>>> getAboutUsStream() {
    return _supabase
        .from('about_us')
        .stream(primaryKey: ['id'])
        .order('order_index', ascending: true);
  }

  // Get FAQ content Stream (Real-time)
  Stream<List<Map<String, dynamic>>> getFAQsStream() {
    return _supabase
        .from('faqs')
        .stream(primaryKey: ['id'])
        .order('order_index', ascending: true);
  }

  // Submit Help and Feedback
  Future<bool> submitFeedback(Map<String, dynamic> feedback) async {
    try {
      await _supabase.from('help_feedback').insert(feedback);
      return true;
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      return false;
    }
  }
}
// Updated at 2026-04-24

