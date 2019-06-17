//
//  DiaryTableViewController.swift
//  QuickDiary
//
//  Created by Sano Gharzani on 2019-04-15.
//  Copyright © 2019 Sano Gharzani. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import CoreLocation


class AddDiaryViewController: UIViewController, UINavigationBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    // MARK: - Properties
    
    var managedContext: NSManagedObjectContext!
    var diary: Diary?
    
    // MARK: Outlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var imagebtn: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var streetNameNumber: UITextView!
    @IBOutlet weak var county: UILabel!
    
    let locationMan = CLLocationManager()
    let regionInMeters: Double = 1000
    var previousLoc: CLLocation?
    
    
    let imgPicker = UIImagePickerController()
    
    @IBAction func ImportImage(_ sender: UIButton) {
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = true
        present(imgPicker, animated: true, completion:nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgPicker.delegate = self
        checkLocServ()
        
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(with:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        textView.becomeFirstResponder()
        if let diary = diary {
            textView.text = diary.title
            textView.text = diary.title
            location.text = diary.city
            streetNameNumber.text = diary.adress
            if let img = diary.image{
                image.image  = UIImage(data: img as Data)
            }
        }
    }
    
    func setUpLocMan(){
        //code to setup the location of the user
        if(diary?.city! != nil && diary?.adress! != nil){
            locationMan.delegate = diary?.adress as? CLLocationManagerDelegate
            locationMan.desiredAccuracy = kCLLocationAccuracyBest
            
        }else {
        locationMan.delegate = self
        locationMan.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func centerViewOnUserLoc(){
        if let location = locationMan.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocServ(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocMan()
            CheckLocAuth()
        }
        else{
            print("Can not check location service")
        }
    }
    
  
    //check the Auth from user
    func CheckLocAuth(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
           trackUserLoc()
        case .notDetermined:
            locationMan.requestWhenInUseAuthorization()
        case .restricted:
            locationMan.requestWhenInUseAuthorization()
            print("Restricted")
            
        case .denied:
            locationMan.requestWhenInUseAuthorization()
            print("Denied")
           
        case .authorizedAlways:
            print("always")
           
        @unknown default:
            locationMan.requestWhenInUseAuthorization()
            print("Is unknown")
           
        }
    }
    
    func trackUserLoc() {
        mapView.showsUserLocation = true
        centerViewOnUserLoc()
        locationMan.startUpdatingLocation()
        previousLoc = getCenterLoc(for: mapView)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage{
            image.contentMode = .scaleAspectFit
            image.image = pickedImage
            
            //convert the image to data
            let imageData = pickedImage.jpegData(compressionQuality: 1)
            
            diary?.image = imageData
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: Actions
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    fileprivate func dismissAndResign() {
        dismiss(animated: true)
        textView.resignFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissAndResign()
    }
    
    @IBAction func done(_ sender: UIButton) {
        guard let title = textView.text, !title.isEmpty else {
            return
        }
        
        if let diary = self.diary {
            diary.title = title
            diary.city = String(location.text!)
            diary.adress = String(streetNameNumber.text!)
            diary.county = String(county.text!)
            if let img = diary.image{
                image.image  = UIImage(data: img as Data)
                print("done " , streetNameNumber.text!, location.text!)
            }
        } else {
            let diary = Diary(context: managedContext)
            diary.title = title
            diary.city = String(location.text!)
            diary.adress = String(streetNameNumber.text!)
            diary.county = String(county.text!)
            diary.date = Date()
            if let img = diary.image{
                image.image  = UIImage(data: img as Data)
            }
        }
        
        do {
            try managedContext.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)")
        }    }
    
    @IBAction func updateLocation(_ sender: UIButton) {
        //update location code
        checkLocServ()
    }
    
    func getCenterLoc(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        //print(" \(latitude) \(longitude)")
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
extension AddDiaryViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
    
}

extension AddDiaryViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        CheckLocAuth()
    }
}


extension AddDiaryViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLoc(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLoc = self.previousLoc else { return }
        
        guard center.distance(from: previousLoc) > 50 else { return }
        self.previousLoc = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else {return}
            
            if let _ = error {
                return
            }
            
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            let cityName = placemark.subAdministrativeArea ?? ""
            let areaName = placemark.administrativeArea ??  ""
        
            
            //print(streetNumber, streetName)
            
          /*  let diary = Diary(context: self.managedContext)
            diary.adress = placemark.thoroughfare ?? ""
            diary.city = placemark.subAdministrativeArea ?? ""*/
            
            
            DispatchQueue.main.async {
                self.location.text = "\(cityName)"
                self.streetNameNumber.text = "\(streetName)\(streetNumber)"
                self.county.text = "\(areaName)"
                
            }
        }
    }
}
