//  CreateGistViewController.swift
//  Gist


import Foundation
import XLForm


class CreateGistViewController: XLFormViewController {
    
    
    //MARK: -  init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeForm()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.initializeForm()
    }
    
    
    //MARK: - Supporting methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.cancel,
            target: self,
            action: #selector(cancelPressed(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.save,
            target: self,
            action: #selector(savePressed(_:)))
    }
    
    fileprivate func initializeForm() {
        let form = XLFormDescriptor(title: "Gist")
        
        // Section 1
        let section1 = XLFormSectionDescriptor.formSection() as XLFormSectionDescriptor
        form.addFormSection(section1)
        
        let descriptionRow = XLFormRowDescriptor(tag: "description", rowType:
            XLFormRowDescriptorTypeText, title: "Description")
        descriptionRow.isRequired = true
        section1.addFormRow(descriptionRow)
        
        let isPublicRow = XLFormRowDescriptor(tag: "isPublic", rowType:
            XLFormRowDescriptorTypeBooleanSwitch, title: "Public?")
        isPublicRow.isRequired = false
        section1.addFormRow(isPublicRow)
        
        let section2 = XLFormSectionDescriptor.formSection(withTitle: "File 1") as
        XLFormSectionDescriptor
        form.addFormSection(section2)
        
        let filenameRow = XLFormRowDescriptor(tag: "filename", rowType:
            XLFormRowDescriptorTypeText, title: "Filename")
        filenameRow.isRequired = true
        section2.addFormRow(filenameRow)
        
        let fileContent = XLFormRowDescriptor(tag: "fileContent", rowType:
            XLFormRowDescriptorTypeTextView, title: "File Content")
        fileContent.isRequired = true
        section2.addFormRow(fileContent)
        
        self.form = form
    }
    
    
    //MARK: - Save / Cancel
    func cancelPressed(_ button: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func savePressed(_ button: UIBarButtonItem) {
        let validationErrors = self.formValidationErrors() as? [NSError]
        guard validationErrors?.count == 0 else {
            self.showFormValidationError(validationErrors!.first)
            return
        }
        
        self.tableView.endEditing(true)
        let isPublic: Bool
        if let isPublicValue = form.formRow(withTag: "isPublic")?.value as? Bool {
            isPublic = isPublicValue
        } else {
            isPublic = false
        }
        
        guard let description = form.formRow(withTag: "description")?.value as? String,
            let filename = form.formRow(withTag: "filename")?.value as? String,
            let fileContent = form.formRow(withTag: "fileContent")?.value as? String else {
                print("could not get values from creation form")
                return
        }
        
        var files = [File]()
        if let file = File(aName: filename, aContent: fileContent) {
            files.append(file)
        }
        
        GitHubAPIManager.sharedInstance.createNewGist(description, isPublic: isPublic, files: files) {
            result in
            guard result.error == nil,
                let successValue = result.value
                , successValue == true else {
                    print(result.error)
                    let alertController = UIAlertController(title: "Could not create gist",
                                                            message: "Sorry, your gist couldn't be created. " +
                        "Maybe GitHub is down or you don't have an internet connection.",
                                                            preferredStyle: .alert)
                    // add ok button
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated:true, completion: nil)
                    return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }

    
}  // end class
