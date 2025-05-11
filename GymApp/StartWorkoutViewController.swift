//
//  StartWorkoutViewController.swift
//  GymApp
//
//  Created by Ajdin Seho on 4/29/25.
//

import UIKit
import CoreData

class StartWorkoutViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtSets: UITextField!
    @IBOutlet weak var txtReps: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var lblVolume: UILabel!
    
    @IBOutlet weak var muscleGroupPicker: UIPickerView!
    var existingExercise: NSManagedObject?
    
    var selectedDate: Date?
    
    var muscleGroups: [String] = []
    var selectedGroup: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSets.delegate = self
        txtReps.delegate = self
        txtWeight.delegate = self

        // Do any additional setup after loading the view.
        if let exercise = existingExercise {
            txtName.text = exercise.value(forKey: "name") as? String
            txtSets.text = String(exercise.value(forKey: "sets") as? Int32 ?? 0)
            txtReps.text = String(exercise.value(forKey: "reps") as? Int32 ?? 0)
            txtWeight.text = String(exercise.value(forKey: "weight") as? Double ?? 0)
            
            // Manually update volume label
            textFieldDidChangeSelection(txtWeight)
        }
        //set up for the uipicker view
        muscleGroupPicker.delegate = self
        muscleGroupPicker.dataSource = self

        // Load from UserDefaults
        muscleGroups = UserDefaults.standard.stringArray(forKey: "muscleGroups") ?? ["Push", "Pull", "Legs"]
        
        if let exercise = existingExercise,
           let workout = exercise.value(forKey: "linkedWorkout") as? NSManagedObject,
           let group = workout.value(forKey: "muscleGroup") as? String,
           let index = muscleGroups.firstIndex(of: group) {
            selectedGroup = group
            muscleGroupPicker.selectRow(index, inComponent: 0, animated: false)
        }


        // Preselect the first item
        if !muscleGroups.isEmpty {
            selectedGroup = muscleGroups[0]
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let name = txtName.text ?? ""

        guard let sets = Int32(txtSets.text ?? ""),
              let reps = Int32(txtReps.text ?? ""),
              let weight = Double(txtWeight.text ?? "") else {
            showAlert(message: "Please enter valid numbers for Sets, Reps, and Weight")
            return
        }

        let volume = Double(sets * reps) * weight

        let workout = NSEntityDescription.insertNewObject(forEntityName: "WorkoutEntity", into: context)
        let workoutDate = selectedDate ?? Date() // fallback to today if nil
        workout.setValue(workoutDate, forKey: "date")
        workout.setValue(selectedGroup ?? "Unknown", forKey: "muscleGroup")

        
        //  EDIT or CREATE logic
        let exercise = existingExercise ?? NSEntityDescription.insertNewObject(forEntityName: "ExerciseEntity", into: context)

        exercise.setValue(name, forKey: "name")
        exercise.setValue(sets, forKey: "sets")
        exercise.setValue(reps, forKey: "reps")
        exercise.setValue(weight, forKey: "weight")
        exercise.setValue(volume, forKey: "volume")
        exercise.setValue(workout, forKey: "linkedWorkout")
        
        
        

        do {
            try context.save()
            print("Exercise saved successfully!")

            // Clear form if adding new (but not when editing)
            if existingExercise == nil {
                txtName.text = ""
                txtSets.text = ""
                txtReps.text = ""
                txtWeight.text = ""
                lblVolume.text = "Volume: 0"
            }
            // Optional: Navigate back after editing
            navigationController?.popViewController(animated: true)

        } catch {
            print("Failed to save exercise: \(error)")
            showAlert(message: "Failed to save exercise. Please try again.")
        }
    }

    
    
    
    // shows an alert
    func showAlert(message: String){
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    // method for calculating the volume on the fly
    func textFieldDidChangeSelection(_ textField: UITextField){
        guard let sets = Int32(txtSets.text ?? ""),
                let reps = Int32(txtReps.text ?? ""),
                let weight = Double(txtWeight.text ?? "") else {
              lblVolume.text = "Volume: 0"
              return
          }
          
          let volume = Double(sets * reps) * weight
        if volume.truncatingRemainder(dividingBy: 1) == 0 {
            // Whole number
            lblVolume.text = "Volume: \(Int(volume))"
        } else {
            // Decimal number
            lblVolume.text = String(format: "Volume: %.2f", volume)
        }
    }
    // code for the muscleGroup Picker
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return muscleGroups.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return muscleGroups[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGroup = muscleGroups[row]
    }
    
    
    
    
}
