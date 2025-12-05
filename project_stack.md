pcIST Frontend App:

**Product Focus:** Streamlining club operations for pcIST through a unified platform. The project's core focuses are: robust event and member management, automated PAD and invoice generation with secure auditing, and a real-time tracker for over 30 online competitive programming contests.

**Key Features & Services:**

*   **Authentication & User Management:** Secure user registration and login using a token-based system with OTP verification. It includes user role management and an admin dashboard for user administration.
*   **Event Management:** Allows for the creation, management, and display of events, including setting event details, managing event payments, and viewing past and upcoming events.
*   **PAD and Invoice Automation:** Automates the generation of PAD (Pre-Authorized Debit) and invoices. This includes creating, maintaining a history of, and downloading these documents in PDF format, with an auditing feature for downloaded documents.
*   **Financial Document Management:** Utilizes Cloudinary for storing and retrieving PAD PDFs, ensuring a reliable and scalable solution for document management.
*   **Real-time Communication:**
    *   **Push Notifications:** Integrated with Firebase Cloud Messaging (FCM) to send real-time notifications.
    *   **Admin Group Chat:** A built-in chat feature for administrators using Socket.IO for real-time communication.
*   **Contest Tracking:** Tracks online programming contests from over 30 different websites.
*   **Image Handling:** Uses Cloudinary for image storage and `image_picker` for selecting images from the user's device.

**Tech Stack Highlights:**

*   **Frontend:** Flutter, GetX (State Management, Navigation, Dependency Injection)
*   **Backend:** Node.js, MongoDB
*   **Networking:** Dio (HTTP Client)
*   **Real-time Communication:** Firebase Cloud Messaging (FCM), Socket.IO
*   **Cloud Services:** Cloudinary (Image and PDF Storage)
*   **Local Storage:** flutter_secure_storage, shared_preferences
*   **CI/CD:** GitHub Actions
*   **Libraries:** `open_file`, `image_picker`, `path_provider`, `intl`

