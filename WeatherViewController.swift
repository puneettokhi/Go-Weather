
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "fe42c0d73df85ea5aa6d7261e8c3c9d9"
    

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()
    
    let weatherDataModel = WeatherDataModel()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        //TODO:Set up the location manager here.
    
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    
    
   
    
    //Write the getWeatherData method here:

    
    func getWeatherData(url : String, parameters : [String: String]){
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if(response.result.isSuccess){
                print("Success!!")

                let weatherJSON: JSON = JSON(response.result.value!)

                print(weatherJSON)
                
                self.updateWeatherData(json: weatherJSON)  // use self since we are in a closure
                
                
            }
            else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }

    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json :JSON){
        
        if  let tempResult = json["main"]["temp"].double{
            
            weatherDataModel.temp = Int((9/5)*(tempResult - 273)+32)
            
            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUI()
        }
            
        else{
            cityLabel.text = "Error loading data"
        }
    }
    
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUI(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temp)°F"
        weatherIcon.image = UIImage(named:weatherDataModel.weatherIconName)
        
    }
    

    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    
    
    //Write the didUpdateLocations method here:
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]   // the locations array's last element would be the most precise loation

        if (location.horizontalAccuracy > 0){

            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print ("lattitude is \(location.coordinate.latitude), longitude is \(location.coordinate.longitude) ")
        }

        let latitude = String(location.coordinate.latitude)
        let longitude = String(location.coordinate.longitude)

        let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid": APP_ID]

        getWeatherData(url : WEATHER_URL, parameters: params)


    }
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text  = "Location Unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        let params : [String: String] = ["q":city, "appid":APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
          let segueVC =  segue.destination as! ChangeCityViewController
            segueVC.delegate = self
        }
        
        
    }
    
    
    
    
}


