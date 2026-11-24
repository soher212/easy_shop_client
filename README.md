# Easy Shop Client

Easy Shop Client is the customer-facing Flutter application for the Easy Shop store system. Customers can browse the catalog, manage favorites and a cart, place orders, select a payment method and delivery location, and view their orders and profile.

## Overview

Easy Shop consists of the merchant app and this client app. Merchants manage categories and products, which are intended to appear in the client app through the shared server API. The customer screens and order/payment flows are implemented and have been exercised. The server is currently unavailable, so the two apps do not share live catalog or order data in the current setup.

## Customer Journey and Implemented Features

### Authentication

- Splash, sign-in, registration, OTP verification, and registration success screens.
- Validation for full name, email, Egyptian phone number, and password.
- API integration is configured for registration, sign-in, OTP verification, OTP resend, and sign-out.
- Session tokens are stored securely; a saved session routes the app to the home screen.

### Store and Catalog

- Home screen with category and product browsing.
- Product cards, product details, and quantity selection.
- Add products to favorites and remove them.
- Shopping cart with item quantities and a calculated total.

### Checkout and Payment

- Checkout summary for cart contents and order total.
- Cash on delivery requires the customer to select a delivery location on the map.
- Card checkout opens Paymob inside an in-app WebView and handles success, failure, or pending results.
- A mock order receives a generated code, appears in the orders screen, and clears the cart after placement.
- Both cash and card flows were exercised with test data.

### Customer Profile

- View and edit customer profile information.
- Select a profile image from the device.
- Reusable map-based location selection for flows that require coordinates.

## Technology Stack

| Area | Technologies |
| --- | --- |
| Application | Flutter, Dart |
| State management | `flutter_bloc` / Cubit |
| Dependency injection | GetIt |
| Networking | Dio, `pretty_dio_logger` |
| Session storage | `flutter_secure_storage` |
| Maps and location | `flutter_map`, `latlong2`, `geolocator` |
| Profile images | `image_picker` |
| Payment page | `webview_flutter`, Paymob Intention API |
| Configuration | `flutter_dotenv` |

## Project Structure

```text
lib/
├── core/                 # Networking, secure storage, DI, routing, theme, shared helpers
└── features/
    ├── auth/             # Registration, sign-in, and OTP
    ├── splash/           # Application entry screen
    ├── home/             # Home screen and navigation tabs
    ├── products/         # Product catalog and details
    ├── categories/       # Category browsing
    ├── favorites/        # Favorites
    ├── cart/             # Shopping cart
    ├── checkout/         # Order creation and payment selection
    ├── payment/          # Paymob checkout and result handling
    ├── orders/           # Customer orders
    ├── profile/          # Customer profile
    └── maps/             # Location selection
test/                     # Authentication, home, cart, checkout, and profile tests
assets/                   # Application logo and shared images
```

Domain entities, repository contracts, and use cases are separated from the presentation and data layers. Cubits manage screen state, and GetIt registers the dependencies and repository implementations used by the app.

## Integration and Current Data Status

The app reads `API_BASE_URL` and `API_KEY` from `.env`. Its API constants define client routes for authentication, profile, categories, products, favorites, carts, orders, and payment. The server is unavailable, so the real response formats and persistence behavior of those routes cannot currently be verified.

The current mock catalog contains ten design sample products and five sample categories. Favorites, cart, orders, and profile use in-memory mock repositories. These customer-side records are temporary, are not stored in a database, and are not synchronized with the merchant app. The products and categories currently displayed are design fixtures, not products published by a merchant through the server.

### Paymob

The payment service creates a Paymob Intention, opens the checkout page in an in-app WebView, and reads the returned payment result. It uses a separate Dio client so the course API key is not sent to Paymob. Its configuration variables are `PAYMOB_SECRET_KEY`, `PAYMOB_PUBLIC_KEY`, and `PAYMOB_CARD_INTEGRATION_ID`.

This direct Paymob integration is configured for training and test payments. The secret key is included in the Flutter app configuration and can be extracted from a distributed app; the integration is not suitable for production payments. A successful test checkout does not mean that the mock order was persisted by the Easy Shop server.

## Tests

The existing test suite covers authentication screens, home, cart and product details, checkout and orders, and profile flows.

```bash
flutter pub get
flutter test
dart analyze
```

## Running the Application

The project uses Flutter with Dart SDK constraint `^3.12.2`. Without a saved session, it starts on the splash and authentication flow; with a saved session, it opens the home screen.

```bash
flutter run
```

`.env` contains local API and payment configuration and is excluded from Git. No secret values are included in this README.
