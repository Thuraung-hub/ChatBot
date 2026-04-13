class AppConstants {
  static const apiTimeoutSeconds = 30;
  static const quickCheckoutDelayMilliseconds = 350;
  static const deliveryLeadDays = 5;
  static const chatAutoScrollDelayMilliseconds = 200;
  static const chatScrollAnimationMilliseconds = 300;
  static const chatScrollOffset = 200.0;

  static const rootRoute = '/';
  static const homeRoute = '/home';
  static const loginRoute = '/login';
  static const signupRoute = '/signup';
  static const cartRoute = '/cart';
  static const profileRoute = '/profile';
  static const chatRoute = '/chat';
  static const adminRoute = '/admin';
  static const productRoute = '/product';

  static const usersCollection = 'users';
  static const chatCollection = 'chat';
  static const productsCollection = 'products';
  static const cartCollection = 'cart';
  static const ordersCollection = 'orders';
  static const commentsCollection = 'comments';

  static const adminRole = 'admin';
  static const subAdminRole = 'sub-admin';
  static const customerRole = 'customer';
  static const processingOrderStatus = 'processing';
}

enum Routes {
  root,
  home,
  login,
  signup,
  cart,
  profile,
  chat,
  admin,
  product,
}

extension RoutesPath on Routes {
  String get path {
    switch (this) {
      case Routes.root:
        return '/';
      case Routes.home:
        return '/home';
      case Routes.login:
        return '/login';
      case Routes.signup:
        return '/signup';
      case Routes.cart:
        return '/cart';
      case Routes.profile:
        return '/profile';
      case Routes.chat:
        return '/chat';
      case Routes.admin:
        return '/admin';
      case Routes.product:
        return '/product';
    }
  }
}
