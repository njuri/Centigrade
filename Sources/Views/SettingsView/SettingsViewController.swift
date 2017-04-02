//
//  SettingsViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 02.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit

final class SettingsViewController: UIViewController {
  
  
  @IBOutlet weak var settingsTableView: UITableView!
  @IBOutlet var automaticCell: UITableViewCell!
  @IBOutlet var unitCell: UITableViewCell!
  @IBOutlet weak var automaticSwitch: UISwitch!
  @IBOutlet weak var automaticLabel: UILabel!
  @IBOutlet weak var unitSegment: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Settings"
    // Do any additional setup after loading the view.
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
    setupSegmentedControl()
  }
  
  func donePressed(){
    dismiss(animated: true)
  }
  
  func setupSegmentedControl(){
    switch UserSettings.currentTemperatureUnit{
    case UnitTemperature.celsius: unitSegment.selectedSegmentIndex = 0
    case UnitTemperature.fahrenheit: unitSegment.selectedSegmentIndex = 1
    case UnitTemperature.kelvin: unitSegment.selectedSegmentIndex = 2
    default: print("")
    }
  }
  
  @IBAction func segmentDidChange(_ sender: Any) {
    switch unitSegment.selectedSegmentIndex{
    case 0: UserSettings.customTemperatureUnit = .celsius
    case 1: UserSettings.customTemperatureUnit = .celsius
    case 2: UserSettings.customTemperatureUnit = .celsius
    default: print("")
    }
  }
  
  
  @IBAction func automaticDidSwitch(_ sender: Any) {
    
    if automaticSwitch.isOn{
      UserSettings.customTemperatureUnit = nil
      settingsTableView.deleteRows(at: [IndexPath(row: 1, section:0)], with: .automatic)
      UIView.animate(withDuration: 0.3, animations: {
        self.automaticLabel.alpha = 1
      })
    }else{
      UserSettings.customTemperatureUnit = UserSettings.defaultTemperatureUnit
      settingsTableView.insertRows(at: [IndexPath(row: 1, section:0)], with: .automatic)
      UIView.animate(withDuration: 0.3, animations: { 
        self.automaticLabel.alpha = 0.3
      })
    }

  }
  
}

extension SettingsViewController : UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let _ = UserSettings.customTemperatureUnit{
      return 2
    }else{
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0{
      return automaticCell
    }else{
      return unitCell
    }
  }
}

extension SettingsViewController : UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    automaticSwitch.setOn(!automaticSwitch.isOn, animated: true)
    automaticDidSwitch(automaticSwitch)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Temperature units"
  }
}
