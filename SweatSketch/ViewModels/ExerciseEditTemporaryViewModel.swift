//
//  ExerciseViewModel.swift
//  MyWorkoutPlanner
//
//  Created by aibaranchikov on 29.11.2023.
//

import Foundation
import CoreData

class ExerciseEditTemporaryViewModel: ObservableObject {
    private let temporaryContext: NSManagedObjectContext
    private let parentViewModel: WorkoutEditTemporaryViewModel
    
    @Published var editingExercise: ExerciseEntity?
    @Published var exerciseActions: [ExerciseActionEntity] = []
    @Published var editingAction: ExerciseActionEntity?
    var isEditingAction: Bool {
        self.editingAction != nil
    }
    
    init(parentViewModel: WorkoutEditTemporaryViewModel, editingExercise: ExerciseEntity? = nil) {
        self.temporaryContext = parentViewModel.temporaryContext
        self.temporaryContext.undoManager?.beginUndoGrouping()
        
        self.parentViewModel = parentViewModel
        
        if editingExercise != nil {
            self.editingExercise = editingExercise
            self.exerciseActions = editingExercise?.exerciseActions?.array as? [ExerciseActionEntity] ?? []
            if !self.exerciseActions.isEmpty {
                switch ExerciseType.from(rawValue: self.editingExercise?.type) {
                case .setsNreps:
                    self.exerciseActions.forEach{
                        if $0.type == nil { $0.type = ExerciseActionType.setsNreps.rawValue }
                    }
                case .timed:
                    self.exerciseActions.forEach{ 
                        if $0.type == nil { $0.type = ExerciseActionType.timed.rawValue }
                    }
                default:
                    return
                }
            }
                
        } else {
            addExercise()
        }
    }
    
    func addExercise() {
        let newExercise = ExerciseEntity(context: temporaryContext)
        newExercise.uuid = UUID()
        newExercise.name = Constants.Design.Placeholders.noExerciseName
        newExercise.order = (parentViewModel.exercises.last?.order ?? -1) + 1
        newExercise.type = ExerciseType.setsNreps.rawValue
        
        self.editingExercise = newExercise
    }
    
    func addExerciseAction() {
        let newExerciseAction = ExerciseActionEntity(context: temporaryContext)
        newExerciseAction.uuid = UUID()
        newExerciseAction.name = Constants.Design.Placeholders.noActionName
        newExerciseAction.order = Int16(editingExercise?.exerciseActions?.count ?? 0)
        
        switch ExerciseType.from(rawValue: self.editingExercise?.type) {
        case .timed:
            newExerciseAction.type = ExerciseActionType.timed.rawValue
            newExerciseAction.duration = 1
        default:
            newExerciseAction.type = ExerciseActionType.setsNreps.rawValue
            newExerciseAction.sets = 1
            newExerciseAction.reps = 1
        }
        
        editingExercise?.addToExerciseActions(newExerciseAction)
        exerciseActions.append(newExerciseAction)
        setEditingAction(newExerciseAction)
    }
    
    func renameExercise(newName: String) {
        self.editingExercise?.name = newName
        self.objectWillChange.send()
    }
    
    func setSupersets(superset: Int) {
        self.editingExercise?.superSets = Int16(superset)
        self.objectWillChange.send()
    }
    
    func setEditingExerciseType(to type: ExerciseType) {
        exerciseActions.forEach{ action in
            let actionType = ExerciseActionType.from(rawValue: action.type).rawValue
            if actionType.isEmpty || actionType == ExerciseActionType.unknown.rawValue {
                switch ExerciseType.from(rawValue: self.editingExercise?.type) {
                case .timed:
                    action.type = ExerciseActionType.timed.rawValue
                    if action.duration < 1 { action.duration = Int32(1) }
                    print("Action type changed to timed")
                default:
                    action.type = ExerciseActionType.setsNreps.rawValue
                    if action.sets < 1 { action.sets = Int16(1) }
                    if action.reps < 1 { action.reps = Int16(1) }
                    print("Action type changed to SNR")
                }
            }
        }
        self.editingExercise?.type = type.rawValue
        self.objectWillChange.send()
        
        print("New Exercise type:"+(self.editingExercise?.type)!)
    }
    
    func setEditingExerciseActionType(to type: ExerciseActionType) {
        self.editingAction?.type = type.rawValue
        
        switch ExerciseActionType.from(rawValue: self.editingAction?.type) {
        case .timed:
            if self.editingAction!.duration < 1 { self.editingAction?.duration = Int32(1) }
        default:
            if self.editingAction!.sets < 1 { self.editingAction?.sets = Int16(1) }
            if self.editingAction!.reps < 1 { self.editingAction?.reps = Int16(1) }
        }
        self.objectWillChange.send()
        
        print("New Action type:"+(self.editingAction?.type)!)
    }
    
    func saveFilteredExerciseActions() {
        let filteredActions = exerciseActions.filter { action in
            switch ExerciseType.from(rawValue: editingExercise?.type) {
                case .setsNreps:
                    return ExerciseActionType.from(rawValue: action.type) == .setsNreps
                case .timed:
                    return ExerciseActionType.from(rawValue: action.type) == .timed
                case .mixed:
                    return ExerciseActionType.from(rawValue: action.type) == .setsNreps || ExerciseActionType.from(rawValue: action.type) == .timed
                case .unknown:
                    return ExerciseActionType.from(rawValue: action.type) == .unknown
            }
        }
        
        let originalSet = Set(exerciseActions)
        let filteredSet = Set(filteredActions)
        let itemsToDelete = originalSet.subtracting(filteredSet)
        
        exerciseActions.removeAll { item in
            itemsToDelete.contains(item)
        }
        
        itemsToDelete.forEach{ item in
            temporaryContext.delete(item)
        }
    }
    
    func deleteExerciseActions(at offsets: IndexSet) {
        let actionsToDelete = offsets.map { self.exerciseActions[$0] }
        actionsToDelete.forEach { exerciseAction in
            self.exerciseActions.remove(atOffsets: offsets)
            self.temporaryContext.delete(exerciseAction)
        }
    }
    
    func moveExerciseActions(from source: IndexSet, to destination: Int) {
        exerciseActions.move(fromOffsets: source, toOffset: destination)
        
        exerciseActions.enumerated().forEach{ index, exerciseAction in
            editingExercise?.removeFromExerciseActions(exerciseAction)
            editingExercise?.insertIntoExerciseActions(exerciseAction, at: index)
            exerciseAction.order=Int16(index)
        }
    }
    
    func setEditingAction(_ action: ExerciseActionEntity) {
        editingAction = action
    }

    func clearEditingAction() {
        editingAction = nil
    }
    
    func isEditingAction(_ action: ExerciseActionEntity) -> Bool {
        editingAction == action
    }
    
    func saveExercise() {
        if let exerciseToAdd = self.editingExercise {
            parentViewModel.addWorkoutExercise(newExercise: exerciseToAdd)
            self.temporaryContext.undoManager?.endUndoGrouping()
            //TODO: Undo add exercise
//            self.temporaryContext.undoManager?.registerUndo(withTarget: self, handler: { [weak self] _ in
//                self?.parentViewModel.undoAddExercise(for: exerciseToAdd)
//            })
        }
    }
    
    func discardExercise() {
        self.temporaryContext.undoManager?.endUndoGrouping()
        self.temporaryContext.undoManager?.undo()
    }
    
}
