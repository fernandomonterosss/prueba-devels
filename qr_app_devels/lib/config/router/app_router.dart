import 'package:go_router/go_router.dart';
import 'package:qr_app_devels/presentation/screens/orders/new_order_page.dart';
import 'package:qr_app_devels/presentation/screens/screen.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => HomePage(
        location: state.uri.path,
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductListPage(),
        ),
        GoRoute(
          path: '/', 
          name: 'orders',
          builder: (context, state) => const OrderListPage()
        ),
        GoRoute(
          path: '/orders-pending', 
          name: 'orders-pending',
          builder: (context, state) => const OrderPendingListPage()
        ),
      ]
    ),
    GoRoute(
      path: '/order/new',
      builder: (context, state) => const NewOrderPage(),
    )
  ],
);