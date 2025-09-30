# WorkNomads Flutter App

A Flutter mobile application for managing uploads, authentication, and user interactions with a backend server.

---

## Table of Contents

- [Features](#features)  
- [Project Structure](#project-structure)  
- [Requirements](#requirements)  
- [Getting Started](#getting-started)  
- [Environment Variables](#environment-variables)  
- [API Endpoints](#api-endpoints)  
- [Authentication](#authentication)  
- [File Uploads](#file-uploads)  
- [Dependencies](#dependencies)  
- [Running the App](#running-the-app)  
- [Notes](#notes)

---

## Features

- User registration and login with JWT authentication.  
- Upload images and audio files to the backend server.  
- Display uploaded files in a list with progress indicators.  
- Secure storage of access and refresh tokens.  

---

## Project Structure

lib/
├── core/
│ ├── api/
│ │ ├── api_client.dart
│ │ └── api_endpoints.dart
├── features/
│ ├── auth/
│ │ ├── data/
│ │ ├── domain/
│ │ └── presentation/
│ ├── uploads/
│ │ ├── data/
│ │ │ ├── file_api.dart
│ │ │ └── file_repository.dart
│ │ ├── domain/
│ │ └── presentation/
├── main.dart
└── ...

---

## API Endpoints

| Feature             | Endpoint          | Method | Auth Required |
| ------------------- | ----------------- | ------ | ------------- |
| Register            | `/auth/register/` | POST   | No            |
| Login               | `/auth/token/`    | POST   | No            |
| Upload Image        | `/upload/image/`  | POST   | Yes (Bearer)  |
| Upload Audio        | `/upload/audio/`  | POST   | Yes (Bearer)  |
| List Uploaded Files | `/upload/files/`  | GET    | Yes (Bearer)  |

---

## Authentication

Access tokens are stored securely using flutter_secure_storage.

Refresh tokens are also stored to maintain session persistence.

All authenticated requests include the header:

    Authorization: Bearer <access_token>
