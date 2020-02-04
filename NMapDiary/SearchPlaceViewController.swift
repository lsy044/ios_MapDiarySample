//
//  SearchPlaceViewController.swift
//
//  Created by JIN on 20/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

/////// clientID랑 시크릿 git ignore ////////////
import UIKit
import NMapsMap
import Alamofire
import Firebase

class SearchPlaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //request
    @IBOutlet var queryField: UITextField! //장소명칭
    @IBOutlet weak var responseView: UITableView!
    
    let cellIdentifier: String = "cell"
    
    var placeArrays: [Place] = []
    var dataToSend: Place? = nil
    
    // for Search?
    var place : Place?
    var placeName: String?
    
    // MARK: Database Properties
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    var placeInfo: [String:String] = ["x":"", "y":""]
    
    // TableViewDataSource - required
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = responseView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceTableViewCell
        
        let place: Place = placeArrays[indexPath.row]
        cell.nameLabel.text = place.name
        cell.addressLabel.text = place.jibunAddress
        cell.tag = indexPath.row
        return cell
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArrays.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.responseView.dataSource = self
        self.responseView.delegate = self
    }
    
    // Search Button
    @IBAction func callSearchPlace (_sender: UIButton) {
        guard let query: String = queryField.text, query.isEmpty == false else{
            print("검색어입력해주세요")
            return
        }
        queryField.endEditing(true)
        search(query)
    }
    
    func search(_ query: String) {
        
        print("\(query)를 검색합니다 ")
        let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-place/v1/search")
        let param: Parameters = [ "query": queryField.text ?? "" , "coordinate": "127.029148,37.586568"]
        /* coordinate 나중에 CoreLocation으로 현재위치받아오기해보기 */
        
        //get response
        let request = Alamofire.request(url!, method: .get, parameters: param, encoding: URLEncoding.default, headers: ["X-NCP-APIGW-API-KEY-ID":"bbuvdesc40","X-NCP-APIGW-API-KEY":"edSqcVi8s5Qv5meC08kjEoMOVtgD3QbjwhOuTsFK"])
        request.response{(dataResponse) in
            // get data - decode
            guard let data: Data = dataResponse.data else {
                print("no data")
                return
            }
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let response: PlaceResponse
                response = try decoder.decode(PlaceResponse.self, from: data)
                // 결과의 places 정보를 배열에 담기
                if let places: [Place] = response.places {
                    self.placeArrays = places
                    print("\(places.count)검색됨")
                }
            } catch {
                print(error.localizedDescription)
            }
            self.responseView.reloadData()
        }
        //for test
        request.responseJSON() {(response) in
            print(response.result.value ?? "")
        }
    }
    
    // row 선택시 반응
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("\(indexPath.section)section의 \(indexPath.row)row를 선택함")
        
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.cellForRow(at: indexPath)
//        let place: Place = placeArrays[indexPath.row]
//

 
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        place = placeArrays[indexPath.row]
        placeName = place?.name
        if let placeX = place?.x , let placeY = place?.y {
            placeInfo = ["x": placeX, "y":placeY]
        }
        return indexPath
    }
    
    // dismiss
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

