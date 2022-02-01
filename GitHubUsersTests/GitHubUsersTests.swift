//
//  GitHubUsersTests.swift
//  GitHubUsersTests
//
//  Created by Jeff on 27/01/2022.
//

import XCTest
import CoreData
@testable import GitHubUsers

class GitHubUsersTests: XCTestCase {
    var sut: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = APPDELEGATE.persistentContainer.viewContext
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testValidateCoreDataEntriesCreation() throws {
        //Test passing condition
        let promise = expectation(description: "CoreData entires creation is validated")
        
        let entries: [String: Any] = [
            "id": 0,
            "username": "TestUser",
            "avatarUrl": URL(string: "www.sampleurl.com") as Any
        ]
        
        //Now let’s create an entity and new user records.
        let dataEntity = NSEntityDescription.entity(forEntityName: "TestEntity",///Change the Entity to "User" To see effect in the UI
                                                    in: sut)!
        
        let Data = NSManagedObject(entity: dataEntity, insertInto: sut)
        
        for (key, value) in entries {
            Data.setValue(value, forKey: key)
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        do {
            try sut.save()
            promise.fulfill()
        } catch let error as NSError {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        wait(for: [promise], timeout: 5)
    }
    
    func testValidateCoreDataEntriesUpdate() throws {
        //Test passing condition
        let promise = expectation(description: "CoreData entires update is validated")
        
        let entries: [String: Any] = [
            "notes": "Lorem ipsum is a dummy text used for testing."
        ]
        
        //Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TestEntity")///Change the Entity to "User" To see effect in the UI
        let predicate = NSPredicate(format: "id = '\(0)'")
        
        fetchRequest.predicate = predicate
        
        do {
            let result = try sut.fetch(fetchRequest)
            if let objectToUpdate = result.first as? NSManagedObject {
                
                for (key, value) in entries {
                    objectToUpdate.setValue(value, forKey: key)
                }
                
                try sut.save()
                promise.fulfill()
            }
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        wait(for: [promise], timeout: 5)
    }
}
