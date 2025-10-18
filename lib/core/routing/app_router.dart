import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/users/presentation/user_management_screen.dart';
import '../../features/notifications/presentation/notification_center_screen.dart';
import '../../features/products/presentation/product_list_screen.dart';
import '../../features/products/presentation/add_edit_product_screen.dart';
import '../../features/categories/presentation/category_screen.dart';
import '../../features/redemptions/presentation/redemption_list_screen.dart';

/// Router provider with auth state management
final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // If not logged in and not on login page, redirect to login
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // If logged in and on login page, redirect to home
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Login Route
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Home/Dashboard Route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // User Management Route
      GoRoute(
        path: '/users',
        name: 'users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      
      // Notifications Route
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationCenterScreen(),
      ),
      
      // Products Route
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListScreen(),
      ),
      
      // Add/Edit Product Route
      GoRoute(
        path: '/products/edit/:id',
        name: 'edit_product',
        builder: (context, state) {
          final productId = state.pathParameters['id'];
          return AddEditProductScreen(productId: productId);
        },
      ),
      
      GoRoute(
        path: '/products/add',
        name: 'add_product',
        builder: (context, state) => const AddEditProductScreen(),
      ),
      
      // Categories Route
      GoRoute(
        path: '/categories',
        name: 'categories',
        builder: (context, state) => const CategoryScreen(),
      ),
      
      // Redemptions Route
      GoRoute(
        path: '/redemptions',
        name: 'redemptions',
        builder: (context, state) => const RedemptionListScreen(),
      ),
    ],
    
    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('صفحة غير موجودة: ${state.matchedLocation}'),
      ),
    ),
  );
});



