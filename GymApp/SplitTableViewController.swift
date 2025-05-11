import UIKit

class SplitTableViewController: UITableViewController {

    var muscleGroups: [String] = []

    @IBOutlet weak var addSplitBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Muscle Groups"
        loadMuscleGroups()

    
    }
    
    


    @IBAction func addSplit(_ sender: UIBarButtonItem){
        promptForMuscleGroup { selectedGroup in
            let trimmed = selectedGroup.trimmingCharacters(in: .whitespacesAndNewlines)

            if self.muscleGroups.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
                let alert = UIAlertController(title: "Already Exists", message: "That muscle group is already in your list.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            } else {
                self.muscleGroups.append(trimmed)
                self.saveMuscleGroups()
                self.tableView.reloadData()
            }
        }
    }
    
  


    
    
    

    func loadMuscleGroups() {
        muscleGroups = UserDefaults.standard.stringArray(forKey: "muscleGroups") ?? ["Push", "Pull", "Legs"]
    }

    func saveMuscleGroups() {
        UserDefaults.standard.set(muscleGroups, forKey: "muscleGroups")
    }

    @objc func addMuscleGroup() {
        let alert = UIAlertController(title: "New Muscle Group", message: nil, preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let text = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
                self.muscleGroups.append(text)
                self.saveMuscleGroups()
                self.tableView.reloadData()
            }
        })
        present(alert, animated: true)
    }

    // MARK: Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muscleGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MuscleGroupCell", for: indexPath)
        cell.textLabel?.text = muscleGroups[indexPath.row]
        return cell
    }

    // Swipe to delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            muscleGroups.remove(at: indexPath.row)
            saveMuscleGroups()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func promptForMuscleGroup(completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: "Muscle Group", message: "Enter the muscle group you're training", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "e.g. Chest, Legs, Back"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let group = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
               !group.isEmpty {
                completion(group)
            }
        })
        
        present(alert, animated: true)
    }

    
    
    
    
}
