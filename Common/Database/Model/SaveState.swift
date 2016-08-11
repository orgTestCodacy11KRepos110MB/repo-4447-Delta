//
//  SaveState.swift
//  Delta
//
//  Created by Riley Testut on 1/31/16.
//  Copyright © 2016 Riley Testut. All rights reserved.
//

import Foundation
import CoreData

import DeltaCore

extension SaveState
{
    enum Attributes: String
    {
        case filename
        case identifier
        case name
        case creationDate
        case modifiedDate
        case type
        case gameType
        
        case game
        case previewGame
    }
}

@objc enum SaveStateType: Int16
{
    case auto
    case general
    case locked
}

@objc(SaveState)
class SaveState: NSManagedObject, SaveStateProtocol
{
    @NSManaged var name: String?
    @NSManaged var creationDate: Date
    @NSManaged var modifiedDate: Date
    @NSManaged var type: SaveStateType
    
    @NSManaged private(set) var filename: String
    @NSManaged private(set) var identifier: String
    
    // Must be optional relationship to satisfy weird Core Data requirement
    // https://forums.developer.apple.com/thread/20535
    @NSManaged var game: Game!
    
    @NSManaged var previewGame: Game?
    
    var fileURL: URL {
        let fileURL = DatabaseManager.saveStatesDirectoryURLForGame(self.game).appendingPathComponent(self.filename)
        return fileURL
    }
    
    var imageFileURL: URL {
        let imageFilename = (self.filename as NSString).deletingPathExtension + ".png"
        let imageFileURL = DatabaseManager.saveStatesDirectoryURLForGame(self.game).appendingPathComponent(imageFilename)
        return imageFileURL
    }
    
    var gameType: GameType {
        return self.game.type
    }
}

extension SaveState
{
    override public func prepareForDeletion()
    {
        super.prepareForDeletion()
        
        guard FileManager.default.fileExists(atPath: self.fileURL.path) else { return }
        
        do
        {
            try FileManager.default.removeItem(at: self.fileURL)
        }
        catch
        {
            print(error)
        }
    }
}

extension SaveState
{
    @NSManaged private var primitiveFilename: String
    @NSManaged private var primitiveIdentifier: String
    @NSManaged private var primitiveCreationDate: Date
    @NSManaged private var primitiveModifiedDate: Date
    
    override func awakeFromInsert()
    {
        super.awakeFromInsert()
        
        let identifier = UUID().uuidString
        let date = Date()
        
        self.primitiveIdentifier = identifier
        self.primitiveFilename = identifier
        self.primitiveCreationDate = date
        self.primitiveModifiedDate = date
    }
}
