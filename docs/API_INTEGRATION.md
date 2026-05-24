# API Integration Guide

Ei document ta explain kore ei Flutter app-e API integration kivabe kora hoyeche. GitHub-e reviewer/developer jeno easily bujhte pare, tai flow ta simple language-e rakha holo.

## Tech Stack

- Flutter UI
- GetX for state management and navigation
- GetStorage for local token/session storage
- `http` package for REST API calls
- JSON request/response using `jsonEncode` and `jsonDecode`

## Main Flow

App-er API flow generally ei pattern follow kore:

```text
UI Screen
  -> GetX Controller
  -> Service class
  -> Backend API
  -> Service returns Map response
  -> Controller updates loading/data/error state
  -> UI updates with Obx()/setState()
```

Example:

```text
LoginScreen
  -> AuthController.login()
  -> AuthService.login()
  -> POST /api/auth/login
  -> token saved in GetStorage
  -> navigate to MainScreen
```

## Base URL

Base API URL ek jaygay rakha hoyeche:

```dart
// lib/services/app_url.dart
class AppUrl {
  static const String baseUrl = 'https://.../api';
}
```

Service file gulo ei base URL use kore endpoint build kore:

```dart
static const String _baseUrl = '${AppUrl.baseUrl}/auth';
```

Tai backend URL change korte hole normally sudhu `AppUrl.baseUrl` update korlei hoy.

## Folder Structure

Important API related folders:

```text
lib/services/
  API call, headers, request body, response parsing

lib/controller/
  Loading state, token collect, service call, UI data update

lib/views/
  User interface, button action, Obx/setState rendering
```

## Authentication and Token

Token save/read kora hoy `AuthController` er maddhome.

Storage keys:

```dart
auth_token
auth_refresh_token
auth_user
```

Token getter:

```dart
String? get token => _box.read<String>('auth_token');
```

Protected API call korar age controller token read kore:

```dart
final token = _authController.token;
if (token == null) return;
```

Then service-e token pathano hoy.

## Headers

Most protected API requests ei header use kore:

```dart
{
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
}
```

Public API, like login/signup, token chara header use kore.

## Service Layer Pattern

Service class direct API hit kore. Example:

```dart
final response = await http.post(
  Uri.parse('$_baseUrl/login'),
  headers: _headers,
  body: jsonEncode({
    'email': email,
    'password': password,
  }),
);
```

Then response parse kore common format-e return kore:

```dart
{
  'success': true,
  'data': ...
}
```

or

```dart
{
  'success': false,
  'message': 'Error message'
}
```

Ei pattern-er jonno controller easily check korte pare:

```dart
if (result['success'] == true) {
  // update data
} else {
  // show error
}
```

## Controller Layer Pattern

Controller API logic manage kore:

- loading start/end
- token check
- service call
- response data save
- error snackbar
- navigation

Example login flow:

```dart
Future<void> login({
  required String email,
  required String password,
}) async {
  isLoading.value = true;

  final result = await AuthService.login(
    email: email,
    password: password,
  );

  if (result['success'] == true) {
    _saveSession(result);
    Get.offAllNamed(RouteHelper.main);
  } else {
    _showError(result['message'] ?? 'Login failed');
  }

  isLoading.value = false;
}
```

## UI Layer Pattern

UI normally controller method call kore and loading state observe kore.

Example:

```dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }

  return ContentWidget();
});
```

Button press korle:

```dart
onPressed: () {
  authController.login(
    email: emailController.text,
    password: passwordController.text,
  );
}
```

## Example: Journey API Integration

Journey feature-e flow:

```text
CreateJourneyPage
  -> JourneyController.createJourney()
  -> JourneyService.createJourney()
  -> POST /api/journeys
  -> controller refreshes journey list
  -> UI shows journey card in HomeScreen
```

Controller token ney:

```dart
final token = _authController.token;
if (token == null) {
  return {'success': false, 'message': 'Not authenticated'};
}
```

Service request body:

```dart
{
  'journeyName': journeyName,
  'description': description,
  'imageUrl': imageUrl,
}
```

## Example: Media API Integration

MediaController app start er por media fetch kore:

```text
MediaController.fetchAllMedia()
  -> MediaService.getAllMedia()
  -> GET /api/media
  -> group media by category name
```

Then UI category name diye media use kore:

```dart
mediaByCategory['Bilateral Stimulation img']
mediaByCategory['Bilateral Stimulation Sound']
```

## Main API Modules

| Module | Service | Controller | Purpose |
|---|---|---|---|
| Auth | `AuthService` | `AuthController` | signup, login, OTP, logout |
| Profile | `ProfileService` | `ProfileController` | user profile, edit profile |
| Journey | `JourneyService` | `JourneyController` | create/list/update journey |
| Media | `MediaService` | `MediaController` | videos, audios, images |
| CBT | `CbtService` | screen-level logic | journey map/formulation |
| EMDR Session | `EmdrSessionService` | Session 4 screen logic | EMDR companion flow |
| Session Progress | `SessionProgressService` | `SessionProgressController` | session completion progress |
| Bilateral | `BilateralService` | `BilateralController` | bilateral settings |
| Subscription | `SubscriptionService` | `SubscriptionController` | plans, subscribe/apply |
| Support | `SupportService` | `SupportController` | support tickets |
| Progress Trackers | `SymptomTrackerService`, `QuestionnaireService` | screen/controller logic | tests/results |

## Error Handling

Service layer try/catch use kore network/parsing error handle kore:

```dart
catch (e) {
  return {
    'success': false,
    'message': 'Network error. Please try again.',
  };
}
```

Controller layer snackbar show kore:

```dart
Get.snackbar('Error', message);
```

## Local Storage Usage

GetStorage use hoy:

- auth token save korte
- refresh token save korte
- user data save korte
- local draft/progress save korte
- calm place data locally cache korte

Example:

```dart
box.write('calm_place_saved', true);
box.write('calm_place_description', description);
```

## How To Add New API

New API integration korte ei steps follow korte hoy:

1. `lib/services/` e new service method add koro.
2. Endpoint URL `AppUrl.baseUrl` diye build koro.
3. Token lagle `Authorization: Bearer $token` header add koro.
4. Request body `jsonEncode()` diye pathao.
5. Response `jsonDecode()` kore `{success, data/message}` format-e return koro.
6. Controller-e token read kore service method call koro.
7. Controller-e loading/data/error state update koro.
8. UI screen-e `Obx()` or `setState()` diye result show koro.

Short example:

```dart
// Service
static Future<Map<String, dynamic>> getSomething(String token) async {
  final response = await http.get(
    Uri.parse('${AppUrl.baseUrl}/something'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final body = jsonDecode(response.body);
  return {
    'success': response.statusCode >= 200 && response.statusCode < 300,
    'data': body['data'],
    'message': body['message'],
  };
}
```

```dart
// Controller
Future<void> fetchSomething() async {
  final token = _authController.token;
  if (token == null) return;

  isLoading.value = true;
  final result = await SomeService.getSomething(token);

  if (result['success'] == true) {
    data.value = result['data'];
  } else {
    Get.snackbar('Error', result['message'] ?? 'Failed');
  }

  isLoading.value = false;
}
```

## Important Notes

- API URL hardcode na kore `AppUrl.baseUrl` use kora hoy.
- Token direct UI theke handle kora hoy na; controller theke token service-e pass hoy.
- Service layer UI navigation kore na; navigation controller/screen side-e hoy.
- API response always predictable Map format-e anar try kora hoy.
- Protected endpoints always Bearer token use kore.

