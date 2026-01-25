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

        model.entities = [generatedCodeEntity]
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
