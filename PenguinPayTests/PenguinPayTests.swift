//
//  PenguinPayTests.swift
//  PenguinPayTests
//
//

import XCTest
@testable import PenguinPay

class PenguinPayTests: XCTestCase {

    func testChangeCountryCode() {
      let expectation = self.expectation(
        description: "Find exchange rates")
      let viewModel = PaymentViewModel()
      viewModel.countryCode.bind {
        if $0.caseInsensitiveCompare("KES") == .orderedSame {
          expectation.fulfill()
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        viewModel.changeCountryCode(to: "KES")
      }
      waitForExpectations(timeout: 8, handler: nil)
    }

}
