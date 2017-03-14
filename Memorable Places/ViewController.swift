//
//  ViewController.swift
//  Memorable Places
//
//  Created by Ramon Gomez on 3/13/17.
//  Copyright © 2017 Ramon's. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    
    var manager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longpress(gestureRecognizer:)))
        
        uiLongPress.minimumPressDuration = 2
        
        map.addGestureRecognizer(uiLongPress)
        
        if activePlace == -1 {
            
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestWhenInUseAuthorization()
            manager.startUpdatingLocation()
            
        } else {
        
            if places.count > activePlace {
               
                if let name = places[activePlace]["name"] {
                    
                    if let lan = places[activePlace]["latitude"] {
                        
                        if let latitude = Double(lan) {
                            
                            if let lon = places[activePlace]["longitude"] {
                                
                                if let longitude = Double(lon) {
                                    
                                   let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                
                                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                    
                                    let region = MKCoordinateRegion(center: coordinate, span: span)
                                    
                                    self.map.setRegion(region, animated: true)
                                    
                                    let annotation = MKPointAnnotation()
                                    
                                    annotation.coordinate = coordinate
                                    
                                    annotation.title = name
                                    
                                    self.map.addAnnotation(annotation)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func longpress( gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = gestureRecognizer.location(in: self.map)
            let newCoordinate = self.map.convert(touchPoint, toCoordinateFrom: self.map)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            var title: String = ""
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placeMarks, error) in
                
                if error != nil {
                    
                    print(error!)
                } else {
                    
                    if let placemark = placeMarks?[0] {
                        
                        if placemark.subThoroughfare != nil {
                            title += placemark.subThoroughfare! + " "
                            
                        }
                        
                        if placemark.thoroughfare != nil {
                            title += placemark.thoroughfare! + " "
                        }
                        
                        if placemark.name != nil {
                            title = placemark.name! 
                        }
                    }
                }
                
                if title == "" {
                    
                    title = "Added \(NSDate())"
                }
                
                let annotation = MKPointAnnotation()
            
                annotation.coordinate = newCoordinate
                annotation.title = title
                
                self.map.addAnnotation(annotation)
                
                places.append(["name":title, "latitude": String(newCoordinate.latitude), "longitude": String(newCoordinate.longitude)])
                
                UserDefaults.standard.set(places, forKey: "places")
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        self.map.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

