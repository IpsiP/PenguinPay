//
//  CountriesRepository.swift
//  PenguinPay
//
//

import Foundation
import FlagPhoneNumber

class CountriesRepository {
    static func getCountriesList() -> [Country] {
        return [Country(name: "Kenya", alpha2Code: "KE", alpha3Code: "KES", flag: .KE),
                Country(name: "Nigeria", alpha2Code: "NG", alpha3Code: "NGN", flag: .NG),
                Country(name: "Tanzania", alpha2Code: "TZ", alpha3Code: "TZS", flag: .TZ),
                Country(name: "Uganda", alpha2Code: "UG", alpha3Code: "UGX", flag: .UG),
        ]
    }
}
