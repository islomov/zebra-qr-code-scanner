# Code Scanner App - Project Context

## Project Overview

Code Scanner is an iOS-only app for generating and scanning QR codes and barcodes, with product info lookup and history tracking.

- No user authentication
- No custom backend
- Phase 1 (current): All features free, no monetization
- Phase 2 (future): Subscription-based monetization (StoreKit 2)

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

**No external dependencies** - all native Apple frameworks.

---

## Features

### Generate Tab
- **QR Code types:** Plain Text, URL, Phone, Email, WiFi, vCard, SMS
- **Barcode types:** Code 128, EAN-13, EAN-8, UPC-A
- **Actions:** Preview, Save to Photos, Share

### Scan Tab
- Live camera scanner, photo library import, flashlight toggle
- Result screen: decoded content, product info (barcodes), copy, open link, add contact

### History Tab
- Two sections: "Created" and "Scanned"
- Search, tap for details, swipe to delete
- Each item shows: type, content preview, date

### Settings (Top Bar)
- Vibrate/sound on scan toggles, default save location, clear history, rate app, about

---

## Project Structure

```
CodeScanner/
├── App/
│   ├── CodeScannerApp.swift
│   └── ContentView.swift
├── Features/
│   ├── Generate/
│   │   ├── Views/ (GenerateView, QRCodeFormView, BarcodeFormView, CodePreviewView)
│   │   └── ViewModels/ (GenerateViewModel)
│   ├── Scan/
│   │   ├── Views/ (ScanView, ScannerOverlayView, ScanResultView)
│   │   └── ViewModels/ (ScanViewModel)
│   ├── History/
│   │   ├── Views/ (HistoryView, HistoryItemView)
│   │   └── ViewModels/ (HistoryViewModel)
│   └── Settings/
│       └── Views/ (SettingsView)
├── Core/
│   ├── Models/ (CodeType, GeneratedCode, ScannedCode, ProductInfo)
│   ├── Services/ (QRCodeGeneratorService, BarcodeGeneratorService, ScannerService, ProductLookupService)
│   ├── Network/ (NetworkManager, OpenFoodFactsAPI, UPCDatabaseAPI)
│   └── Storage/ (CoreDataManager, CodeScanner.xcdatamodeld)
├── Shared/
│   ├── Components/ (CodeImageView, LoadingView)
│   ├── Extensions/ (UIImage+Extensions, String+Extensions)
│   └── Constants/ (AppConstants)
└── Resources/ (Assets.xcassets, Info.plist)
```

---

## Data Models (Core Data)

### GeneratedCodeEntity
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | Unique identifier |
| type | String | Code type (qr, code128, ean13, etc.) |
| content | String | The encoded content |
| contentType | String | Content category (url, text, phone, wifi, vcard, email, sms) |
| imageData | Data | Generated code image |
| createdAt | Date | Creation timestamp |

### ScannedCodeEntity
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID | Unique identifier |
| type | String | Detected code type |
| content | String | Decoded content |
| productName | String? | Product name from API |
| productBrand | String? | Product brand from API |
| productImage | String? | Product image URL from API |
| scannedAt | Date | Scan timestamp |

---

## API Integration

### Open Food Facts API (Free, No Key Required)
- **Purpose:** Food product lookup
- **URL:** `GET https://world.openfoodfacts.org/api/v0/product/{barcode}.json`
- **Fields:** product_name, brands, image_url, categories, ingredients_text, nutrition info

### UPC Database API (Free Tier: 100 req/day)
- **Purpose:** General product lookup
- **URL:** `GET https://api.upcdatabase.org/product/{barcode}`
- **Auth:** `Authorization: Bearer {API_KEY}`
- **Fields:** title, brand, description, images

### Lookup Strategy
1. EAN barcode? Try Open Food Facts first
2. If no result or non-EAN, try UPC Database
3. If both fail, show "Product not found" + raw barcode

---

## Offline Capabilities

Everything works offline **except** Product Info Lookup (requires internet).

---

## Implementation Notes

- **QR Generation:** `CIQRCodeGenerator` filter, error correction L/M/Q/H, convert `CIImage` to `UIImage`
- **Barcode Generation:** `CICode128BarcodeGenerator` for Code 128; EAN/UPC may need custom implementation
- **Scanning:** `DataScannerViewController` (iOS 16+), supports QR + multiple barcode formats
- **Core Data:** `NSPersistentContainer`, `@FetchRequest` in SwiftUI, background context for saves

---

## Localization Rules

- Only modify **English** language entries in `Localizable.xcstrings`
- Do **not** add, remove, or modify strings for any other languages
- Multi-language updates handled in a separate ticket

---

## Important Considerations

1. **Camera Permission:** Required for scanning
2. **Photo Library Permission:** Required for saving generated codes
3. **Network Handling:** Gracefully handle offline state for product lookup
4. **Error Handling:** User-friendly messages for API failures
5. **Performance:** Generate codes on background thread if needed
6. **Accessibility:** Support VoiceOver and Dynamic Type
