//
//  CreateViewController.swift
//  HUGS
//
//  Controller for View in which new HUGS wearable is added to the system
//

import UIKit

class CreateViewController: UIViewController, UITextFieldDelegate {
    
    var currWeightLb : Double = 40.0;
    
    @IBOutlet weak var titleText: UINavigationItem!
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var weightLabel : UILabel!
    @IBOutlet var weightStepper : UIStepper!
    @IBOutlet var birthdayPicker: UIDatePicker!
    @IBOutlet var unitControl: UISegmentedControl!
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        currWeightLb = sender.value
        if (unitControl.selectedSegmentIndex == 0) {
            weightLabel.text = (sender.value).description
        } else {
            weightLabel.text = String(format:"%.2f", currWeightLb / 2.2)
        }
    }
    
    @IBAction func unitValueChanged(_ sender: Any) {
        if (unitControl.selectedSegmentIndex == 0) {
            weightLabel.text = String(format:"%.1f", currWeightLb)
        } else {
            weightLabel.text = String(format:"%.2f", currWeightLb / 2.2)
        }
    }
    
    @IBAction func createButtonClicked(_ sender: Any) {
        userVars.userName = nameTextField.hasText ? nameTextField.text! : "Unnamed"
        userVars.userBirthday = birthdayPicker.date
        userVars.userWeight = currWeightLb
        configure()
        
        let mainViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        self.navigationController?.pushViewController(mainViewController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTextField.delegate = self;

        // Close TextField when clicked outside of keyboard region
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        birthdayPicker.maximumDate = userVars.userBirthday
        weightLabel.text = userVars.userWeight.description
        unitControl.selectedSegmentIndex = 0
        weightStepper.value = userVars.userWeight
        nameTextField.text = userVars.userName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Close text field when return button clicked
    func textFieldShouldReturn(nameTextField: UITextField!) -> Bool {
        nameTextField.resignFirstResponder();
        self.view.endEditing(true)
        return true;
    }

}

