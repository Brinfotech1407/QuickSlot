# QuickSlot Flutter App

Flutter client for QuickSlot, a mini sports slot booking app. It talks to the Node.js backend and supports venue browsing, date-based slot availability, booking, conflict handling, and booking cancellation.

## Features

- Simple user selection using backend seed users.
- Venue list with selected venue details.
- Date picker and hourly slot grid.
- Clear available/booked slot states.
- Booking confirmation flow.
- Graceful `409` conflict handling when a slot is taken by another user.
- My Bookings list with cancel action.
- Loading, error, and empty states across the main flows.

## Backend Requirement

Start the backend first from:

```powershell
F:\JobWork\ScoutInfotech\quick-slot-backend
```

Then run:

```powershell
npm run db:reset
npm run dev
```

The API should be available on `http://localhost:3000`.

## Running Flutter

For Android emulator, the default API URL is already:

```text
http://10.0.2.2:3000
```

Run:

```powershell
flutter run
```

For Chrome, Windows desktop, or a physical device on the same network, pass the backend URL explicitly:

```powershell
flutter run --dart-define API_BASE_URL=http://localhost:3000
```

For a physical phone, replace `localhost` with your computer's LAN IP:

```powershell
flutter run --dart-define API_BASE_URL=http://192.168.1.10:3000
```

## State Management Choice

The app uses `flutter_bloc` with `BookingCubit`.

This matches the boilerplate already present in the project and keeps async UI state predictable:

- Initial app load fetches users, venues, slots, and bookings.
- Booking and cancellation side effects are centralized.
- Loading, error, empty, success, and conflict states are explicit.
- On `409 Slot already booked`, the Cubit refreshes the slot grid and shows a clear message.

## Useful Checks

```powershell
flutter analyze
flutter test
```

Backend race-condition proof:

```powershell
cd F:\JobWork\ScoutInfotech\quick-slot-backend
npm run test:concurrency
```
