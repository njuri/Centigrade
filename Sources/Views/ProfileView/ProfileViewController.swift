//
//  ProfileViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 06.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit

protocol ProfileCardControllerDelegate: class{
  func dismissPressed()
}

final class ProfileViewController : UIViewController {
  
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var profileTableView: UITableView!
  
  @IBOutlet var automaticCell: UITableViewCell!
  @IBOutlet var unitCell: UITableViewCell!
  @IBOutlet weak var automaticSwitch: UISwitch!
  @IBOutlet weak var automaticLabel: UILabel!
  @IBOutlet weak var unitSegment: UISegmentedControl!
  @IBOutlet weak var unitsLabel: UILabel!
  
  @IBOutlet weak var chevronIcon: UIImageView!
  @IBOutlet weak var chevronButton: UIButton!
  @IBOutlet weak var editProfileButton: UIButton!
  
  weak var delegate : ProfileCardControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupSegmentedControl()
    setupAutomaticCell()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.layer.cornerRadius = profileImageView.frame.height/2
  }
  
  @IBAction func editProfilePressed(_ sender: Any) {
  }
  
  func setupAutomaticCell(){
    let labelAlpha : CGFloat
    let isAutomatic : Bool
    if let _ = UserSettings.customTemperatureUnit{
      labelAlpha = 0.3
      isAutomatic = false
    }else{
      labelAlpha = 1
      isAutomatic = true
    }
    automaticSwitch.setOn(isAutomatic, animated: true)
    UIView.animate(withDuration: 0.3, animations: {
      self.automaticLabel.alpha = labelAlpha
    })
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
    case 1: UserSettings.customTemperatureUnit = .fahrenheit
    case 2: UserSettings.customTemperatureUnit = .kelvin
    default: print("")
    }
  }
  
  @IBAction func automaticDidSwitch(_ sender: Any) {
    
    if automaticSwitch.isOn{
      UserSettings.customTemperatureUnit = nil
      profileTableView.deleteRows(at: [IndexPath(row: 1, section:0)], with: .automatic)
    }else{
      UserSettings.customTemperatureUnit = UserSettings.defaultTemperatureUnit
      profileTableView.insertRows(at: [IndexPath(row: 1, section:0)], with: .automatic)
    }
    setupAutomaticCell()
  }

  @IBAction func chevronPressed(_ sender: Any) {
    delegate?.dismissPressed()
  }
  
}

extension ProfileViewController : UITableViewDataSource{
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

extension ProfileViewController : UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    automaticSwitch.setOn(!automaticSwitch.isOn, animated: true)
    automaticDidSwitch(automaticSwitch)
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Temperature units"
  }
}
