//
//  PaymentViewModel.swift
//  PenguinPay
//
//

import Foundation
import FlagPhoneNumber

public class PaymentViewModel {
    let recipientFirstName = Box("")
    let recipientLastName = Box("")
    let countryCode = Box("")
    let recipientsPhoneNumber = Box("")
    var senderAmount = ""
    var currentExchangeRate = 0.0
    let currancyText = Box(Constants.loading)
    let recipientAmountText = Box("0.00")
    let senderAmountText = Box("0.00")
    var isRecipientPhoneNumberValid = false
    var isAllowedToSend = Box(false)
    var countriesList = Box(Array<Country>())
    private static let defaultTargetCountryCode = Constants.kes
    let allowedContriesFlagList = Box(Array<FPNCountryCode>())
    var selectedCountry = Box(Country(name: "", alpha2Code: "", alpha3Code: "", flag: .KE))
    
    init() {
        changeCountryCode(to: Self.defaultTargetCountryCode)
        countriesList.value = CountriesRepository.getCountriesList()
        allowedContriesFlagList.value = countriesList.value.map { $0.flag }
        updateIsAllowedTosend()
    }

    func changeCountryCode(to newCountryCode: String) {
        if(!countryCode.value.contains(newCountryCode) ) {
            if let selectedCountry = countriesList.value.first(where: { (country) -> Bool in
                country.alpha3Code.contains(newCountryCode)
            }) {
                countryCode.value = selectedCountry.alpha3Code
                self.selectedCountry.value = selectedCountry
            }
            
            fetchExchangeRateFor(newCountryCode)
            updateIsAllowedTosend()
        }
    }
    
    func senderAmountUpdatedTo(amount: String) {
        if let number = Int(amount, radix: 2) {
            recipientAmountText.value = String(Int((currentExchangeRate * Double(number)).rounded()), radix: 2)
            senderAmount = amount
            updateIsAllowedTosend()
        }
    }
    
    func updateRecipientFirstName(firstName: String) {
        recipientFirstName.value = firstName
        updateIsAllowedTosend()
    }
    
    func updateRecipientLastName(lastName: String) {
        recipientLastName.value = lastName
        updateIsAllowedTosend()
    }
    
    func updateRecipientPhoneNumber(number: String) {
        recipientsPhoneNumber.value = number
    }
    
    func isValidPhoneNumber(flag: Bool) {
        isRecipientPhoneNumberValid = flag
        updateIsAllowedTosend()
    }
    
    func updateIsAllowedTosend() {
        let isSenderAmounEntered = (Double(senderAmount) ?? 0.0) > 0
        
        if(!recipientFirstName.value.isEmpty && !recipientLastName.value.isEmpty && isRecipientPhoneNumberValid && isSenderAmounEntered) {
            isAllowedToSend.value = true
        }else {
            isAllowedToSend.value = false
        }
    }
    
    func resetValues() {
        recipientFirstName.value = ""
        recipientLastName.value = ""
        senderAmount = ""
        senderAmountText.value = "0.00"
        recipientAmountText.value = "0.00"
        recipientsPhoneNumber.value = ""
        isRecipientPhoneNumberValid = false
        isAllowedToSend.value = false
        selectedCountry.value = countriesList.value.first(where: { (country) -> Bool in
            country.alpha3Code.contains(countryCode.value)
        }) ?? countriesList.value[0]
        changeCountryCode(to: countryCode.value)
    }
    
    
    //This method fetches exchage rate for all countries
    fileprivate func fetchExchangeRateFor(_ countryCode: String) {
        self.countryCode.value = countryCode
        CurrancyExchangeService.exchangeRateFor(countryCode: countryCode) { [weak self] (exchangeData, error) in
            guard
                let weakSelf = self,
                let exchangeData = exchangeData
            else {
                return
            }
            
            let exchangeRate = weakSelf.getCurrencyRateForCountryCode(countryCode: countryCode, exchangeData: exchangeData)
            weakSelf.currentExchangeRate = exchangeRate
            
            if let selectedCountry = weakSelf.countriesList.value.first(where: { (country) -> Bool in
                country.alpha3Code.contains(countryCode)
            }) {
                weakSelf.currancyText.value = "1 BIN = " + String(exchangeRate) + " " + selectedCountry.alpha3Code
            }
            
            weakSelf.senderAmountText.value = "0.00"
            weakSelf.recipientAmountText.value = "0.00"
        }
    }
        
    fileprivate func getCurrencyRateForCountryCode(countryCode: String,exchangeData: ExchangeData ) -> Double {
        switch(countryCode)
        {
        case Constants.kes, Constants.ke:
            return exchangeData.rates.KES
        case Constants.ngn, Constants.ng:
            return exchangeData.rates.NGN
        case Constants.tzs, Constants.tz:
            return exchangeData.rates.TZS
        case Constants.ugx, Constants.ug:
            return exchangeData.rates.UGX
        default:
            return 0
        }
    }
    
}
