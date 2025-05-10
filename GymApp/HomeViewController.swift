//
//  HomeViewController.swift
//  GymApp
//
//  Created by Ajdin Seho on 4/29/25.
//

import UIKit

class HomeViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentWeek: [Date] = []
    

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            layout.sectionInset = .zero // Remove auto insets

            // This gets the actual width of the collection view frame
            let screenWidth = UIScreen.main.bounds.width
            let collectionWidth = collectionView.frame.width
            let cellWidth = floor(collectionWidth / 7)

            layout.itemSize = CGSize(width: cellWidth, height: 80)

            // This centers the cells inside the collection view if there's a tiny gap
            let totalCellWidth = cellWidth * 7
            
        }
        

        currentWeek = getDatesForCurrentWeek()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let collectionWidth = collectionView.frame.width
        let cellWidth = floor(collectionWidth / 7)
        layout.itemSize = CGSize(width: cellWidth, height: 80)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        // 💡 Calculate leftover space to center cells
        let totalCellWidth = cellWidth * 7
        let inset = (collectionWidth - totalCellWidth) / 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

        collectionView.collectionViewLayout.invalidateLayout()
    }


    
    
    
    
    
    func getDatesForCurrentWeek(startingFrom referenceDate: Date = Date()) -> [Date] {
        var week: [Date] = []
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: referenceDate)
        let startOfWeek = calendar.date(byAdding: .day, value: -((weekday - calendar.firstWeekday + 7) % 7), to: referenceDate)!

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                week.append(date)
            }
        }
        return week
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentWeek.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dayCell", for: indexPath)
        
        let date = currentWeek[indexPath.item]
        let formatter = DateFormatter()
        formatter.dateFormat = "E\ndd"
        let label = UILabel(frame: cell.contentView.bounds)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = formatter.string(from: date)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() } // Clean previous label
        cell.contentView.addSubview(label)
        cell.layer.cornerRadius = 8
        cell.layer.borderWidth = 1
        cell.layer.borderColor = UIColor.gray.cgColor

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = currentWeek[indexPath.item]
        print("Selected date: \(selectedDate)")
    }
    


}
