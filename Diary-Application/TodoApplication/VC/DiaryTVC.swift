//
//  DiaryTVC.swift
//  DiaryApplication
//
//  Created by Sano Gharzani on 2019-05-22.
//  Copyright © 2019 Gary Tokman. All rights reserved.
//

import UIKit
import CoreData

class DiaryTVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    
    

    var diaryArray = [Diary]()
    var currentDiaryArray = [Diary]() //update table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        alterLayout()
    }
    
    
    
    private func setUpSearchBar() {
        searchBar.delegate = self
    }
    
    func alterLayout() {
        table.tableHeaderView = UIView()
        // search bar in section header
        table.estimatedSectionHeaderHeight = 50
        // search bar in navigation bar
        //navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        navigationItem.titleView = searchBar
        searchBar.showsScopeBar = true // you can show/hide this dependant on your layout
        searchBar.placeholder = "Search item by location"
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDiaryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? TableCell else {
            return UITableViewCell()
        }
        cell.cityLbl.text = currentDiaryArray[indexPath.row].city
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentDiaryArray = diaryArray.filter({ item -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return item.city!.lowercased().contains(searchText.lowercased())
           
            default:
                return false
            }
        })
        print(currentDiaryArray)
        table.reloadData()
    }
    
}

class Locate {
    let city: String
    let category: LocateType
    
    init(city: String, category: LocateType) {
        self.city = city
        self.category = category
    }
}

enum LocateType: String {
    case city = "City"
    case county = "County"
}

