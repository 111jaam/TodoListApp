//
//  EditViewController.swift
//  TodoListMVVM

import UIKit
import TodoData

protocol EditViewControllerDelegate: AnyObject {
    func addTaskSuccess(title: String)
    func addSubTask(title: String, parent: TodoItem, atIndexPath: IndexPath)
    func editTaskSuccess(withNewTitle: String, editAtIndexPath: IndexPath)
}

class EditViewController: UIViewController {

    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var inputTextField: UITextField!
    weak var delegate: EditViewControllerDelegate?
    
    var viewModel: EditViewModel! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI() {
        
        //Config Navigation Title
        let title = viewModel.titleForView()
        self.title = title
        
        //Config TextField Default Input
        inputTextField.text = viewModel.defaultInputText()
        
        //Config Save Button Status
        saveButton.isEnabled = viewModel.isEnableSaveButton(currentInputText: inputTextField.text ?? "")
        
        inputTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        guard let inputText = textField.text else { return }
        saveButton.isEnabled = viewModel.isEnableSaveButton(currentInputText: inputText)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        guard let input = inputTextField.text else { return }
    
        switch viewModel.getState() {
            
        case .addRootTask:
            delegate?.addTaskSuccess(title: input)
            self.navigationController?.popViewController(animated: true)
            break
        case .editTask:
            delegate?.editTaskSuccess(withNewTitle: input, editAtIndexPath: viewModel.getIndex())
            self.navigationController?.popViewController(animated: true)
            break
        case .addSubTask:
            delegate?.addSubTask(title: input, parent: viewModel.getTodoItem(), atIndexPath: viewModel.getIndex())
            self.navigationController?.popViewController(animated: true)
            break
        }
    }
}
