# WoLong Home System

A comprehensive community management platform with web, Android, and iOS applications.

## Project Overview

WoLong Home System is a multi-platform community system designed for member management, content sharing, activities, Q&A, product exchange, and more. The system includes a point-based integral system to reward user participation.

## Project Structure

```
dmy-wl-home-system/
├── Android/                 # Android application
│   ├── AndroidManifest.xml
│   ├── res/                 # Resources (layouts, values, drawables)
│   └── src/                 # Java source code
├── iOS/                     # iOS application
│   └── wljy/                # Objective-C source files
├── Web/                     # JSP web application
│   └── wljy/                # JSP pages and resources
│       ├── admin/           # Admin panel
│       ├── css/             # Stylesheets
│       ├── img/             # Images
│       ├── inc/             # Includes
│       ├── js/              # JavaScript
│       ├── phone/           # Mobile-specific pages
│       └── WEB-INF/         # Web configuration
└── Database/                # Database scripts
    └── WoLongDatabase.sql   # Oracle database schema
```

## Features

### Core Features

1. **Member Management**
   - User registration and login
   - Profile management
   - Password change
   - Member privileges and roles

2. **Activity System**
   - Activity posting and management
   - Activity types (Member activities, Official activities)
   - Activity registration/entry
   - Activity comments and evaluations
   - Activity image gallery

3. **Content Sharing**
   - Share posts with images and videos
   - Comment on shares
   - Evaluate shares (like/dislike)
   - Personal share management

4. **Study & Q&A**
   - Post questions
   - Answer questions
   - Question categories (Professional knowledge, Enterprise related, General)
   - Reward system with integrals

5. **FAQ (Frequently Asked Questions)**
   - Browse FAQ entries
   - Post new FAQ
   - Add answers

6. **Product Exchange**
   - Browse products
   - Exchange with integral points
   - Shopping cart
   - Order management

7. **Feedback System**
   - Submit feedback/suggestions
   - Track feedback status

8. **Media Management**
   - Photo upload and gallery
   - Video upload and playback
   - File downloads

9. **Personal Collections**
   - Save favorite content
   - Manage collections

10. **Integral/Points System**
    - Earn points for various activities
    - Point history tracking
    - Redeem points for products

## Technology Stack

### Web Application
- **Frontend**: HTML, CSS, JavaScript, JSP
- **Backend**: Java/JSP
- **Database**: Oracle Database
- **Server**: JSP Servlet Container

### Android Application
- **Language**: Java
- **Min SDK**: 11 (Android 3.0)
- **Target SDK**: 17 (Android 4.2)

### iOS Application
- **Language**: Objective-C
- **Framework**: UIKit

## Database Schema

The system uses Oracle Database with the following main tables:

### User & Membership
- `MEMBERINFO` - Member information
- `MANAGERINFO` - Admin/manager information
- `MEMBERLOGINLIST` - Login history
- `INTEGRALLOG` - Points transaction history

### Content Management
- `ACTIVITY_INFO` - Activities
- `ACTIVITY_COMMENT` - Activity comments
- `ACTIVITY_EVAL` - Activity evaluations
- `SHARE_INFO` - Shared content
- `SHARE_COMMENT` - Share comments
- `SHARE_EVAL` - Share evaluations

### Q&A System
- `PROBLEM_QINFO` - Questions
- `PROBLEM_AINFO` - Answers
- `STUDY_QINFO` - Study questions
- `STUDY_AINFO` - Study answers
- `FAQ_*` - FAQ entries

### E-Commerce
- `PRODUCT_INFO` - Products
- `PRODUCT_IMAGE` - Product images
- `PRODUCT_TYPE` - Product categories
- `ORDER_PRODUCT` - Orders

### Media
- `DATA_INFO` - Uploaded files
- `MEMBER_DATA` - Member uploads
- `MEMBER_IMAGE` - Member images

### Other
- `COLLECTION_INFO` - User collections
- `OPINION` - Feedback/suggestions

## Installation

### Prerequisites
- Oracle Database 11g or later
- Java Development Kit (JDK) 7+
- Android SDK (for Android app)
- Xcode (for iOS app)
- Web application server (Tomcat/WebLogic)

### Database Setup
1. Create an Oracle database instance
2. Run the SQL script: `Database/WoLongDatabase.sql`
3. The script will create all required tables and default data

### Web Application
1. Deploy the `Web/wljy` directory to your JSP server
2. Configure database connection in `connection.jsp`
3. Access the application through your server

### Android Application
1. Import the Android project into Android Studio
2. Configure the API endpoint to point to your web server
3. Build and install on device

### iOS Application
1. Open `iOS/wljy.xcodeproj` in Xcode
2. Configure the API endpoint to point to your web server
3. Build and install on device

## API Endpoints (Web)

| Feature | Endpoint | Description |
|---------|----------|-------------|
| Login | `login.jsp` | User authentication |
| Main | `main.jsp` | Main dashboard |
| Activities | `single.jsp` | Activity list |
| Share | `share.jsp` | Content sharing |
| Study | `study.jsp` | Learning/Q&A |
| FAQ | `faq.jsp` | FAQ browsing |
| Exchange | `exchange.jsp` | Product exchange |
| Feedback | `feedback.jsp` | User feedback |
| Profile | `person.jsp` | User profile |

## User Roles

- **Regular Member**: Basic access to all features
- **Manager/Admin**: Additional administrative capabilities

## Integral Points System

Users earn points for various activities:
- Daily login
- Posting activities
- Uploading study materials
- Sharing content
- Answering questions
- Participating in events

Points can be redeemed for products in the exchange system.

## License

This project is provided as-is for educational and development purposes.


