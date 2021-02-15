//
//  ExchangeDataTest.swift
//  PenguinPayTests
//
//

import XCTest
@testable import PenguinPay

class ExchangeDataTest: XCTestCase {
    
    var exampleJSONData: Data!
    var exchange: ExchangeData!

    override func setUp() {
      let bundle = Bundle(for: type(of: self))
      let url = bundle.url(forResource: "exchangeRates", withExtension: "json")!
      exampleJSONData = try! Data(contentsOf: url)
    
      let decoder = JSONDecoder()
        exchange = try! decoder.decode(ExchangeData.self, from: exampleJSONData)
    }
      
    func testDecodeKES() throws {
        XCTAssertEqual(exchange.rates.KES, 109.4)
    }
    
    func testDecodeNGN() throws {
        XCTAssertEqual(exchange.rates.NGN, 381.15)
    }
    
    func testDecodeTZS() throws {
        XCTAssertEqual(exchange.rates.TZS, 2319.355)
    }
    
    func testDecodeUGX() throws {
        XCTAssertEqual(exchange.rates.UGX, 3666.564314)
    }

}
