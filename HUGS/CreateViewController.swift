//
//  CreateViewController.swift
//  HUGS
//
//  Controller for View in which new HUGS wearable is added to the system
//

import UIKit
import os.log
import CoreBluetooth

class CreateViewController: UIViewController, UITextFieldDelegate {
    
    var currWeightLb : Double = 40.0;
    var timer = Timer()
    
    @IBOutlet weak var titleText: UINavigationItem!
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var weightLabel : UILabel!
    @IBOutlet var weightStepper : UIStepper!
    @IBOutlet var birthdayPicker: UIDatePicker!
    @IBOutlet var unitControl: UISegmentedControl!
    
    @IBOutlet weak var peripheralTableView: UITableView!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func refreshAction(_ sender: AnyObject) {
        if !(bleDelegate.bluetoothEnabled()) {
            print("Bluetooth is off")
            let bluetoothAlert = UIAlertController(title:"Bluetooth Off", message:"Please turn on Bluetooth to refresh", preferredStyle: .alert)
            bluetoothAlert.addAction(UIAlertAction(title:"Cancel", style:.default, handler: {_ in NSLog("Override Cancelled")}))
            self.present(bluetoothAlert, animated:true, completion:nil)
        }
        bleDelegate.refresh()
        self.timer.invalidate()
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(reloadTable), userInfo: nil, repeats: false)
        

    }
    
    @objc func reloadTable() {
        self.peripheralTableView.reloadData()
    }
    
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
        
        saveSystemVariables()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.systemFont(ofSize: 24)
        unitControl.setTitleTextAttributes([NSAttributedStringKey.font: font],
                                                    for: .normal)
        
        self.nameTextField.delegate = self;
        
        self.peripheralTableView.delegate = bleDelegate
        self.peripheralTableView.dataSource = bleDelegate
        self.peripheralTableView.reloadData()
        
        refreshAction(self);

        // Close TextField when clicked outside of keyboard region
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if let savedSystemVars = loadSystemVariables() {
           os_log("Successfully loaded system variables", log: OSLog.default, type:.debug)
            userVars.userName = savedSystemVars.userName
            userVars.userBirthday = savedSystemVars.userBirthday
            userVars.userWeight = savedSystemVars.userWeight
            configure()
        } else {
            os_log("Did not load system variables", log: OSLog.default, type:.debug)
        }
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        birthdayPicker.date = userVars.userBirthday
        birthdayPicker.maximumDate = Date()
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
    
    func saveSystemVariables() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(userVars, toFile:VarsArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Successfully saved system variables", log: OSLog.default, type:.debug)
        } else {
            os_log("Error saving system variables", log: OSLog.default, type:.error)
        }
    }
    
    func loadSystemVariables() -> SystemVariables? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: VarsArchiveURL.path) as? SystemVariables
    }
}


class PeripheralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var peripheralLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
