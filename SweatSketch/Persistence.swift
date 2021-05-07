//
//  Persistence.swift
//  MyWorkoutPlanner
//
//  Created by aibaranchikov on 7/5/21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
//        var weightPlates : [WeightPlate] = []
//        var weightCount = 10
//        for i in 1...weightCount {
//            let newPlate = WeightPlate(context: viewContext)
//            newPlate.weight = Double(10 * i)
//            weightPlates.append(newPlate)
//        }
        
        let planCount = Int.random(in: 0...2)
        
        for w in 0...planCount {
            let workout = WorkoutEntity(context: viewContext)
            workout.uuid = UUID()
            workout.name = "Test Workout Auto \(w) Test Workout Auto Test Workout Auto"
            workout.position = Int16(w)
            
            let exerciseCount = Int.random(in: 0...20)
            
            for e in 0...exerciseCount {
                let newExercise = ExerciseEntity(context: viewContext)
                newExercise.name = String("Test Exercise \(w)-\(e)")
                
                workout.addToExercises(newExercise)
            }
        }

        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SweatSketchData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
