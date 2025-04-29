//
//  StartWorkoutViewController.swift
//  GymApp
//
//  Created by Ajdin Seho on 4/29/25.
//

import UIKit
import CoreData

class StartWorkoutViewController: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtSets: UITextField!
    @IBOutlet weak var txtReps: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                let weight = Double(txtWeight.text!) else {
           showAlert(message: "Please enter valid numbers for Sets, Reps, and Weight")
           return
       }
        
    }
    
    func showAlert(message: String){
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
}
