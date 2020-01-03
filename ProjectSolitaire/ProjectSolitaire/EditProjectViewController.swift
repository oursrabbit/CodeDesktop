//
//  EditProjectViewController.swift
//  ProjectSolitaire
//
//  Created by 杨璨 on 2019/12/26.
//  Copyright © 2019 canyang. All rights reserved.
//

import UIKit

class EditProjectViewController: UIViewController {
    
    var editProject = Project();
    var editType = EditProjectType.Edit;
    
    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var projectStartDateTextField: UITextField!
    @IBOutlet weak var projectEndDateTextField: UITextField!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var currentEditDate = UITextField();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        projectNameTextField.text = editProject.Name;
        projectStartDateTextField.text = Utils.dateConvertString(date: editProject.StartDate)
        if let endDate = editProject.EndDate {
            projectEndDateTextField.text = Utils.dateConvertString(date: endDate)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func clearDate(_ sender: Any) {
        datePickerView.isHidden = true
        currentEditDate.text = nil
    }
    
    @IBAction func endEditDate(_ sender: Any) {
        datePickerView.isHidden = true
        currentEditDate.text = Utils.dateConvertString(date: datePicker.date);
    }
    
    public func prepareEdit(editProject: Project, editType: EditProjectType)
    {
        self.editProject = editProject;
        self.editType = editType;
    }
    
    @IBAction func updateProject(_ sender: Any) {
        switch editType {
        case .Create:
            addProject()
            break
        case .Edit:
            updateProject()
            break
        default:
            break
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func addProject() {
        editProject.Name = projectNameTextField.text!;
        
        if let startDate = Utils.stringConvertDate(string: projectStartDateTextField.text)
        {
            editProject.StartDate = startDate;
        }
        else
        {
            return;
        }
        
        editProject.EndDate = Utils.stringConvertDate(string: projectNameTextField.text)
        try! StaticData.realm.write {
            StaticData.realm.add(editProject)
        }
    }
    
    private func updateProject() {
        try! StaticData.realm.write {
            editProject.Name = projectNameTextField.text!;
            
            if let startDate = Utils.stringConvertDate(string: projectStartDateTextField.text)
            {
                editProject.StartDate = startDate;
            }
            else
            {
                return;
            }
            
            editProject.EndDate = Utils.stringConvertDate(string: projectEndDateTextField.text)
        }
    }
    
}

extension EditProjectViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentEditDate = textField;
        datePickerView.isHidden = false;
        return false;
    }
}
