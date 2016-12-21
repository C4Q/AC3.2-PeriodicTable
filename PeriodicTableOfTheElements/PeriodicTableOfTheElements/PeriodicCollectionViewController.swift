//
//  PeriodicCollectionViewController.swift
//  PeriodicTableOfTheElements
//
//  Created by Jason Gresh on 12/20/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "elementCell"

class PeriodicCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    var fetchedResultsController: NSFetchedResultsController<Element>!
    let groupOffsets = [0, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 0]
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        getData()

        // Register cell classes
        self.collectionView!.register(UINib(nibName:"ElementCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func getData() {
        APIRequestManager.manager.getData(endPoint: "https://api.fieldbook.com/v1/5859ad86d53164030048bae2/elements") { data in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options:[]),
                    let elements = jsonData as? [[String:Any]] {
                    
                    let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.privateContext
                    Element.putElements(from: elements, into: moc)
                    DispatchQueue.main.async {
                        self.collectionView!.reloadData()
                    }
                }
            }
        }
    }
    
    func initializeFetchedResultsController() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        
        let request = NSFetchRequest<Element>(entityName: "Element")
        let groupSort = NSSortDescriptor(key: "group", ascending: true)
        let numberSort = NSSortDescriptor(key: "number", ascending: true)
        let predicate = NSPredicate(format: "group <= %d", 18)
        request.sortDescriptors = [groupSort, numberSort]
        request.predicate = predicate
        
        // diagnostic
//        do {
//            let els = try moc.fetch(request)
//
//            for el in els {
//                print("\(el.group) \(el.number) \(el.symbol)")
//            }
//        }
//        catch {
//            print("error fetching")
//        }
    
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "group", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = fetchedResultsController.sections?.count {
            return count
        }
        else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
        
//        guard let sections = fetchedResultsController.sections else {
//            fatalError("No sections in fetchedResultsController")
//        }
//        let sectionInfo = sections[section]
//        return sectionInfo.numberOfObjects
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ElementCollectionViewCell
        
        cell.elementView.symbolLabel.text = ""
        cell.elementView.numberLabel.text = ""
        
        // bump the cells down
        if indexPath.item >= groupOffsets[indexPath.section] {
            var modifiedIp = indexPath
            modifiedIp.item = indexPath.item - groupOffsets[indexPath.section]
            
            let element = fetchedResultsController.object(at: modifiedIp)
            
            cell.elementView.symbolLabel.text = element.symbol!
            cell.elementView.numberLabel.text = String(element.number)
            
            let dimension = self.collectionView!.bounds.height / 7 - spacing * 6
            cell.elementView.symbolLabel.font = UIFont.systemFont(ofSize: dimension/2)
        }
        return cell
    }

    let spacing:CGFloat = 2.0
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = self.collectionView!.bounds.height / 7 - spacing * 6
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    // you'd think you need this but our sections have only one column
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return spacing
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
