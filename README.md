Flutter App Link : https://magnetic-signer-466310-b9.web.app/

Backend Link (Agents) : https://city-pulse-backend-service-129861535450.asia-south1.run.app

# 🏙️ Agentic Pulse City App

A modern, intelligent city management and safety application built with Flutter, designed to transform urban data into actionable insights for citizens and authorities.

## 🌟 Features

### 🏠 **Smart Home Dashboard**
- Real-time city status monitoring
- Weather integration with location-based updates
- Quick access to essential services
- Community alerts and notifications
- Safety tips and recommendations

### 🚨 **Emergency Response System**
- One-tap emergency services access
- Direct dialing to police (100), ambulance (108), fire (101)
- Women helpline (1091) and child helpline (1098)
- Automatic location sharing with emergency contacts
- Real-time incident reporting

### 🗺️ **Intelligent Navigation**
- Live traffic monitoring with crowd insights
- Smart route planning with traffic avoidance
- Turn-by-turn navigation with real-time updates
- Multiple transport modes (Car, Walk, Bike)
- Traffic incident overlay on maps

### 📊 **City Dashboard**
- Real-time sentiment analysis across city areas
- Incident mapping with user-reported data
- Interactive Google Maps integration
- Color-coded traffic and sentiment indicators
- Professional data visualization

### �� **Smart Planner**
- AI-powered event scheduling
- Weather-aware planning suggestions
- Traffic-aware travel recommendations
- Google Calendar integration
- Smart insights and productivity tips

### 👥 **Community Features**
- Real-time community alerts
- Local event discovery
- Neighborhood safety updates
- Community engagement tools
- Event recommendations

### �� **AI Assistant**
- Gemini AI-powered intelligent responses
- Voice and text interaction
- City-specific queries and recommendations
- Real-time assistance for urban navigation
- Smart suggestions for daily activities

### �� **Modern UI/UX**
- Professional, clean design
- Consistent blue theme (#4299E1)
- Responsive layout for all screen sizes
- Smooth animations and transitions
- Intuitive navigation

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Maps**: Google Maps Flutter
- **Charts**: FL Chart
- **AI**: Google Generative AI (Gemini)
- **Camera**: Web Camera API
- **Voice**: Speech-to-Text & Text-to-Speech
- **Platform**: Web, iOS, Android

## �� Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_maps_flutter: ^2.5.0
  fl_chart: ^0.65.0
  google_generative_ai: ^0.3.0
  speech_to_text: ^6.6.0
  flutter_tts: ^3.8.5
  url_launcher: ^6.2.5
  universal_html: ^2.2.4
  geolocator: ^10.1.0
  table_calendar: ^3.0.9
  intl: ^0.18.1
  flutter_dotenv: ^5.1.0
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Google Maps API Key
- Gemini AI API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/agentic_pulse_city_app.git
   cd agentic_pulse_city_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   cp env.example .env
   ```
   
   Add your API keys to `.env`:
   ```
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   GEMINI_API_KEY=your_gemini_api_key
   ```

4. **Configure web camera permissions**
   
   Add to `web/index.html`:
   ```html
   <script>
     if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
       console.log('Camera API supported');
     }
   </script>
   ```

5. **Run the application**
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For mobile
   ```

## 📱 Screenshots

### Home Dashboard

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 06 22" src="https://github.com/user-attachments/assets/0db2ee3e-d2a1-4871-8e96-4d8bb985d312" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 17 55" src="https://github.com/user-attachments/assets/09709131-51cd-4e4e-9dfd-92d847f8c8ec" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 18 05" src="https://github.com/user-attachments/assets/0ca606a2-471e-4ab5-995d-6a59cedbb892" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 18 13" src="https://github.com/user-attachments/assets/4cb225f3-bc25-4fdd-a91b-c3ad45ec37b8" />

### Navigation

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 09 28" src="https://github.com/user-attachments/assets/fe7738da-6e96-41f3-abab-93614b5f1363" />
<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 16 40" src="https://github.com/user-attachments/assets/4df31376-135b-4ba3-bae6-72e8acdacae9" />

### One-tap Civic Reporting

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 13 57" src="https://github.com/user-attachments/assets/ccc49d12-78b3-4bf3-82e3-21caf5b76d49" />

### City Dashboard

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 10 00" src="https://github.com/user-attachments/assets/69739120-e7fe-4835-a55f-4fe2033bc6ee" />

### AI Assistant

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 21 56" src="https://github.com/user-attachments/assets/517fe1f1-ff89-47a2-b3ab-69f516026995" />


### Calendar

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 11 38" src="https://github.com/user-attachments/assets/d603a45a-eb2a-4b47-942c-f50a5bb5872e" /> <img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 12 01" src="https://github.com/user-attachments/assets/e583d26f-d502-4067-bff2-56cd10375c88" /><img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 13 17" src="https://github.com/user-attachments/assets/27ab57a4-38c7-4ff4-9df6-884898112378" />

### Profile

<img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 13 33" src="https://github.com/user-attachments/assets/783acebc-0ad5-4303-a09b-b46f18109ba6" /> <img width="200" height="500" alt="Simulator Screenshot - iPhone 16 Pro - 2025-07-27 at 09 17 28" src="https://github.com/user-attachments/assets/bede76a2-dff5-493d-b2e5-828913c7aa1d" />


## ��️ Project Structure


lib/
├── main.dart # App entry point
├── models/ # Data models
│ ├── event_data.dart
│ ├── incident_data.dart
│ └── sentiment_data.dart
├── screens/ # UI screens
│ ├── home_screen.dart # Main dashboard
│ ├── dashboard_screen.dart # City analytics
│ ├── planner_screen.dart # Smart planner
│ ├── profile_screen.dart # User profile
│ ├── report_incident_screen.dart
│ ├── traffic_navigation_screen.dart
│ ├── crowd_insights_screen.dart
│ └── ai_assistant_screen.dart
└── services/ # Business logic
├── calendar_service.dart
├── config_service.dart
└── google_calendar_service.dart
