//
//  WorkoutCatalogWorkoutRowView.swift
//  SweatSketch
//
//  Created by aibaranchikov on 12.04.2024.
//

import SwiftUI

struct WorkoutCatalogWorkoutRowView: View {
    @ObservedObject var workoutRepresentation: WorkoutCatalogWorkoutViewRepresentation
    @Binding var isLoggedIn: Bool
    
    var onMoveRequested: (_ workout: WorkoutCatalogWorkoutViewRepresentation) -> ()
    var onShareRequested: (_ workout: WorkoutCatalogWorkoutViewRepresentation) -> ()
    
    var body: some View {
        Menu {
            Button(Constants.Placeholders.WorkoutCatalog.moveWorkoutButtonLabel) {
               onMoveRequested(workoutRepresentation)
            }

            Button(Constants.Placeholders.WorkoutCatalog.shareWorkoutButtonLabel) {
                onShareRequested(workoutRepresentation)
            }
            .disabled(!isLoggedIn)
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

struct WorkoutCatalogWorkoutRowView_Previews: PreviewProvider {
    
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        
        let collectionDataManager = CollectionDataManager()
        let firstCollection = collectionDataManager.fetchFirstUserCollection(in: persistenceController.container.viewContext)
        
        let workoutForPreview = (firstCollection?.toWorkoutCollectionRepresentation()?.workouts.first)!
        
        WorkoutCatalogWorkoutRowView(workoutRepresentation: workoutForPreview, isLoggedIn: .constant(true), onMoveRequested: {workout in }, onShareRequested: { _ in })
    }
}
