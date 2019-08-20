//
//  SearchPlaceViewController.swift
//  NMapTest
//
//  Created by JIN on 20/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//
/////// clientID랑 시크릿 git ignore ////////////
import UIKit
import Alamofire

class SearchPlaceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //request
    @IBOutlet var query: UITextField! //장소명칭
    
    @IBOutlet var place: UILabel!
    @IBOutlet weak var responseView: UITableView!
    let cellIdentifier: String = "cell"
    var places: [Place] = []

    // TableViewDataSource - required
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = responseView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PlaceTableViewCell
        
        let place: Place = self.places[indexPath.row]
        
        cell.textLabel?.text = place.name
        //        cell.nameLabel.text = place.name
        
        //        // 비동기 - 백그라운드포함 어디에서나 동작 (ex 이미지받아오기)
        //        DispatchQueue.global().async {
        //            // cell의 움직임에 대한 인덱스변화와 이미지 맞추기
        //            if let index: IndexPath = self.responseView.indexPath(for: cell) {
        //                if index.row == indexPath.row {
        //
        //                }
        //            }
        //            // 비동기 - 메인스레드에서 실행할 메소드 (ex 이미지셋팅)
        //            DispatchQueue.main.async { }
        //        }
        //
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.responseView.dataSource = self
        self.responseView.delegate = self
    }
    
    // Search Button
    @IBAction func callSearchPlace(_sender: UIButton) {
        print("sy")
        
        let url = URL(string: "https://naveropenapi.apigw.ntruss.com/map-place/v1/search")
        let param: Parameters = [ "query": query.text ?? "" , "coordinate": "127.029148,37.586568"]
        
        AF.request(
            url!, method: .get, parameters: param, encoding: URLEncoding.default, headers: ["X-NCP-APIGW-API-KEY-ID":"","X-NCP-APIGW-API-KEY":""])
            
            .validate()
            .responseJSON() { response in
                print("성공여부 : \(response.result)")
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any],
                        let info = json["places"] as? [[String: Any]] {
                        print(info.first?["name"] as! String)
                    }
                case .failure(_): break
                }
            }
    }
    
    
}
