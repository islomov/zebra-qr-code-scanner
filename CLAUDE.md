# Code Scanner App - Project Context

## Project Overview

Code Scanner is an iOS application that allows users to generate and scan QR codes and barcodes. The app provides product information lookup for scanned barcodes and maintains a history of all generated and scanned codes.

**Key Characteristics:**
- iOS only application
- No user authentication (no sign in/sign up)
- No custom backend required
- Phase 1: All features free, no monetization
- Phase 2 (future): Subscription-based monetization

---

## Tech Stack

| Component | Technology |
|-----------|------------|
| Language | Swift 5.9+ |
| UI Framework | SwiftUI |
| Minimum iOS | iOS 16 |
| Architecture | MVVM |
| QR/Barcode Generation | Core Image |
| Scanning | VisionKit (DataScannerViewController) |
| Local Storage | Core Data |
| Preferences | UserDefaults |
| Image Export | PhotosUI |
| Sharing | UIActivityViewController |
| Networking | URLSession |
| Product Lookup | Open Food Facts API + UPC Database API |

---

## App Structure

```
┌─────────────────────────────────────────┐
│  Code Scanner              ⚙️ (Settings) │  ← Top Bar
├─────────────────────────────────────────┤
│                                         │
│            [Main Content]               │
│                                         │
├─────────────────────────────────────────┤
│   Generate    │    Scan    │   History  │  ← 3 Tabs
└─────────────────────────────────────────┘
```

---

## Features

### 1. Generate Tab

**QR Code Types:**
- Plain Text
- URL/Link
- Phone Number
- Email
- WiFi Credentials
- vCard (Contact)
- SMS

**Barcode Types:**
- Code 128
- EAN-13
- EAN-8
- UPC-A

**Actions on generated code:**
- Preview
- Save to Photos
- Share (iOS share sheet)

### 2. Scan Tab

- Live camera scanner
- Import from photo library
- Flashlight toggle
- Result screen with:
  - Decoded content
  - Product info (for barcodes via API)
  - Copy to clipboard
  - Open link (if URL)
  - Add to contacts (if vCard)

### 3. History Tab

- Two sections: "Created" and "Scanned"
- Search bar
- Each item shows: type, content preview, date
- Tap to view details
- Swipe to delete

### 4. Settings (Top Bar)

- Vibrate on scan (toggle)
- Sound on scan (toggle)
- Default save location
- Clear history
- Rate app
- About/Version

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                         iOS App                              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│   │    Generate    │  │      Scan      │  │   History    │  │
│   │      Tab       │  │      Tab       │  │     Tab      │  │
│   └───────┬────────┘  └───────┬────────┘  └──────┬───────┘  │
│           │                   │                   │          │
│           ▼                   ▼                   ▼          │
│   ┌────────────────────────────────────────────────────┐    │
│   │                   View Models                      │    │
│   │         (Business Logic & State Management)        │    │
│   └────────────────────────┬───────────────────────────┘    │
│                            │                                 │
│           ┌────────────────┼────────────────┐               │
│           ▼                ▼                ▼               │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       │
│   │  Generator   │ │   Scanner    │ │   Product    │       │
│   │   Service    │ │   Service    │ │   Service    │       │
│   │ (Core Image) │ │ (VisionKit)  │ │  (Network)   │       │
│   └──────────────┘ └──────────────┘ └──────┬───────┘       │
│                                            │                │
│   ┌────────────────────────────────────────┼───────────┐   │
│   │              Core Data                 │           │   │
│   │        (History & Preferences)         │           │   │
│   └────────────────────────────────────────┼───────────┘   │
│                                            │                │
└────────────────────────────────────────────┼────────────────┘
                                             │
                                             ▼
                              ┌──────────────────────────┐
                              │    Third-Party APIs      │
                              ├──────────────────────────┤
                              │  • Open Food Facts       │
                              │    (Food products)       │
                              │                          │
                              │  • UPC Database          │
                              │    (General products)    │
                              └──────────────────────────┘
```

---

## Project Structure

```
CodeScanner/
├── App/
│   ├── CodeScannerApp.swift
│   └── ContentView.swift
│
├── Features/
│   ├── Generate/
│   │   ├── Views/
│   │   │   ├── GenerateView.swift
│   │   │   ├── QRCodeFormView.swift
│   │   │   ├── BarcodeFormView.swift
│   │   │   └── CodePreviewView.swift
│   │   └── ViewModels/
│   │       └── GenerateViewModel.swift
│   │
│   ├── Scan/
│   │   ├── Views/
│   │   │   ├── ScanView.swift
│   │   │   ├── ScannerOverlayView.swift
│   │   │   └── ScanResultView.swift
│   │   └── ViewModels/
│   │       └── ScanViewModel.swift
│   │
│   ├── History/
│   │   ├── Views/
│   │   │   ├── HistoryView.swift
│   │   │   └── HistoryItemView.swift
│   │   └── ViewModels/
│   │       └── HistoryViewModel.swift
│   │
│   └── Settings/
│       └── Views/
│           └── SettingsView.swift
│
├── Core/
│   ├── Models/
│   │   ├── CodeType.swift
│   │   ├── GeneratedCode.swift
│   │   ├── ScannedCode.swift
│   │   └── ProductInfo.swift
│   │
│   ├── Services/
│   │   ├── QRCodeGeneratorService.swift
│   │   ├── BarcodeGeneratorService.swift
│   │   ├── ScannerService.swift
│   │   └── ProductLookupService.swift
│   │
│   ├── Network/
│   │   ├── NetworkManager.swift
│   │   ├── OpenFoodFactsAPI.swift
│   │   └── UPCDatabaseAPI.swift
│   │
│   └── Storage/
│       ├── CoreDataManager.swift
│       └── CodeScanner.xcdatamodeld
│
├── Shared/
│   ├── Components/
│   │   ├── CodeImageView.swift
│   │   └── LoadingView.swift
│   ├── Extensions/
│   │   ├── UIImage+Extensions.swift
│   │   └── String+Extensions.swift
│   └── Constants/
│       └── AppConstants.swift
│
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

## Data Models

### Core Data Entities

#### GeneratedCodeEntity
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | Unique identifier |
| type | String | Code type (qr, code128, ean13, etc.) |
| content | String | The encoded content |
| contentType | String | Content category (url, text, phone, wifi, vcard, email, sms) |
| imageData | Data | Generated code image |
| createdAt | Date | Creation timestamp |

#### ScannedCodeEntity
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | Unique identifier |
| type | String | Detected code type |
| content | String | Decoded content |
| productName | String? | Product name from API (optional) |
| productBrand | String? | Product brand from API (optional) |
| productImage | String? | Product image URL from API (optional) |
| scannedAt | Date | Scan timestamp |

---

## API Integration

### Open Food Facts API (Free, No Key Required)

**Purpose:** Food product information lookup

**Base URL:** `https://world.openfoodfacts.org/api/v0/product/`

**Example Request:**
```
GET https://world.openfoodfacts.org/api/v0/product/737628064502.json
```

**Response Fields:**
- product_name
- brands
- image_url
- categories
- ingredients_text
- nutrition info

### UPC Database API (Free Tier: 100 requests/day)

**Purpose:** General product information lookup

**Base URL:** `https://api.upcdatabase.org/product/`

**Authentication:** Requires free API key

**Example Request:**
```
GET https://api.upcdatabase.org/product/{barcode}
Header: Authorization: Bearer {API_KEY}
```

**Response Fields:**
- title
- brand
- description
- images

### Product Lookup Strategy

```
Barcode Scanned
      │
      ▼
┌─────────────────┐
│ Is it a food    │──── Yes ───▶ Open Food Facts API
│ barcode? (EAN)  │                     │
└────────┬────────┘                     │
         │ No                           ▼
         ▼                        ┌───────────┐
┌─────────────────┐               │  Result?  │
│ UPC Database    │               └─────┬─────┘
│ API             │                     │
└────────┬────────┘              Yes    │    No
         │                         ◄────┴────►
         ▼                         │         │
   ┌───────────┐                   ▼         ▼
   │  Result?  │               Show Info   Fallback
   └─────┬─────┘                          to UPC DB
         │
  Yes    │    No
    ◄────┴────►
    │         │
    ▼         ▼
Show Info   Show "Product
            not found"
            + raw barcode
```

---

## Offline Capabilities

| Feature | Works Offline |
|---------|---------------|
| QR Code Generation | ✅ Yes |
| Barcode Generation | ✅ Yes |
| QR/Barcode Scanning | ✅ Yes |
| Save to Photos | ✅ Yes |
| Share | ✅ Yes |
| History (view/search) | ✅ Yes |
| Product Info Lookup | ❌ No (requires internet) |

---

## Phase Roadmap

### Phase 1 (Current)
- All features free
- No advertisements
- No monetization
- Focus: Build & launch, gather users and feedback

### Phase 2 (Future)
- Add subscription model (weekly/yearly)
- Feature gating for premium
- Potentially add advertisements for free tier
- Add StoreKit 2 integration
- Consider AdMob integration

---

## Key Implementation Notes

### QR Code Generation (Core Image)
- Use `CIQRCodeGenerator` filter
- Supports error correction levels: L, M, Q, H
- Output is `CIImage`, convert to `UIImage` for display/saving

### Barcode Generation (Core Image)
- Use `CICode128BarcodeGenerator` for Code 128
- For EAN/UPC, may need third-party library or custom implementation

### Scanning (VisionKit)
- Use `DataScannerViewController` (iOS 16+)
- Supports QR codes and multiple barcode formats
- Built-in camera UI with customizable overlay

### Core Data
- Use `NSPersistentContainer` for stack setup
- Implement `@FetchRequest` in SwiftUI views
- Consider background context for saves

---

## Dependencies

**No external dependencies required for Phase 1**

All functionality can be achieved with native Apple frameworks:
- Core Image
- VisionKit
- Core Data
- PhotosUI
- Foundation (URLSession)

---

## Important Considerations

1. **Camera Permission:** Request camera access for scanning feature
2. **Photo Library Permission:** Request access for saving generated codes
3. **Network Handling:** Gracefully handle offline state for product lookup
4. **Error Handling:** Provide user-friendly messages for API failures
5. **Performance:** Generate codes on background thread if needed
6. **Accessibility:** Support VoiceOver and Dynamic Type
