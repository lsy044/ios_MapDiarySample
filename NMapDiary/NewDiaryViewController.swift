//
//  NewDiaryViewController.swift
//  NMapDiary
//
//  Created by JIN on 23/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NewDiaryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UITextViewDelegate {

    // SearchPlaceView에서 받아온 장소데이터
    var data: Place? = nil
    @IBOutlet var placeNameLabel: UILabel!
    
    // IBOutlet - 기록필드
//    @IBOutlet var diaryPlaceField: UITextField!
    @IBOutlet var diaryContentsField: UITextView!
    @IBOutlet weak var diaryImageField: UIImageView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var diaryDateLabel: UILabel!
    let dateFormatter: DateFormatter =  {
        let formatter: DateFormatter = DateFormatter()
        
        formatter.dateStyle = .medium
        return formatter
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true //편집가능 //위치수정 -> 초기화시
        return picker
    }()
    
    // diary 데이터베이스
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    var placeInfo: [String:String] = ["x":"", "y":""]
    
//    //Dismiss modal - 취소
//    @IBAction func dismissSelf() {
//        self.dismiss(animated: true, completion: nil)
//    }
    
    //detect textField
//    @IBAction func textFieldTextEdited(_ sender: UITextField) {
//        determineButtonState()
//    }
    
//    //TapView - 키보드내림
//    @IBAction func tapView(_ sender: UITapGestureRecognizer) {
//        self.view.endEditing(true)
//    }
    
    //datePicker값 바뀔때
    @IBAction func didDatePickerValueChanged(_ sender: UIDatePicker) {
        //label에 date나오게
        let date: Date = self.datePicker.date //= sender.date
        let dateString: String = self.dateFormatter.string(from: date)
        self.diaryDateLabel.text = dateString
//        determineButtonState()
    }
    
    //Tap imageView - 사진첩불러오기
    @IBAction func tapImageView(_ sender: UITapGestureRecognizer) {
        print("True")
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    //Cancel Selecting Image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Select Image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage: UIImage =
            info[UIImagePickerControllerEditedImage] as? UIImage { //확인
            self.diaryImageField.image = editedImage
            //            determineButtonState() //profileImage 필수조건으로
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNewDiary(diaryPlace: String, diaryDate: String, diaryContents: String, placeInfo: [String:String] ) {
        let newDiary: [String: Any]
        newDiary = ["diaryPlace": diaryPlace, "diaryDate": diaryDate, "diaryConetents": diaryContents, "placeInfo": placeInfo]

        database.child(databaseName).childByAutoId().setValue(newDiary)
        print("새로운 일기가 추가되었습니다")
        print("총 개수: \(self.diaryRecords.count)")
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
    
    // diary저장 - optional 다시 선언해야함 필수조건정해서
    @IBAction func touchUpSaveButton(_sender: UIButton) {
        addNewDiary(diaryPlace: placeNameLabel.text!,
                    diaryDate: diaryDateLabel.text!,
                    diaryContents: diaryContentsField.text,
//                    diaryImage: (diaryImageField.image)!,
            placeInfo: (placeInfo))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        
        self.datePicker.addTarget(self, action: #selector(self.didDatePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 받아온 장소 데이터
        print(data ?? "no data")
        if let place: Place = data,
            let x: String =  place.x, let y: String = place.y {
            placeInfo["x"] = x
            placeInfo["y"] = y
            placeNameLabel.text = data?.name
            print(placeInfo)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
