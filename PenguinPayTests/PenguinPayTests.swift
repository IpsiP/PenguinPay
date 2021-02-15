//
//  PenguinPayTests.swift
//  PenguinPayTests
//
//

import XCTest
@testable import PenguinPay

class PenguinPayTests: XCTestCase {

    func testChangeCountryCode() {
      // 1
      let expectation = self.expectation(
        description: "Find location using geocoder")
      // 2
      let viewModel = PaymentViewModel()
      // 3
      viewModel.countryCode.bind {
        if $0.caseInsensitiveCompare("KES") == .orderedSame {
          expectation.fulfill()
        }
      }
      // 4
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        viewModel.changeCountryCode(to: "KES")
      }
      // 5
      waitForExpectations(timeout: 8, handler: nil)
    }

}
