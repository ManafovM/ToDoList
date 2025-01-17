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
    
    var isFiltering: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    var toDosSnapshot: NSDiffableDataSourceSnapshot<Section, ToDo.ID> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ToDo.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(isFiltering ? filteredToDos.map { $0.id } : toDos.map { $0.id })
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let itemIdentifier = dataSource.itemIdentifier(for: indexPath),
              let toDoToDelete = toDos.first(where: { $0.id == itemIdentifier }) else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self else { return }
            if let index = toDos.firstIndex(of: toDoToDelete),
               let filteredIndex = filteredToDos.firstIndex(of: toDoToDelete){
                toDos.remove(at: index)
                filteredToDos.remove(at: filteredIndex)
                dataSource.apply(toDosSnapshot, animatingDifferences: true)
                ToDo.saveToDos(toDos)
            }
            completionHandler(true)
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func checkmarkTapped(sender: ToDoCell) {
        if let indexPath = tableView.indexPath(for: sender),
           let itemIdentifier = dataSource.itemIdentifier(for: indexPath),
           let index = toDos.firstIndex(where: { $0.id == itemIdentifier }),
           let filteredIndex = filteredToDos.firstIndex(where: { $0.id == itemIdentifier }){
            toDos[index].isComplete.toggle()
            filteredToDos[filteredIndex].isComplete.toggle()
            dataSource.applySnapshotUsingReloadData(toDosSnapshot)
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
        
        dataSource.apply(toDosSnapshot, animatingDifferences: true)
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
            if let index = toDos.firstIndex(of: toDo),
               let filteredIndex = filteredToDos.firstIndex(of: toDo){
                toDos[index] = toDo
                filteredToDos[filteredIndex] = toDo
                dataSource.applySnapshotUsingReloadData(toDosSnapshot)
            } else {
                toDos.append(toDo)
                filteredToDos = toDos
                dataSource.apply(toDosSnapshot, animatingDifferences: true)
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
        
        let itemIdentifier = dataSource.itemIdentifier(for: indexPath)
        detailController?.toDo = toDos.first(where: { $0.id == itemIdentifier })
        
        return detailController
    }
}
