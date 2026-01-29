//
//  CoreDataManager.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 25/01/26.
//

import CoreData
import UIKit

final class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {
        loadPersistentStores()
    }

    // MARK: - Core Data Stack

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CodeScanner", managedObjectModel: Self.managedObjectModel)
        return container
    }()

    private static var managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()

        // GeneratedCodeEntity
        let generatedCodeEntity = NSEntityDescription()
        generatedCodeEntity.name = "GeneratedCodeEntity"
        generatedCodeEntity.managedObjectClassName = NSStringFromClass(GeneratedCodeEntity.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let typeAttribute = NSAttributeDescription()
        typeAttribute.name = "type"
        typeAttribute.attributeType = .stringAttributeType
        typeAttribute.isOptional = false

        let contentAttribute = NSAttributeDescription()
        contentAttribute.name = "content"
        contentAttribute.attributeType = .stringAttributeType
        contentAttribute.isOptional = false

        let contentTypeAttribute = NSAttributeDescription()
        contentTypeAttribute.name = "contentType"
        contentTypeAttribute.attributeType = .stringAttributeType
        contentTypeAttribute.isOptional = false

        let imageDataAttribute = NSAttributeDescription()
        imageDataAttribute.name = "imageData"
        imageDataAttribute.attributeType = .binaryDataAttributeType
        imageDataAttribute.isOptional = true

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        generatedCodeEntity.properties = [
            idAttribute,
            typeAttribute,
            contentAttribute,
            contentTypeAttribute,
            imageDataAttribute,
            createdAtAttribute
        ]

        // ScannedCodeEntity
        let scannedCodeEntity = NSEntityDescription()
        scannedCodeEntity.name = "ScannedCodeEntity"
        scannedCodeEntity.managedObjectClassName = NSStringFromClass(ScannedCodeEntity.self)

        let scannedIdAttribute = NSAttributeDescription()
        scannedIdAttribute.name = "id"
        scannedIdAttribute.attributeType = .UUIDAttributeType
        scannedIdAttribute.isOptional = false

        let scannedTypeAttribute = NSAttributeDescription()
        scannedTypeAttribute.name = "type"
        scannedTypeAttribute.attributeType = .stringAttributeType
        scannedTypeAttribute.isOptional = false

        let scannedContentAttribute = NSAttributeDescription()
        scannedContentAttribute.name = "content"
        scannedContentAttribute.attributeType = .stringAttributeType
        scannedContentAttribute.isOptional = false

        let productNameAttribute = NSAttributeDescription()
        productNameAttribute.name = "productName"
        productNameAttribute.attributeType = .stringAttributeType
        productNameAttribute.isOptional = true

        let productBrandAttribute = NSAttributeDescription()
        productBrandAttribute.name = "productBrand"
        productBrandAttribute.attributeType = .stringAttributeType
        productBrandAttribute.isOptional = true

        let productImageAttribute = NSAttributeDescription()
        productImageAttribute.name = "productImage"
        productImageAttribute.attributeType = .stringAttributeType
        productImageAttribute.isOptional = true

        let scannedAtAttribute = NSAttributeDescription()
        scannedAtAttribute.name = "scannedAt"
        scannedAtAttribute.attributeType = .dateAttributeType
        scannedAtAttribute.isOptional = false

        scannedCodeEntity.properties = [
            scannedIdAttribute,
            scannedTypeAttribute,
            scannedContentAttribute,
            productNameAttribute,
            productBrandAttribute,
            productImageAttribute,
            scannedAtAttribute
        ]

        model.entities = [generatedCodeEntity, scannedCodeEntity]
        return model
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private func loadPersistentStores() {
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    // MARK: - Save

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }

    // MARK: - Generated Codes

    func saveGeneratedCode(
        type: String,
        content: String,
        contentType: String,
        image: UIImage?
    ) -> GeneratedCodeEntity {
        let entity = GeneratedCodeEntity(context: viewContext)
        entity.id = UUID()
        entity.type = type
        entity.content = content
        entity.contentType = contentType
        entity.imageData = image?.pngData()
        entity.createdAt = Date()

        saveContext()
        return entity
    }

    func fetchGeneratedCodes() -> [GeneratedCodeEntity] {
        let request = GeneratedCodeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GeneratedCodeEntity.createdAt, ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch generated codes: \(error)")
            return []
        }
    }

    func deleteGeneratedCode(_ entity: GeneratedCodeEntity) {
        viewContext.delete(entity)
        saveContext()
    }

    func deleteAllGeneratedCodes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GeneratedCodeEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to delete all generated codes: \(error)")
        }
    }

    // MARK: - Scanned Codes

    func saveScannedCode(
        type: String,
        content: String,
        productName: String? = nil,
        productBrand: String? = nil,
        productImage: String? = nil
    ) -> ScannedCodeEntity {
        let entity = ScannedCodeEntity(context: viewContext)
        entity.id = UUID()
        entity.type = type
        entity.content = content
        entity.productName = productName
        entity.productBrand = productBrand
        entity.productImage = productImage
        entity.scannedAt = Date()

        saveContext()
        return entity
    }

    func fetchScannedCodes() -> [ScannedCodeEntity] {
        let request = ScannedCodeEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScannedCodeEntity.scannedAt, ascending: false)]

        do {
            return try viewContext.fetch(request)
        } catch {
            print("Failed to fetch scanned codes: \(error)")
            return []
        }
    }

    func deleteScannedCode(_ entity: ScannedCodeEntity) {
        viewContext.delete(entity)
        saveContext()
    }

    func deleteAllScannedCodes() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ScannedCodeEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try viewContext.execute(deleteRequest)
            saveContext()
        } catch {
            print("Failed to delete all scanned codes: \(error)")
        }
    }
}

// MARK: - Core Data Entity

@objc(GeneratedCodeEntity)
public class GeneratedCodeEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var content: String?
    @NSManaged public var contentType: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var createdAt: Date?
}

extension GeneratedCodeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<GeneratedCodeEntity> {
        return NSFetchRequest<GeneratedCodeEntity>(entityName: "GeneratedCodeEntity")
    }

    var qrCodeContentType: QRCodeContentType? {
        guard let contentType = contentType else { return nil }
        return QRCodeContentType(rawValue: contentType)
    }

    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

// MARK: - Scanned Code Entity

@objc(ScannedCodeEntity)
public class ScannedCodeEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var type: String?
    @NSManaged public var content: String?
    @NSManaged public var productName: String?
    @NSManaged public var productBrand: String?
    @NSManaged public var productImage: String?
    @NSManaged public var scannedAt: Date?
}

extension ScannedCodeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScannedCodeEntity> {
        return NSFetchRequest<ScannedCodeEntity>(entityName: "ScannedCodeEntity")
    }
}
