//
//  ProfileViewController.swift
//  Centigrade
//
//  Created by Juri Noga on 06.04.17.
//  Copyright © 2017 Juri Noga. All rights reserved.
//

import UIKit
import CentigradeKit
import CoreLocation

protocol ProfileCardControllerDelegate: class{
  func dismissPressed()
}

final class ProfileViewController : UIViewController {
  
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var profilePlaceholderImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
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
  @IBOutlet weak var addButton: UIButton!
  
  weak var delegate : ProfileCardControllerDelegate?
  
  var isEditingProfile = false
  var user : UserObject = CoreDataFactory.user
  var weatherHistoryPoints : [WeatherDataPoint] = []
  var locationTitles : [String?] = []
  let geocoder = CLGeocoder()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupSegmentedControl()
    updateAutomaticCell()
    updateSegmentCell()
    editProfileButton.setTitle(NSLocalizedString("EDIT_PROFILE_BUTTON", comment: "Edit Profile"), for: .normal)
    automaticLabel.text = NSLocalizedString("AUTOMATIC_LABEL", comment: "Automatic")
    unitsLabel.text = NSLocalizedString("UNITS_LABEL", comment: "Units")
    addButton.setTitle(NSLocalizedString("ADD_BUTTON", comment: "Add"), for: .normal)
    profilePlaceholderImageView.image = profilePlaceholderImageView.image?.withRenderingMode(.alwaysTemplate)
    profilePlaceholderImageView.tintColor = .gray
    nameField.placeholder = NSLocalizedString("YOUR_NAME_LABEL", comment: "Your Name")
    nameField.text = user.name
    profileTableView.register(UINib(nibName: WeatherHistoryViewCell.classString(), bundle:nil), forCellReuseIdentifier: WeatherHistoryViewCell.classString())
    loadHistory()
    guard let imageData = user.imageData else { return }
    profilePlaceholderImageView.image = nil
    DispatchQueue.global(qos: .userInitiated).async {
      let image = UIImage(data: imageData as Data)
      DispatchQueue.main.async {
        self.profileImageView.image = image
      }
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.layer.cornerRadius = profileImageView.frame.height/2
  }
  
  @IBAction func editProfilePressed(_ sender: Any) {
    if isEditingProfile {
      toggleProfileEdit(isOn: false)
    }else{
      toggleProfileEdit(isOn: true)
    }
  }
  
  func toggleProfileEdit(isOn : Bool){
    isEditingProfile = isOn
    nameField.isEnabled = isOn
    
    let imageAlpha : CGFloat
    let addButtonAlpha : CGFloat
    if isOn{
      addButton.isHidden = false
      addButtonAlpha = 1
      imageAlpha = 0.17
      editProfileButton.setTitle(NSLocalizedString("DONE_BUTTON", comment: "Done"), for: .normal)
      nameField.becomeFirstResponder()
    }else{
      addButtonAlpha = 0
      imageAlpha = 1
      editProfileButton.setTitle(NSLocalizedString("EDIT_PROFILE_BUTTON", comment: "Edit Profile"), for: .normal)
      nameField.resignFirstResponder()
      user.name = nameField.text
    }
    
    UIView.animate(withDuration: 0.3, animations: {
      self.profileImageView.alpha = imageAlpha
      self.addButton.alpha = addButtonAlpha
      self.profilePlaceholderImageView.alpha = imageAlpha
    }) { _ in
      self.addButton.isHidden = !isOn
    }
  }
  
  func loadHistory(){
    CoreDataFactory.fetchWeatherHistory { (points) in
      self.weatherHistoryPoints = points
      for _ in 0..<points.count{
        self.locationTitles.append(nil)
      }
      DispatchQueue.main.async {
        self.profileTableView.reloadSections([1], with: .automatic)
      }
    }
  }
  
  @IBAction func addImagePressed(_ sender: Any) {
    let ac = UIAlertController(title: NSLocalizedString("PROFILE_IMAGE_LABEL", comment: "Profile image"), message: NSLocalizedString("PICTURE_QUESTION_LABEL", comment: "How do you want to add your profile pic?"), preferredStyle: .actionSheet)
    
    if UIImagePickerController.isSourceTypeAvailable(.camera){
      let cameraAction = UIAlertAction(title: NSLocalizedString("TAKE_CAMERA_LABEL", comment: "Take using camera"), style: .default, handler: { (action) in
        self.createImagePicker(with: .camera)
      })
      ac.addAction(cameraAction)
    }
    
    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
      let libraryAction = UIAlertAction(title: NSLocalizedString("FROM_LIBRARY_LABEL", comment: "Choose from library"), style: .default, handler: { (action) in
        self.createImagePicker(with: .photoLibrary)
      })
      ac.addAction(libraryAction)
    }
    ac.addAction(UIAlertAction(title: NSLocalizedString("CANCEL_LABEL", comment: "Cancel"), style: .cancel, handler: nil))
    
    present(ac, animated: true, completion: nil)
    
  }
  
  func updateAutomaticCell(){
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
  
  func updateSegmentCell(){
    let labelAlpha : CGFloat
    let isAutomatic : Bool
    if let _ = UserSettings.customTemperatureUnit{
      labelAlpha = 1
      isAutomatic = false
    }else{
      labelAlpha = 0.3
      isAutomatic = true
    }
    unitSegment.isEnabled = !isAutomatic
    UIView.animate(withDuration: 0.3, animations: {
      self.unitsLabel.alpha = labelAlpha
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
    profileTableView.reloadSections([0], with: .none)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
      self.profileTableView.reloadSections([1], with: .none)
    }
  }
  
  @IBAction func automaticDidSwitch(_ sender: Any) {
    if automaticSwitch.isOn{
      UserSettings.customTemperatureUnit = nil
    }else{
      UserSettings.customTemperatureUnit = UserSettings.defaultTemperatureUnit
    }
    updateAutomaticCell()
    updateSegmentCell()
    profileTableView.reloadSections([0], with: .none)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.profileTableView.reloadSections([1], with: .none)
    }

  }
  
  @IBAction func chevronPressed(_ sender: Any) {
    delegate?.dismissPressed()
  }
  
  func createImagePicker(with type : UIImagePickerControllerSourceType){
    guard UIImagePickerController.isSourceTypeAvailable(type) else { return }
    let ivc = UIImagePickerController()
    ivc.delegate = self
    ivc.sourceType = type
    ivc.allowsEditing = true
    present(ivc, animated: true, completion: nil)
  }
  
  func processSelectedImage(image : UIImage){
    profilePlaceholderImageView.isHidden = true
    profileImageView.image = image
    user.imageData = UIImageJPEGRepresentation(image, 0.5) as NSData?
  }
  
}

extension ProfileViewController : UITableViewDataSource{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0{
      return 2
    }else{
      return weatherHistoryPoints.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0{
      if indexPath.row == 0{
        return automaticCell
      }else{
        return unitCell
      }
    }else{
      let cell = tableView.dequeueReusableCell(withIdentifier: WeatherHistoryViewCell.classString()) as! WeatherHistoryViewCell
      let point = weatherHistoryPoints[indexPath.row]
      cell.set(to: point)
      return cell
    }
  }
}

extension ProfileViewController : UITableViewDelegate{
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.section == 0 && indexPath.row == 0{
      automaticSwitch.setOn(!automaticSwitch.isOn, animated: true)
      automaticDidSwitch(automaticSwitch)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0{
      return 44
    }else{
      return 55
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0{
      return NSLocalizedString("TEMPERATURE_UNITS_LABEL", comment: "Temperature units")
    }else{
      return NSLocalizedString("WEATHER_HISTORY_LABEL", comment: "Weather history")
    }
  }
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0{
      if let unit = UserSettings.customTemperatureUnit{
        switch unit {
        case UnitTemperature.celsius: return NSLocalizedString("CELSIUS_UNIT_DESCRIPTION", comment: "")
        case UnitTemperature.fahrenheit: return NSLocalizedString("FAHRENHEIT_UNIT_DESCRIPTION", comment: "")
        case UnitTemperature.kelvin: return NSLocalizedString("KELVIN_UNIT_DESCRIPTION", comment: "")
        default: return nil
        }
      }else{
        return String(format: NSLocalizedString("AUTOMATIC_UNIT_DESCRIPTION", comment: "Centigrade will show temperature in units based on phone's default settings. Currently using: %@"), UserSettings.defaultTemperatureUnit.symbol)
      }
    }else{
      if weatherHistoryPoints.count == 0{
        return NSLocalizedString("NO_HISTORY_LABEL", comment: "No recent history.")
      }else{
        return nil
      }
    }
  }
}

extension ProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
      processSelectedImage(image: editedImage)
    }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
      processSelectedImage(image: originalImage)
    }
    dismiss(animated: true, completion: nil)
  }
}

extension ProfileViewController : UITextFieldDelegate{
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameField.resignFirstResponder()
    user.name = nameField.text
    return true
  }
}
