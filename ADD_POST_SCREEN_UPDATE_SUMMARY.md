# Add Post Screen - API Integration Update

## Overview

The `add_post_screen.dart` has been completely updated to integrate with the new comprehensive trip creation API. The screen now supports all the trip data fields that match the exact JSON structure you provided.

## Key Updates

### 1. **New Imports**
- Added `flutter_bloc` for state management
- Added trip model classes (`TripLocation`, `RouteGeoJSON`, `Distance`, `TripDuration`)
- Added `PostsBloc` and `PostsApiHelper` for API integration

### 2. **Enhanced Form Fields**
- **Trip Type Selection**: Radio buttons for "Load" vs "Truck"
- **Start & End Dates/Times**: Separate date and time pickers for trip start and end
- **Vehicle & Driver Fields**: Optional vehicle ID and driver ID inputs
- **Self-Drive Toggle**: Switch to indicate if user will drive themselves
- **Goods & Weight**: Goods type ID and weight input fields
- **Enhanced Validation**: Better validation for all fields

### 3. **API Integration**
- **BlocListener**: Listens to `PostsBloc` states for success/error handling
- **Comprehensive Trip Creation**: Creates trips with all the data structure you specified
- **Automatic Calculations**: Calculates distance and duration based on coordinates and dates
- **Route GeoJSON**: Generates GeoJSON route data from start/end coordinates

### 4. **Enhanced UI Components**

#### **Trip Type Selector**
```dart
Widget _buildPostTypeSelector() {
  // Radio buttons for Load vs Truck selection
}
```

#### **Self-Drive Toggle**
```dart
Widget _buildSelfDriveToggle() {
  // Switch to indicate self-driving preference
}
```

#### **Enhanced Form Validation**
- Validates map coordinates are selected
- Validates trip dates and times
- Validates weight input format
- Shows appropriate error messages

### 5. **API Data Structure**

The form now creates trips with the exact structure you provided:

```json
{
  "title": "Fresh Vegetables Delivery to Kochi",
  "description": "Transporting fresh vegetables from Pathanamthitta to Kochi via Kottayam.",
  "tripStartLocation": {
    "address": "Pathanamthitta Bus Stand, Kerala",
    "coordinates": [76.7704, 9.2645]
  },
  "tripDestination": {
    "address": "Ernakulam South Railway Station, Kochi, Kerala",
    "coordinates": [76.2875, 9.9674]
  },
  "routeGeoJSON": {
    "type": "LineString",
    "coordinates": [
      [76.7704, 9.2645],
      [76.2875, 9.9674]
    ]
  },
  "vehicle": "68ac5e670d66969b0f50b125",
  "selfDrive": true,
  "driver": "68ac5aba31cc29079926f2d9",
  "distance": {
    "value": 135.5,
    "text": "135.5 km"
  },
  "duration": {
    "value": 150,
    "text": "2 hours 30 mins"
  },
  "goodsType": "684aa733b88048daeaebff93",
  "weight": 25,
  "tripStartDate": "2025-08-26T09:00:00.000Z",
  "tripEndDate": "2025-08-26T13:30:00.000Z"
}
```

### 6. **Form Sections**

1. **Trip Type**: Load or Truck selection
2. **Start Location**: Address input + map coordinate picker
3. **Destination**: Address input + map coordinate picker
4. **Trip Details**: Start/end dates and times
5. **Vehicle & Driver**: Vehicle ID, Driver ID, self-drive toggle
6. **Goods & Weight**: Goods type ID and weight
7. **Trip Content**: Title and description

### 7. **Smart Features**

#### **Automatic Calculations**
- **Distance**: Calculated from start/end coordinates
- **Duration**: Calculated from start/end dates
- **Default End Time**: 4 hours after start if not specified

#### **Enhanced Validation**
- Ensures map coordinates are selected
- Validates required dates and times
- Validates weight format
- Shows user-friendly error messages

#### **State Management**
- Uses `BlocListener` for API response handling
- Shows success/error messages
- Automatically clears form on successful creation

### 8. **User Experience Improvements**

- **Clear Section Headers**: Organized form into logical sections
- **Optional Field Indicators**: Shows which fields are optional
- **Better Error Messages**: More specific validation messages
- **Loading States**: Handled by BLoC state management
- **Form Reset**: Automatically clears form after successful submission

### 9. **API Integration Flow**

1. **User fills form** → Form validation
2. **User submits** → Creates trip data objects
3. **API call** → `PostsApiHelper.createPost()`
4. **BLoC handles** → Success/error states
5. **UI responds** → Shows messages and clears form

### 10. **Backward Compatibility**

The screen maintains all existing functionality while adding new features:
- Map coordinate selection still works
- Date/time pickers still function
- Form validation is enhanced
- UI styling remains consistent

## Usage

The updated screen now provides a comprehensive trip creation experience that:

1. **Collects all required trip data** in a user-friendly interface
2. **Validates input** with helpful error messages
3. **Creates trips** with the exact API structure you specified
4. **Handles API responses** with proper state management
5. **Provides feedback** to users on success/error states

The form is now ready to create trips with the complete data structure you provided, including locations, routes, vehicle information, timing, and all other trip details.
