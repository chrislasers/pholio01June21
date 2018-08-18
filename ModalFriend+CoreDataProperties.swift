//
//  ModalFriend+CoreDataProperties.swift
//  
//
//  Created by Chris  Ransom on 8/17/18.
//
//

import Foundation
import CoreData


extension ModalFriend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ModalFriend> {
        return NSFetchRequest<ModalFriend>(entityName: "ModalFriend")
    }

    @NSManaged public var name: String?
    @NSManaged public var profileImage: String?
    @NSManaged public var lastMessage: ModalMessage?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension ModalFriend {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: ModalMessage)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: ModalMessage)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
