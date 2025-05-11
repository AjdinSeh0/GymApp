//
//  HistoryTableViewController.swift
//  GymApp
//
//  Created by Ajdin Seho on 4/29/25.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    //var exercises: [NSManagedObject] = []
    
    var groupedExercises: [Date: [NSManagedObject]] = [:]
    var sortedSectionDates: [Date] = []
    
    
    
    
    var selectedDate: Date?

    @IBOutlet weak var lblNoWorkouts: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchExercises()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        fetchExercises()
        
        if selectedDate == nil {
             navigationItem.rightBarButtonItem = nil
         }
    }
    
    func fetchExercises() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let request = NSFetchRequest<NSManagedObject>(entityName: "ExerciseEntity")

        if let date = selectedDate {
            // Fetch only exercises linked to a workout on the selected date
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            request.predicate = NSPredicate(format: "linkedWorkout.date >= %@ AND linkedWorkout.date < %@", startOfDay as NSDate, endOfDay as NSDate)
        }

        do {
            let fetched = try context.fetch(request)

            // 🧼 Clear previous data
            groupedExercises.removeAll()
            sortedSectionDates.removeAll()

            // Group by workout date
            let calendar = Calendar.current
            for exercise in fetched {
                if let workout = exercise.value(forKey: "linkedWorkout") as? NSManagedObject,
                   let rawDate = workout.value(forKey: "date") as? Date {
                    
                    let dateOnly = calendar.startOfDay(for: rawDate)

                    if groupedExercises[dateOnly] != nil {
                        groupedExercises[dateOnly]?.append(exercise)
                    } else {
                        groupedExercises[dateOnly] = [exercise]
                    }
                }
            }

            // Sort section headers (newest to oldest)
            sortedSectionDates = groupedExercises.keys.sorted(by: >)

            lblNoWorkouts.isHidden = !fetched.isEmpty
            tableView.reloadData()

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }



    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sortedSectionDates.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = sortedSectionDates[section]
        return groupedExercises[date]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = sortedSectionDates[section]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)

        let exercises = groupedExercises[date] ?? []
        let totalVolume = exercises.reduce(0.0) { sum, exercise in
            let volume = exercise.value(forKey: "volume") as? Double ?? 0.0
            return sum + volume
        }

        let volumeString = Int(totalVolume)

        return "\(dateString) - Total Volume: \(volumeString)"
    }


    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = sortedSectionDates[indexPath.section]
        let exercise = groupedExercises[date]?[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)

        let name = exercise?.value(forKey: "name") as? String ?? "Unnamed"
        let sets = exercise?.value(forKey: "sets") as? Int32 ?? 0
        let reps = exercise?.value(forKey: "reps") as? Int32 ?? 0
        let weight = exercise?.value(forKey: "weight") as? Double ?? 0
        let volume = exercise?.value(forKey: "volume") as? Double ?? 0

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(sets) sets, \(reps) reps, \(weight) pounds, \(Int(volume)) total volume"

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            let sectionDate = sortedSectionDates[indexPath.section]
            guard let exerciseToDelete = groupedExercises[sectionDate]?[indexPath.row] else { return }

            context.delete(exerciseToDelete)
            groupedExercises[sectionDate]?.remove(at: indexPath.row)

            if groupedExercises[sectionDate]?.isEmpty ?? true {
                groupedExercises.removeValue(forKey: sectionDate)
                sortedSectionDates.removeAll(where: { $0 == sectionDate })
            }

            do {
                try context.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Failed to delete exercise: \(error)")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDate = sortedSectionDates[indexPath.section]
        guard let selectedExercise = groupedExercises[sectionDate]?[indexPath.row] else { return }


        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let workoutVC = storyboard.instantiateViewController(withIdentifier: "StartWorkoutViewController") as? StartWorkoutViewController {
            workoutVC.existingExercise = selectedExercise
            navigationController?.pushViewController(workoutVC, animated: true)
        }
    }
    
    @IBAction func onAddWorkout(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "StartWorkoutViewController") as? StartWorkoutViewController {
            vc.selectedDate = self.selectedDate
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
