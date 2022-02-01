//
//  CoreDataManager.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    /// Create Coredata entry
    func createData(withEntries entries : [String: Any] ,
                    forEntity entity    : String        ,
                    completion          : @escaping (_ finished: Bool) -> ()){
        
        //We need to create a context from this container
        let managedContext = APPDELEGATE.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let dataEntity = NSEntityDescription.entity(
            forEntityName : entity,
            in            : managedContext
        )!
        
        let Data = NSManagedObject(entity: dataEntity, insertInto: managedContext)
        
        for (key, value) in entries {
            Data.setValue(value, forKey: key)
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        do {
            try managedContext.save()
            completion(true)
        } catch let error as NSError {
            Helper.debugLogs(anyData: "\(error)", andTitle: "Coredata Save Error")
            Helper.debugLogs(anyData: "\(error.userInfo)", andTitle: "Coredata save Error User Info")
            completion(false)
        }
    }
    
    /// Update Coredata entry
    func upateData(withId id           : Int32 ,
                   forEntity entity    : String,
                   withEntries entries : [String: Any],
                   completion          : @escaping (_ finished: Bool) -> ()){
        
        //We need to create a context from this container
        let managedContext = APPDELEGATE.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let predicate = NSPredicate(format: "id = '\(id)'")
        
        fetchRequest.predicate = predicate
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = result.first as? NSManagedObject {
                
                for (key, value) in entries {
                    objectToUpdate.setValue(value, forKey: key)
                }
                
                try managedContext.save()
            }
            completion(true)
        } catch {
            print("Failed to update")
            completion(false)
        }
    }
    
    /// Retrieve coredata entry
    func retrieveData(forEntity entity: String,
                      shouldAddCondition addCondition: Bool = false,
                      withKeyAndValue keyVal: [String: String]? = nil,
                      ofType type: NSCompoundPredicate.LogicalType? = nil) -> Any? {
        
        //We need to create a context from this container
        let managedContext = APPDELEGATE.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "id", ascending: true)]
        
        if addCondition {
            if let keyVal = keyVal {
                
                var predicates: [NSPredicate] = []
                
                for (key, value) in keyVal {
                    let predicate = NSPredicate(format: "\(key) = '\(value)'")
                    predicates.append(predicate)
                }
                
                var compundPredicate = NSCompoundPredicate()
                
                if let type = type {
                    compundPredicate = NSCompoundPredicate(type: type,
                                                           subpredicates: predicates)
                } else {
                    compundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
                fetchRequest.predicate = compundPredicate
            }
        }
        
        do {
            var returnData: [Any] = []
            
            let data = try managedContext.fetch(fetchRequest)

            guard data.count > 0 else { return nil }
            
            if entity == PROFILE {
                if let datum = data.first as? NSManagedObject {
                    let id        = datum.value(forKey: "id")         as! Int32
                    let username  = datum.value(forKey: "username")   as! String
                    let name      = datum.value(forKey: "name")       as! String
                    let company   = datum.value(forKey: "company")    as! String
                    let blog      = datum.value(forKey: "blog")       as! String
                    let location  = datum.value(forKey: "location")   as! String
                    let email     = datum.value(forKey: "email")      as! String
                    let followers = datum.value(forKey: "followers")  as! Int32
                    let following = datum.value(forKey: "following")  as! Int32
                    
                    let profile: ProfileModel = ProfileModel(withId: id, username: username, name: name, company: company, blog: blog, location: location, email: email, followers: followers, following: following)
                    
                    return profile
                }
            } else {
                for datum in data as! [NSManagedObject] {
                    
                    let id        = datum.value(forKey: "id")         as! Int32
                    let username  = datum.value(forKey: "username")   as! String
                    let notes     = datum.value(forKey: "notes")      as? String
                    let avatarUrl = datum.value(forKey: "avatarUrl")  as! URL
                    
                    let user: UserListModel = UserListModel(withId: id,
                                                            username: username,
                                                            notes: notes,
                                                            andAvatarUrl: avatarUrl)
                    returnData.append(user)
                }
            }
            
            return returnData
        } catch {
            print("Failed to fetch")
            return nil
        }
    }
    
}
