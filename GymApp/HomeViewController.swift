import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblMonthYear: UILabel! // Displays the month and year based on the center of the current week
    
    
    

    var currentWeekOffset = 0 // Tracks how far we’ve paged away from the current week (0 = today)
    var visibleDates: [Date] = [] // Stores 3 weeks of days: [previous, current, next]
    private var hasScrolledToMiddle = false // Prevents repeated centering

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false

        // Configure horizontal layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero
        }

        // Load this week and adjacent weeks
        visibleDates = getVisibleWeeks(centeredOn: currentWeekOffset)
        collectionView.reloadData()
        updateMonthYearLabel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure layout is correctly sized for 7 cells across
        guard let layout = collectionView.collectionViewLayout as? PagedFlowLayout else { return }

        let collectionWidth = collectionView.bounds.width
        let cellWidth = floor(collectionWidth / 7) // Make 7 equal-width day cells
        layout.itemSize = CGSize(width: cellWidth, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero

        collectionView.collectionViewLayout.invalidateLayout()

        // Scroll to the center page (this week's view) once per view appearance
        if !hasScrolledToMiddle {
            let pageWidth = collectionView.frame.width
            collectionView.setContentOffset(CGPoint(x: pageWidth, y: 0), animated: false)
            hasScrolledToMiddle = true
        }
    }

    // Builds a 3-week range of days centered on the given week offset
    func getVisibleWeeks(centeredOn offset: Int) -> [Date] {
        let calendar = Calendar.current
        var allDates: [Date] = []

        for weekOffset in -1...1 {
            let targetOffset = offset + weekOffset
            let referenceDate = calendar.date(byAdding: .weekOfYear, value: targetOffset, to: Date())!
            let weekday = calendar.component(.weekday, from: referenceDate)
            let startOfWeek = calendar.date(byAdding: .day, value: -((weekday - calendar.firstWeekday + 7) % 7), to: referenceDate)!

            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                    allDates.append(date)
                }
            }
        }

        return allDates
    }

    // Detects swipe direction and updates to the correct week accordingly
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let pageWidth = scrollView.bounds.width

        let pageDelta = round(offsetX / pageWidth) - 1  // -1 = left swipe, 1 = right swipe

        guard abs(pageDelta) == 1 else {
            // Snap back to center if no meaningful scroll occurred
            collectionView.setContentOffset(CGPoint(x: pageWidth, y: 0), animated: false)
            return
        }

        // Update the week offset and reload
        currentWeekOffset += Int(pageDelta)
        visibleDates = getVisibleWeeks(centeredOn: currentWeekOffset)
        collectionView.reloadData()

        // After reload, scroll back to the middle page and update the label
        DispatchQueue.main.async {
            self.collectionView.setContentOffset(CGPoint(x: pageWidth, y: 0), animated: false)
            self.updateMonthYearLabel()
        }
    }

    // Number of date cells shown (21 total: 3 weeks)
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleDates.count
    }

    // Configures each date cell using a custom DayCell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath) as! DayCell

        let date = visibleDates[indexPath.item]
        cell.configure(with: date) // Set text like “Mon\n06”

        // Style the cell
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor

        return cell
    }

    // Prints the selected date when tapped
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = visibleDates[indexPath.item]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as? HistoryTableViewController {
            vc.selectedDate = selectedDate
            navigationController?.pushViewController(vc, animated: true)
        }

    }

    // When user returns to this view, reset the week and re-center
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        currentWeekOffset = 0
        visibleDates = getVisibleWeeks(centeredOn: currentWeekOffset)
        collectionView.reloadData()
        hasScrolledToMiddle = false
        updateMonthYearLabel()
    }

    // Displays the month + year based on the middle date in the current view
    func updateMonthYearLabel() {
        guard visibleDates.count >= 4 else { return } // Ensure we can safely access the middle

        let middleDate = visibleDates[visibleDates.count / 2]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        lblMonthYear.text = formatter.string(from: middleDate)
    }
    
    
    @IBAction func onHistroyBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as? HistoryTableViewController {
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    
}
