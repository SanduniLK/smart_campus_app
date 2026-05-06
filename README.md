# 📱 Smart Campus Operations System

## 🎓 Project Overview

The **Smart Campus Operations System** is a production-level Flutter mobile application designed to modernize university services. It provides a centralized platform for students and staff to access real-time academic and campus-related information efficiently.

This project is developed as part of the **ICT4153 Mobile Application Development** module at the **University of Ruhuna (FOT)**.

---

## 🚀 Key Features

### 🔐 Authentication

* Role-based login (Student / Staff)
* Secure authentication (Mock / Firebase)

### 📅 Timetable Management

* View and manage personal schedules
* Organized daily and weekly views

### 🎉 Event Management

* Browse university events
* Register for events
* QR-based event confirmation (scan & generate)

### 🗺️ Campus Map

* Integrated location services
* Navigate campus using maps

### 📢 Announcements

* Real-time announcements via REST API
* Automatic updates

### 🔔 Notifications

* Push notifications for urgent updates
* Alerts for events and announcements

---

## 🏗️ Technical Architecture

This application follows **Clean Architecture** principles:

### 📂 Layers

* **Presentation Layer** → UI, Screens, Widgets
* **Business Logic Layer** → State management (Provider / Riverpod / Bloc)
* **Data Layer** → API services, local database
* **Repository Layer** → Data abstraction

---

## ⚙️ Advanced Technical Implementation

### 🔄 Navigation

* Named routes
* Nested navigation (BottomNavigationBar with independent stacks)
* Route guards (authentication-based routing)

### 🧠 State Management

* Provider / Riverpod / Bloc
* Separation of UI and business logic

### 💾 Data Management

* SQLite database (relational structure)

  * Users
  * Events
  * Registrations
* REST API integration
* Async/await handling
* Error & exception handling

### 📱 Device Features

* QR code scanning & generation
* Location services
* Push notifications

### ⚡ Performance Optimization

* Lazy loading / pagination
* Loading indicators
* Form validation
* Null safety

---

## 🗃️ Database Schema

### Tables:

* **Users**

  * id
  * name
  * role
  * email

* **Events**

  * id
  * title
  * date
  * location

* **Registrations**

  * id
  * userId (FK)
  * eventId (FK)

---

## 🌐 API Integration

* Fetch announcements from REST API
* Handle network errors and responses properly


---

## 🛠️ Tech Stack

* Flutter (Dart)
* SQLite
* REST APIs
* Firebase (optional)
* Provider / Riverpod / Bloc

---

## 📦 Installation

```bash
# Clone the repository
git clone https://github.com/your-username/smart-campus-app.git

# Navigate to project folder
cd smart-campus-app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 📸 Screenshots

*(Add your app screenshots here)*

---

## 🧪 Testing

* Unit Testing
* Widget Testing
* Manual Testing

---

## 📌 Future Improvements

* AI-based recommendations
* Offline mode enhancements
* Advanced analytics dashboard

---

## 📄 License

This project is developed for academic purposes.

---

## 🙌 Acknowledgment

Developed as part of **ICT4153 - Mobile Application Development**
Faculty of Technology, University of Moratuwa

---
