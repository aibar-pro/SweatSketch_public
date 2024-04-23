//
//  WorkoutCollectionWorkoutRowView.swift
//  SweatSketch
//
//  Created by aibaranchikov on 12.04.2024.
//

import SwiftUI

struct WorkoutCollectionWorkoutRowView: View {
    @ObservedObject var workoutRepresentation: WorkoutCollectionWorkoutViewRepresentation
    
    var onMoveRequested: (_ workout: WorkoutCollectionWorkoutViewRepresentation) -> ()
    
    var body: some View {
        Menu {
           Button("Move Workout") {
               onMoveRequested(workoutRepresentation)
           }

           Button("Share Workout") {

           }
       } label: {
           HStack{
               Text(workoutRepresentation.name)
                   .lineLimit(1)
                   .multilineTextAlignment(.leading)
               Spacer()
           }
       }
    }
}

struct WorkoutCollectionWorkoutRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        
        let collectionDataManager = CollectionDataManager()
        let firstCollection = collectionDataManager.fetchFirstUserCollection(in: persistenceController.container.viewContext)
        
        let workoutForPreview = (firstCollection?.toWorkoutCollectionRepresentation()?.workouts.first)!
        
        WorkoutCollectionWorkoutRowView(workoutRepresentation: workoutForPreview, onMoveRequested: {workout in })
    }
}
