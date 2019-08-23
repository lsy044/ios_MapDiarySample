//
//  NcloudMapViewController.swift
//
//  Created by JIN on 17/08/2019.
//  Copyright © 2019 sy. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NMapViewController: UIViewController, NMapViewDelegate, NMapPOIdataOverlayDelegate, NMapLocationManagerDelegate {

    //Mobile Dynamic Map
    var mapView: NMapView?
    @IBOutlet weak var levelStepper: UIStepper!
    var changeStateButton: UIButton?
    enum state {
        case disabled
        case tracking
        case trackingWithHeading
    }
    var currentState: state = .disabled
    
    // 불러올 diary 데이터베이스 for Markers
    var database: DatabaseReference!
    var diaryRecords: [String: [String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "diaryRecords"
    var places: [[String:String]]! = []
    
    // connect Database
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
        
        mapView = NMapView(frame: self.view.frame)
        self.navigationController?.navigationBar.isTranslucent = false
        
        if let mapView = mapView {
            
            // set the delegate for map view
            mapView.delegate = self
            
            // set the application api key for Open MapViewer Library
            mapView.setClientId("bbuvdesc40")
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // 레이어 커스텀...
//            setLayerGroup(NMF_LAYER_GROUP_BUILDING,isEnabled: false)
//            let NMF_LAYER_GROUP_BUILDING: String?
//            mapView.setMapViewBuildingMode(false)
//            mapView.setMapViewTrafficMode(false)
            view.addSubview(mapView)
        }
        
        // Add Controls
        changeStateButton = createButton()
        
        if let button = changeStateButton {
            view.addSubview(button)
        }
        
        // Zoom 용 UIStepper 셋팅
        if let min: Int32 = mapView?.minZoomLevel(), let max: Int32 = mapView?.maxZoomLevel() {
            initLevelStepper(min, maxValue: max, initialValue:11)
        }
        view.bringSubview(toFront: levelStepper)
        //        mapView?.setBuiltInAppControl(true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDatabase()
        mapView?.viewWillAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mapView?.viewDidDisappear()
    }
    
    // MARK: - NMapViewDelegate
    public func onMapView(_ mapView: NMapView!, initHandler error: NMapError!) {
        if (error == nil) { // success
            // set map center and level
            mapView.setMapCenter(NGeoPoint(longitude:126.978371, latitude:37.5666091), atLevel:11)
            // set for retina display
            mapView.setMapEnlarged(true, mapHD: true)
        } else { // fail
            print("onMapView:initHandler: \(error.description)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView?.viewDidAppear()
        
        showMarkers()
        print("didappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView?.viewWillDisappear()
        stopLocationUpdating()
    }
    
    // MARK: - NMapPOIdataOverlayDelegate
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForOverlayItem poiItem: NMapPOIitem!, selected: Bool) -> UIImage! {
        return NMapViewResources.imageWithType(poiItem.poiFlagType, selected: selected)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, anchorPointWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResources.anchorPoint(withType: poiFlagType)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, calloutOffsetWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForCalloutOverlayItem poiItem: NMapPOIitem!, constraintSize: CGSize, selected: Bool, imageForCalloutRightAccessory: UIImage!, calloutPosition: UnsafeMutablePointer<CGPoint>!, calloutHit calloutHitRect: UnsafeMutablePointer<CGRect>!) -> UIImage! {
        return nil
    }
    
    // MARK: - NMapLocationManagerDelegate Methods
    open func locationManager(_ locationManager: NMapLocationManager!, didUpdateTo location: CLLocation!) {
        
        let coordinate = location.coordinate
        
        let myLocation = NGeoPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        let locationAccuracy = Float(location.horizontalAccuracy)
        
        mapView?.mapOverlayManager.setMyLocation(myLocation, locationAccuracy: locationAccuracy)
        mapView?.setMapCenter(myLocation)
    }
    
    open func locationManager(_ locationManager: NMapLocationManager!, didFailWithError errorType: NMapLocationManagerErrorType) {
        
        var message: String = ""
        
        switch errorType {
        case .unknown: fallthrough
        case .canceled: fallthrough
        case .timeout:
            message = "일시적으로 내위치를 확인 할 수 없습니다."
        case .denied:
            message = "위치 정보를 확인 할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오."
        case .unavailableArea:
            message = "현재 위치는 지도내에 표시할 수 없습니다."
        case .heading:
            message = "나침반 정보를 확인 할 수 없습니다."
//        case .default:
//                message = "default" //
        }
        
        if (!message.isEmpty) {
            let alert = UIAlertController(title:"NMapViewer", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK", style:.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        if let mapView = mapView, mapView.isAutoRotateEnabled {
            mapView.setAutoRotateEnabled(false, animate: true)
        }
    }
    
    // NMapLocationManagerDelegate - additional
    func locationManager(_ locationManager: NMapLocationManager!, didUpdate heading: CLHeading!) {
        let headingValue = heading.trueHeading < 0.0 ? heading.magneticHeading : heading.trueHeading
        setCompassHeadingValue(headingValue)
    }
    
    func onMapViewIsGPSTracking(_ mapView: NMapView!) -> Bool {
        return NMapLocationManager.getSharedInstance().isTrackingEnabled()
    }
    
    func findCurrentLocation() {
        enableLocationUpdate()
    }
    
    func setCompassHeadingValue(_ headingValue: Double) {
        if let mapView = mapView, mapView.isAutoRotateEnabled {
            mapView.setRotateAngle(Float(headingValue), animate: true)
        }
    }
    
    func stopLocationUpdating() {
        disableHeading()
        disableLocationUpdate()
    }
    
    // MARK: - My Location
    func enableLocationUpdate() {
        if let lm = NMapLocationManager.getSharedInstance() {
            
            if lm.locationServiceEnabled() == false {
                locationManager(lm, didFailWithError: .denied)
                return
            }
            
            if lm.isUpdateLocationStarted() == false {
                // set delegate
                lm.setDelegate(self)
                // start updating location
                lm.startContinuousLocationInfo()
            }
            print("true")
            print(lm)
        }
    }
    
    func disableLocationUpdate() {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            if lm.isUpdateLocationStarted() {
                // start updating location
                lm.stopUpdateLocationInfo()
                // set delegate
                lm.setDelegate(nil)
            }
        }
        mapView?.mapOverlayManager.clearMyLocationOverlay()
    }
    
    // MARK: - Compass
    func enableHeading() -> Bool {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            let isAvailableCompass = lm.headingAvailable()
            if isAvailableCompass {
                mapView?.setAutoRotateEnabled(true, animate: true)
                lm.startUpdatingHeading()
            } else {
                return false
            }
        }
        return true
    }
    
    func disableHeading() {
        if let lm = NMapLocationManager.getSharedInstance() {
            
            let isAvailableCompass = lm.headingAvailable()
            if isAvailableCompass {
                lm.stopUpdatingHeading()
            }
        }
        mapView?.setAutoRotateEnabled(false, animate: true)
    }
    
    // MARK: - Button Control
    func createButton() -> UIButton? {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 15, y: 30, width: 36, height: 36)
        button.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func buttonClicked(_ sender: UIButton!) {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            switch currentState {
            case .disabled:
                enableLocationUpdate()
                updateState(.tracking)
            case .tracking:
                let isAvailableCompass = lm.headingAvailable()
                
                if isAvailableCompass {
                    enableLocationUpdate()
                    if enableHeading() {
                        updateState(.trackingWithHeading)
                    }
                } else {
                    stopLocationUpdating()
                    updateState(.disabled)
                }
            case .trackingWithHeading:
                stopLocationUpdating()
                updateState(.disabled)
            }
        }
    }
    
    func updateState(_ newState: state) {
        
        currentState = newState
        switch currentState {
        case .disabled:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
        case .tracking:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
        case .trackingWithHeading:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_my"), for: .normal)
        }
    }
    
    // MARK: - Level Stepper
    func initLevelStepper(_ minValue: Int32, maxValue: Int32, initialValue: Int32) {
        levelStepper.minimumValue = Double(minValue)
        levelStepper.maximumValue = Double(maxValue)
        levelStepper.stepValue = 1
        levelStepper.value = Double(initialValue)
    }
    
    @IBAction func levelStepperValueChanged(_ sender: UIStepper) {
        mapView?.setZoomLevel(Int32(sender.value))
    }
    
    // MARK: - Marker 기능 - 옵셔널수정해야함
    func showMarkers() {
        if let mapOverlayManager = mapView?.mapOverlayManager {
            // create POI data overlay
            if let poiDataOverlay = mapOverlayManager.newPOIdataOverlay() {
                poiDataOverlay.initPOIdata(Int32(self.places.count))
                for place in places {
                    poiDataOverlay.addPOIitem(atLocation: NGeoPoint(longitude: Double(place["x"]!)!, latitude: Double(place["y"]!)!), title: "마커", type: UserPOIflagTypeDefault, iconIndex: 0, with: nil)
                }
                poiDataOverlay.endPOIdata()
                
                // show all POI data
                poiDataOverlay.showAllPOIdata()
                poiDataOverlay.selectPOIitem(at: 2, moveToCenter: false, focusedBySelectItem: true)

            }
        }
        print("\(places.count)만큼 표시함")
    }

    
//    func clearOverlays() {
//        if let mapOverlayManager = mapView?.mapOverlayManager {
//            mapOverlayManager.clearOverlays()
//        }
//    }

    
}
