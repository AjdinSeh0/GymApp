//
//  StartWorkoutViewController.swift
//  GymApp
//
//  Created by Ajdin Seho on 4/29/25.
//

import UIKit
import CoreData

class StartWorkoutViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtSets: UITextField!
    @IBOutlet weak var txtReps: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var lblVolume: UILabel!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSets.delegate = self
        txtReps.delegate = self
        txtWeight.delegate = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSave(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        var newExercise = NSEntityDescription.insertNewObject(forEntityName: "ExerciseEntity", into: context)
        // might need to set a default later just in case
        
        let name = txtName.text ?? ""
        
        guard   let sets = Int32(txtSets.text!),
                let reps = Int32(txtReps.text!),
                let weight = Double(txtWeight.text!)
        else {
           showAlert(message: "Please enter valid numbers for Sets, Reps, and Weight")
           return
       }
        let volume = Double(sets * reps) * weight
        
        newExercise.setValue(name, forKey: "name")
        newExercise.setValue(sets, forKey: "sets")
        newExercise.setValue(reps, forKey: "reps")
        newExercise.setValue(weight, forKey: "weight")
        newExercise.setValue(volume, forKey: "volume")

        do {
            try context.save()
            print("Exercise saved successfully!")
            
            // clear the fields after saving
            txtName.text = ""
            txtSets.text = ""
            txtReps.text = ""
            txtWeight.text = ""
            lblVolume.text = "Volume: 0"
            
        } catch {
            print("Failed to save exercise: \(error)")
            showAlert(message: "Failed to save exercise. Please try again.") // error alert
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
    
    

}
