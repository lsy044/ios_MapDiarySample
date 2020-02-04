//
//  ShowDiaryViewController.swift
//  NMapDiary
//
//  Created by JIN on 26/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//
//configureBase 정리

import UIKit
import FirebaseDatabase
import FirebaseStorage

class ShowDiaryViewController: UIViewController {
    
    // 데이터베이스 로드
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    
    // - 불러올 diary 데이터베이스 for Markers
    var selectedDiary: [String: Any]! = [:]
    var placeToget: [String:String]!
    
    // MARK: Properties
    var selectedDiaryPlaceString: String?
    var selectedDiaryDateString: String?
    var selectedDiaryContentsString: String?
    var selectedDiaryIndexPath: Int?
    
    @IBOutlet var selectedDiaryPlaceLabel: UILabel!
    @IBOutlet var selectedDiaryDateLabel: UILabel!
    @IBOutlet var selectedDiaryImageView: UIImageView!
    @IBOutlet var selectedDiaryContentsTextView: UITextView!
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    // params에 맞는 데이터베이스고르기 - 예외처리해줘야함
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName)
            .observe(.value, with: { (snapshot) -> Void in
                guard let diaryRecords = snapshot.value as? [String: [String: Any]]
                    else {
                        return
                }
                self.diaryRecords = diaryRecords
                let diaryArrays = Array(self.diaryRecords)
                
                if self.placeToget == nil {
                    
                    // - From TableView
                    self.selectedDiaryPlaceLabel.text = self.selectedDiaryPlaceString
                    self.selectedDiaryDateLabel.text = self.selectedDiaryDateString
                    let diary = diaryArrays[self.selectedDiaryIndexPath!]
                    if let diaryContentsString = diary.value["diaryContents"] as? String {
                        self.selectedDiaryContentsTextView?.text = diaryContentsString
                    }
                    
                    let url = diary.value["diaryImageURL"] as! String
                    if let url = URL(string: url){
                        do {
                            let data = try Data(contentsOf: url)
                            let image = UIImage(data: data)
                            self.selectedDiaryImageView.image = image
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                } else if self.placeToget != nil {
                    // - From Map
                    for diary in diaryArrays {
                        //                    if let diaryPlace: [String : String] = diary.value["placeInfo"] as? [String : String] {
                        //                        if diaryPlace["x"] == self.placeToget["x"], diaryPlace["y"] == self.placeToget["y"] {
                        if diary.value["placeInfo"] as? [String : String] == self.placeToget {
                            print("match")
                            self.selectedDiary = diary.value
                        }
                    }
                }
            })
    }
    
    // fromMapInfo to Label
    func setLabel() {
        self.selectedDiaryPlaceLabel.text = self.selectedDiary["diaryPlace"] as? String
        self.selectedDiaryDateLabel.text = self.selectedDiary["diaryDate"] as? String
        
        let url = self.selectedDiary["diaryImageURL"] as? String
        if let url = URL(string: url!){
            do {
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                self.selectedDiaryImageView.image = image
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        self.selectedDiaryContentsTextView.text = self.selectedDiary["diaryContents"] as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.placeToget)
        configureDatabase()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureDatabase()
        
        if self.placeToget != nil {
            setLabel()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
