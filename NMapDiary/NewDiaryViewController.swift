//
//  NewDiaryViewController.swift
//  Demo
//
//  Created by cscoi008 on 2019. 8. 22..
//  Copyright © 2019년 cscoi008. All rights reserved.
//

import UIKit
import os.log
import FirebaseDatabase
import FirebaseStorage


class NewDiaryViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    // SearchPlaceView에서 받아온 장소데이터
    var data: Place? = nil
    
    var diaryImageURL : String?
    
    // MARK: Database
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    var newPlaceInfo: [String:String] = ["x":"", "y":""]
    
    
    // MARK: Properties
    
    @IBOutlet var newPlaceTextField: UITextField!
    @IBOutlet var newImageView: UIImageView!
    @IBOutlet var newContentsTextView: UITextView!
    @IBOutlet var newDateTextField: UITextField!
    @IBOutlet var newSaveButton: UIButton!
    
    // MARK: Date Picker 지우기
    let newDatePicker = UIDatePicker()
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: ImagePicker
    lazy var newImagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    
    @IBAction func unwindToNewDiaryView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? SearchPlaceViewController, let placeNameString = sourceViewController.placeName {
            newPlaceTextField.text = placeNameString
            newPlaceInfo = sourceViewController.placeInfo
        }
    }
    
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName)
            .observe(.value, with: { (snapshot) -> Void in
                guard let diaryRecords = snapshot.value as? [String: [String: Any]]
                    else {
                        return
                }
                self.diaryRecords = diaryRecords
            })
    }
    
    @IBAction func touchUpSaveButton() {
        
        let randomID = UUID.init().uuidString
        
        let uploadRef = Storage.storage().reference(withPath : "diaries/\(randomID).jpg")
        
        guard let imageData = UIImageJPEGRepresentation(self.newImageView.image!, 0.75) else {
            fatalError("error")
        }
        
        let uploadMetadata = StorageMetadata.init()
        
        uploadMetadata.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: uploadMetadata) {
            (downloadMetadata, error) in if let error = error {
                print("error\(error.localizedDescription)")
                return
            }
            print ("Put complete and I got \(String(describing: downloadMetadata))")
            
            uploadRef.downloadURL(completion: {(url, error) in
                if let error = error {
                    print ("fail to generate download URL \(error.localizedDescription)")
                    return
                }
                if let url = url {
                    print("Here is download url \(url.absoluteString)")
                    self.diaryImageURL = url.absoluteString
                }
                self.addNewDiary(diaryPlace: self.newPlaceTextField.text!,
                                 diaryDate: self.newDateTextField.text!,
                                 diaryContents: self.newContentsTextView.text,
                                 placeInfo: self.newPlaceInfo,
                                 diaryImageURL: (url?.absoluteString)!)
                
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    func addNewDiary(diaryPlace: String, diaryDate: String, diaryContents: String, placeInfo: [String:String], diaryImageURL: String) {
        
        let newDiary: [String: Any]
        
        newDiary = ["diaryPlace": diaryPlace, "diaryDate": diaryDate,
                    "diaryContents": diaryContents, "placeInfo": placeInfo,
                    "diaryImageURL": diaryImageURL]
        
        database.child(databaseName).childByAutoId().setValue(newDiary)
        print("새로운 일기가 추가되었습니다")
        print("총 개수: \(self.diaryRecords.count)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        newImagePicker.delegate = self
        newPlaceTextField.delegate = self
        newDateTextField.delegate = self
        
        navigationItem.title = "적어봄"
        
        //date picker 지우기
        self.newDatePicker.addTarget(self, action: #selector(self.didDatePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        let date: Date = Date()
        let dateString: String = self.dateFormatter.string(from: date)
        self.newDateTextField.text = dateString
        
        //image picker
        let imageTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapSelectImageView(_:)))
        self.newImageView.addGestureRecognizer(imageTapGesture)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 받아온 장소 데이터
        print(data ?? "newDiaryViewController가 받아온 장소가 없음: no data")
        if let place: Place = data,
            let x: String =  place.x, let y: String = place.y {
            newPlaceInfo["x"] = x
            newPlaceInfo["y"] = y
            newPlaceTextField.text = data?.name
            print(newPlaceInfo)
        }
        configureDatabase()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 편집하는 동안 저장 버튼을 비활성화합니다.
        newSaveButton.isEnabled = false
        
        if textField.tag == 0 {
            //모달로 장소검색창을 띄웁니다. 체크
            guard let searchViewController = storyboard?.instantiateViewController(withIdentifier: "SearchVC") as? SearchPlaceViewController else {
                return true
            }
            present(searchViewController, animated: true, completion: nil)
            return false
        } else {
            showDatePicker()
        }
        return true
    }
    
    //text field가 editing을 시작하면
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 편집하는 동안 저장 버튼을 비활성화합니다.
        newSaveButton.isEnabled = false
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNewSaveButtonState()
    }
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage : UIImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.newImageView.image = editedImage
            
            updateNewSaveButtonState()
        }else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Actions
    
    // MARK: -Image Picker Actions
    @IBAction func tapSelectImageView(_ sender: UITapGestureRecognizer){
        self.present(self.newImagePicker, animated:true, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        newPlaceTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: -DatePicker Actions 지우기
    @IBAction func didDatePickerValueChanged(_ sender: UIDatePicker){
        print("date changed")
        
        let date: Date = self.newDatePicker.date
        let dateString: String = self.dateFormatter.string(from: date)
        
        self.newDateTextField.text = dateString
    }
    
    func showDatePicker() {
        
        self.newDatePicker.addTarget(self, action: #selector(self.didDatePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        newDatePicker.datePickerMode = .date
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let cancelButton = UIBarButtonItem(title: "취소하기", style: .plain, target: self, action: #selector(cancelDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "입력", style: .plain, target: self, action: #selector(doneDatePicker))
        
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        
        newDateTextField.inputAccessoryView = toolbar
        newDateTextField.inputView = newDatePicker
        let date : Date = self.newDatePicker.date
        newDateTextField.text = dateFormatter.string(from: date)
    }
    
    @objc func doneDatePicker() {
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker() {
        
        let date : Date = self.newDatePicker.date
        newDateTextField.text = dateFormatter.string(from: date)
        
        self.view.endEditing(true)
    }
    
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateNewSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let placeText = newPlaceTextField.text ?? ""
        if self.newImageView != nil {
            newSaveButton.isEnabled = !placeText.isEmpty
        }
    }
    
    
    
}


