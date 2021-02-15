//
//  CurrancyExchangeService.swift
//  PenguinPay
//
//

import Foundation

enum CurrancyExchangeError: Error {
  case invalidResponse
  case noData
  case failedRequest
  case invalidData
}

class CurrancyExchangeService {
  typealias CurrancyExchangeDataCompletion = (ExchangeData?, CurrancyExchangeError?) -> ()
  
  private static let app_id = "288da399046b47388375fd764b111296"
  private static let host = "openexchangerates.org"
  private static let path = "/api/latest.json"
  
  static func exchangeRateFor(countryCode: String, completion: @escaping CurrancyExchangeDataCompletion) {
    var urlBuilder = URLComponents()
    urlBuilder.scheme = "https"
    urlBuilder.host = host
    urlBuilder.path = path
    urlBuilder.queryItems = [
      URLQueryItem(name: "app_id", value: app_id),
    ]
    
    guard let url = urlBuilder.url else {return}
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      //execute completion handler on main thread
      DispatchQueue.main.async {
        guard error == nil else {
          print("Failed request from openexchangerates: \(error!.localizedDescription)")
          completion(nil, .failedRequest)
          return
        }
        
        guard let data = data else {
          print("No data returned from openexchangerates")
          completion(nil, .noData)
          return
        }
        
        guard let response = response as? HTTPURLResponse else {
          print("Unable to process openexchangerates response")
          completion(nil, .invalidResponse)
          return
        }
        
        guard response.statusCode == 200 else {
          print("Failure response from openexchangerates: \(response.statusCode)")
          completion(nil, .failedRequest)
          return
        }
        
        do {
          let decoder = JSONDecoder()
          let exchangeData: ExchangeData = try decoder.decode(ExchangeData.self, from: data)
          completion(exchangeData, nil)
        } catch {
          print("Unable to decode Exchange rate response: \(error.localizedDescription)")
          completion(nil, .invalidData)
        }
      }
    }.resume()
  }
}
