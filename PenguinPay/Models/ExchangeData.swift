//
//  ExchangeData.swift
//  PenguinPay
//
//

import Foundation

struct ExchangeData: Decodable {
    let rates: Rates
}

struct Rates: Decodable {
    let KES: Double
    let NGN: Double
    let TZS: Double
    let UGX: Double
}
