# PAD and Invoice Management Features

## Overview
This document outlines the new administrative features for PAD (official statements) and Invoice management that have been added to the pcIST Flutter application.

## Features Implemented

### 1. PAD Statement Management
- **Create PAD Statement** (`/createPad`)
  - Generate official PAD statements with multiple authorizers
  - Option to send via email or download as PDF
  - Support for custom contact information and address
  - Rich text statement input with validation

- **PAD History** (`/padHistory`)
  - View all previously created PAD statements
  - Download existing PAD statements by ID
  - Filter and search functionality
  - Status indicators (sent/draft)

### 2. Invoice Management
- **Create Invoice** (`/createInvoice`)
  - Generate professional invoices with multiple products/services
  - Dynamic product addition and removal
  - Automatic grand total calculation
  - Option to send via email or download as PDF
  - Authorizer information and contact details

- **Invoice History** (`/invoiceHistory`)
  - View all previously created invoices with pagination
  - Download existing invoices by ID
  - Product/service summary display
  - Payment status and client information

## API Integration

### PAD API (`lib/services/padApi.dart`)
- `sendPadStatement()` - Send PAD via email
- `downloadPadStatement()` - Download PAD as PDF
- `downloadPadById()` - Download existing PAD by ID
- `getPadHistory()` - Retrieve PAD history

### Invoice API (`lib/services/invoiceApi.dart`)
- `sendInvoice()` - Send invoice via email
- `downloadInvoice()` - Download invoice as PDF
- `downloadInvoiceById()` - Download existing invoice by ID
- `getInvoiceHistory()` - Retrieve invoice history with pagination

## Data Models

### PAD Models (`lib/secret.dart`)
- `PadAuthorizer` - Authorizer information (name, role)
- `PadStatement` - Complete PAD statement data

### Invoice Models (`lib/secret.dart`)
- `InvoiceProduct` - Product/service information (description, quantity, price)
- `Invoice` - Complete invoice data with products and authorizer info

## Process Flow (`lib/preocesses/onTapProcesses.dart`)
- `SendPadStatement()` - Handle PAD email sending with loading states
- `DownloadPadStatement()` - Handle PAD PDF download
- `SendInvoice()` - Handle invoice email sending
- `DownloadInvoice()` - Handle invoice PDF download

## User Interface

### Admin Features Integration
The new features are accessible through the Admin Features page (`/adminFeatures`) under the "Document Management" section:
- Create PAD Statement
- PAD History
- Create Invoice
- Invoice History

### Design Consistency
- Follows existing app design patterns
- Gradient backgrounds and card-based layouts
- Consistent color scheme (deep orange theme)
- Responsive design for different screen sizes
- Proper error handling and loading states

## Backend Requirements

The backend should provide the following endpoints:
- `POST /pad/send` - Send PAD statement via email
- `POST /pad/download` - Download PAD statement as PDF
- `GET /pad/download/{id}` - Download PAD by ID
- `GET /pad/history` - Get PAD history
- `POST /invoice/send` - Send invoice via email
- `POST /invoice/download` - Download invoice as PDF
- `GET /invoice/download/{id}` - Download invoice by ID
- `GET /invoice/history` - Get invoice history (with pagination)

## Security
- All API calls require authentication tokens
- Admin role verification (role == 2) for access control
- Input validation and sanitization
- Secure file handling for PDF downloads

## Future Enhancements
- Templates for PAD statements and invoices
- Bulk operations for multiple documents
- Advanced filtering and search capabilities
- Document version control
- Digital signatures integration
