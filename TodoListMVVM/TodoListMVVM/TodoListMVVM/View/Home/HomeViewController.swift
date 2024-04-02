//
//  ViewController.swift
//  TodoListMVVM

import UIKit
import TodoData

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        viewModel.loadTasks()
        tableView.reloadData()
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: Constant.tableViewCellNib, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: Constant.tableViewCellNib)
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        let editVC = viewModel.initEditVC(withStage: .addRootTask, todoItem: nil, atIndex: nil)
        editVC.delegate = self
        self.navigationController?.pushViewController(editVC, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItem()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.tableViewCellNib, for: indexPath) as? HomeTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        let todoItem = viewModel.todoItems[indexPath.row]
        cell.configCellWithData(data: viewModel.getDataForCellByItem(item: todoItem))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = viewModel.initEditVC(withStage: .editTask, todoItem: viewModel.todoItems[indexPath.row], atIndex: indexPath)
        editVC.delegate = self
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let todoItem = viewModel.todoItems[indexPath.row]
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Calculate IndexPath objects for each index in the range to delete
            let indexRangeToDelete = self.viewModel.indexRangeOfTaskAndSubtasks(for: todoItem)
            
            let parentOfDeleteTast = todoItem.parent
            
            self.viewModel.removeTask(todoItem: todoItem)
            
            // Delete the rows from the table view
            tableView.deleteRows(at: indexRangeToDelete, with: .automatic)
            //delete first root task will effect to alls
            if todoItem.number == 1  {
                tableView.reloadData()
            } else {
                if let parentTask = parentOfDeleteTast {
                    tableView.reloadRows(at: self.viewModel.findIndexEffectAfterDelete(for: parentTask), with: .automatic)
                } else {
                    tableView.reloadData()
                }
            }
            completionHandler(true)
        }
        
        // Define an action for adding a subtask
        let addSubtaskAction = UIContextualAction(style: .normal, title: "Add Subtask") { (action, view, completionHandler) in
            
            let editVC = self.viewModel.initEditVC(withStage: .addSubTask, todoItem: todoItem, atIndex: indexPath)
            editVC.delegate = self
            self.navigationController?.pushViewController(editVC, animated: true)
            completionHandler(true)
        }
        
        addSubtaskAction.backgroundColor = .systemBlue
        var actions = [UIContextualAction]()
        actions.append(deleteAction)
        if viewModel.canAddSubTask(todoItem: todoItem) {
            actions.append(addSubtaskAction)
        }
        let configuration = UISwipeActionsConfiguration(actions: actions)
        configuration.performsFirstActionWithFullSwipe = false

        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constant.tableViewHeight
    }
}

extension HomeViewController: EditViewControllerDelegate {
    
    func addTaskSuccess(title: String) {
        viewModel.addRootTask(title: title)
        let indexPathsEffect = viewModel.indexPathEffectAfterAddRoot()
        tableView.beginUpdates()
        tableView.insertRows(at: indexPathsEffect, with: .automatic)
        tableView.endUpdates()
    }
    
    func addSubTask(title: String, parent: TodoItem, atIndexPath: IndexPath) {
        viewModel.addSubtask(title: title, to: parent)
        let indexPaths = viewModel.indexPathEffectAfterAddSubTask(parent: parent)
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }
    
    func editTaskSuccess(withNewTitle: String, editAtIndexPath: IndexPath) {
        viewModel.todoItems[editAtIndexPath.row].title = withNewTitle
        tableView.reloadRows(at: [editAtIndexPath], with: .automatic)
    }
}

extension HomeViewController: TodoItemCellDelegate {
    func didTapCompleteButton(inCell cell: HomeTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let indexPathEffect = viewModel.toggleCompletion(for: indexPath.row)
        tableView.reloadRows(at: indexPathEffect, with: .automatic)
    }
}
