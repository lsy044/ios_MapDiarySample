//
//  NcloudMapViewController.swift
//
//  Created by JIN on 17/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import UIKit
import NMapsMap
import FirebaseDatabase

public let DEFAULT_CAMERA_POSITION = NMFCameraPosition(NMGLatLng(lat: 37.584611, lng: 127.026581), zoom: 14, tilt: 0, heading: 0)

class NMapViewController: UIViewController, NMFMapViewDelegate {
    
    // Mobile Dynamic Map
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    weak var mapView: NMFMapView!
    
    @IBOutlet weak var levelStepper: UIStepper!
    var selectStateButton: UIButton?
    
    // 불러올 diary 데이터베이스 for Markers
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    var places: [[String:String]]! = []
    
    // for Markers
    let infoWindow = NMFInfoWindow()
    
    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    
    // marker에서 보낼 params
    //    var placeArrays: [Place] = []
    var dataToSend: [String:String]!
    
    // connect Database - for Markers
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
                for diary in diaryArrays {
                    self.places.append( diary.value["placeInfo"] as! [String : String] )
                }
            })
        print("\(self.places.count)장소들")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatabase()
        self.navigationController?.navigationBar.isTranslucent = false
        
        // Map Load
        mapView = naverMapView.mapView
        naverMapView.mapView.moveCamera(NMFCameraUpdate(position: DEFAULT_CAMERA_POSITION))
        
        naverMapView.positionMode = .normal
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: false)
        
        // Add Controls
        selectStateButton = createButton()
        if let button = selectStateButton  {
            view.addSubview(button)
        }
        
        mapView.addObserver(self, forKeyPath: "positionMode", options: [.new, .old, .prior], context: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("will")
        configureDatabase()
        //        showMarkers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("did")
        showMarkers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: Tracking Location
    func createButton() -> UIButton? {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 15, y: 30, width: 36, height: 36)
        button.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        return button
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        switch naverMapView.positionMode {
        case .disabled:
            return
        case .direction:
            selectStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
            self.naverMapView.positionMode = .normal
            print("disable")
        case .normal:
            selectStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
            self.naverMapView.positionMode = .direction
            print("direction to compass")
        case .compass:
            return
        }
    }
    
    // MARK: Marker 기능 - 옵셔널수정해야함
    func showMarkers() {
        for place in places {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: Double(place["y"]!)!, lng: Double(place["x"]!)!)
            
            marker.iconImage = NMFOverlayImage(name: "footprints")
            marker.width = 30
            marker.height = 30
//            marker.captionText = 
            
            // for markers-info window
            marker.touchHandler = { [weak self] (overlay: NMFOverlay) -> Bool in
                print("marker")
                
                let nextViewController =  self?.storyBoard.instantiateViewController(withIdentifier: "About") as! ShowDiaryViewController
                self?.navigationController?.pushViewController(nextViewController, animated: true)
                
                self?.dataToSend = place
                nextViewController.placeToget = self?.dataToSend
                print(self?.dataToSend)
                return true
            }
            marker.userInfo = ["y" : place["y"] ?? "", "x": place["x"] ?? ""]
            
            marker.mapView = mapView
            //            infoWindow.open(with: marker)
        }
        print("\(places.count)만큼 표시함")
        
        // 커스텀
        //        marker.iconImage = NMFOverlayImage(name: "marker_icon")
        //        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        //        marker.iconTintColor = UIColor.red
        //        marker.width = 25
        //        marker.height = NMF_MARKER_SIZE_AUTO
        //        marker.isFlat = true
        //        marker.captionRequestedWidth = 100
        //        marker.captionText = "아주아주아주아주아주 아주아주아주아주 긴 캡션"
        //        marker.captionAlign = .top
    }
    
    // segue Data 전달
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "fromMarker", let destination = segue.destination as? ShowDiaryViewController {
    //            destination.placeToget = self.dataToSend
    //        }
    //    }
}

extension NMGLatLng {
    func positionString() -> String {
        return String(format: "(%.5f, %.5f)", lat, lng)
    }
}
