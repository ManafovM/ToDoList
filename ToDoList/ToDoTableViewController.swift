//
//  ToDoTableViewController.swift
//  ToDoList
//
//  Created by マナフォフ・マリフ on 2024/11/08.
//

import UIKit

enum Section: CaseIterable {
    case main
}

class ToDoTableViewController: UITableViewController, UISearchResultsUpdating, ToDoCellDelegate {
    var toDos = [ToDo]()
    var filteredToDos = [ToDo]()
    let searchController = UISearchController()
    var dataSource: UITableViewDiffableDataSource<Section, ToDo.ID>!
    
    
    var toDosSnapshot: NSDiffableDataSourceSnapshot<Section, ToDo.ID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDo.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(toDos.map { $0.id })
        return snapshot
    }
    
    var filteredToDosSnapshot: NSDiffableDataSourceSnapshot<Section, ToDo.ID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDo.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredToDos.map { $0.id })
        return snapshot
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let savedToDos = ToDo.loadToDos() {
            toDos = savedToDos
        } else {
            toDos = ToDo.loadSampleToDos()
        }
        filteredToDos = toDos
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        createDataSource()
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            toDos.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender) {
            var toDo = toDos[indexPath.row]
            toDo.isComplete.toggle()
            toDos[indexPath.row] = toDo
            tableView.reloadRows(at: [indexPath], with: .automatic)
            ToDo.saveToDos(toDos)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchString = searchController.searchBar.text,
           searchString.isEmpty == false {
            filteredToDos = toDos.filter({ (toDo) -> Bool in
                toDo.title.localizedCaseInsensitiveContains(searchString)
            })
        } else {
            filteredToDos = toDos
        }
        
        dataSource.apply(filteredToDosSnapshot, animatingDifferences: true)
        print(toDos)
    }
    
    func createDataSource() {
        dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { [weak self] tableView, indexPath, itemIdentifier in
            guard let self, let toDo = toDos.first(where: { $0.id == itemIdentifier })
            else {
                return nil
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellIdentifier", for: indexPath) as! ToDoCell
            cell.titleLabel.text = toDo.title
            cell.isCompleteButton.isSelected = toDo.isComplete
            cell.delegate = self
            return cell
        })
        dataSource.apply(toDosSnapshot)
    }
    
    @IBAction func unwindToToDoList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! ToDoDetailTableViewController
        if let toDo = sourceViewController.toDo {
            if let indexOfExistingToDo = toDos.firstIndex(of: toDo) {
                toDos[indexOfExistingToDo] = toDo
                tableView.reloadRows(at: [IndexPath(row: indexOfExistingToDo, section: 0)], with: .automatic)
            } else {
                let newIndexPath = IndexPath(row: toDos.count, section: 0)
                toDos.append(toDo)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        ToDo.saveToDos(toDos)
    }
    
    @IBSegueAction func editToDo(_ coder: NSCoder, sender: Any?) -> ToDoDetailTableViewController? {
        let detailController = ToDoDetailTableViewController(coder: coder)
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
                return detailController
              }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        detailController?.toDo = toDos[indexPath.row]
        
        return detailController
    }
}
