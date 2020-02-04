import UIKit
import os.log
import FirebaseDatabase
import FirebaseStorage

class LogDiaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Database Setting
    
    var database: DatabaseReference!
    var diaries: [String:[String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    
    
    // MARK: Properties
    
    @IBOutlet var logDiaryTableView: UITableView!
    let cellIdentifier = "logCell"
    
    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter
    }()
    
    // MARK: Actions
    
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName)
            .observe(.value, with: { (snapshot) -> Void in
                guard let diaries = snapshot.value as? [String:[String:Any]] else {
                    print("오류")
                    return
                }
                self.diaries = diaries
                self.logDiaryTableView.reloadData()
                print("new diary is published")
                print("total count: \(self.diaries.count)")
            })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        logDiaryTableView.delegate = self
        logDiaryTableView.dataSource = self
        
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        logDiaryTableView.reloadSections(IndexSet(0...0), with: .automatic)
    //    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let logDiaryTableviewCell = logDiaryTableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? LogDiaryTableViewCell else {
            fatalError("The dequeued cell is not an instance of ListTableViewCell.")
        }
        
        let diaryArray = Array(self.diaries)
        let diary = diaryArray[indexPath.row]
        
        if let diaryDateString = diary.value["diaryDate"],
            let diaryPlaceString = diary.value["diaryPlace"] {
            
            logDiaryTableviewCell.dateTableCellLabel?.text = diaryDateString as? String
            
            logDiaryTableviewCell.placeTableCellLabel?.text = diaryPlaceString as? String
            
            let diaryContentsString = diary.value["diaryContents"]
            logDiaryTableviewCell.contentsTableCellLabel?.text = diaryContentsString as? String
            
            logDiaryTableviewCell.tag = indexPath.row
            
        }
        
        return logDiaryTableviewCell
    }
    
    //테이블뷰에서 셀을 삭제합니다.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let diariesArray = Array(self.diaries)
            let diary = diariesArray[indexPath.row]
            let deletedURL = diary.value["diaryImageURL"]
            
            self.diaries.removeValue(forKey: diary.key)
            database.child(databaseName).child(diary.key).removeValue()
            
            let uploadRef = Storage.storage().reference(forURL: deletedURL as! String)
            uploadRef.delete {error in
                if let error = error {
                    print(error)
                } else {
                    // File deleted successfully
                }
            }
            
            logDiaryTableView.reloadSections(IndexSet(0...0), with: .automatic)
        }
    }
    
    
    //MARK: Naviagation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let selectedCell = sender as? LogDiaryTableViewCell {
            guard let nextViewController = segue.destination as? ShowDiaryViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            nextViewController.selectedDiaryPlaceString = selectedCell.placeTableCellLabel.text
            nextViewController.selectedDiaryDateString = selectedCell.dateTableCellLabel.text
            nextViewController.selectedDiaryContentsString = selectedCell.contentsTableCellLabel.text
            
            nextViewController.selectedDiaryIndexPath = selectedCell.tag
            print("\(selectedCell.tag)")
            
        } else {
            print("sender가 cell이 아님")
            return
        }
    }
}
