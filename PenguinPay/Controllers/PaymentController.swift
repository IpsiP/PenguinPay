//
//  PaymentController.swift
//  PenguinPay
//
//

import UIKit
import FlagPhoneNumber


class PaymentController: UIViewController {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipientView: DropDownView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var firstNameTextField: PenguinTextField!
    @IBOutlet weak var lastNameTextField: PenguinTextField!
    @IBOutlet weak var phoneNumberTextField: FPNTextField!
    @IBOutlet weak var recieveTextField: PenguinTextField!
    @IBOutlet weak var sendingAmoutTextField: PenguinTextField!
    @IBOutlet weak var receivingAmountTextField: PenguinTextField!
    @IBOutlet weak var sendButton: UIButton!
    
    private let viewModel = PaymentViewModel()
    private var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        
        viewModel.currancyText.bind { [weak self] currancyValue in
            self?.currencyLabel.text = currancyValue
        }
        
        viewModel.senderAmountText.bind { [weak self] senderAmount in
            self?.sendingAmoutTextField.text = ""
            self?.sendingAmoutTextField.placeholder = senderAmount
        }
        
        viewModel.recipientAmountText.bind { [weak self] recipientAmount in
            self?.receivingAmountTextField.text = recipientAmount
            self?.receivingAmountTextField.placeholder = recipientAmount
        }
        
        viewModel.recipientFirstName.bind { [weak self] firstName in
            self?.firstNameTextField.text = firstName
        }
        
        viewModel.recipientLastName.bind { [weak self] lastName in
            self?.lastNameTextField.text = lastName
        }
        
        viewModel.countriesList.bind { [weak self] countries in
            self?.recipientView.options = countries
            self?.recipientView.selectedValue = countries[0].alpha3Code
        }
        
        viewModel.countryCode.bind { [weak self] countryCode in
            self?.recipientView.selectedValue = countryCode
        }

        viewModel.isAllowedToSend.bind { [weak self] flag in
            self?.sendButton.isEnabled = flag
            self?.sendButton.alpha = flag ? 1 : 0.5
        }
        
        viewModel.recipientsPhoneNumber.bind { [weak self] number in
            self?.phoneNumberTextField.text = number
        }
        
        viewModel.allowedContriesFlagList.bind { [weak self] flagsList in
            self?.phoneNumberTextField.setCountries(including: flagsList)
        }
        
        viewModel.selectedCountry.bind { [weak self] country in
            self?.phoneNumberTextField.text = ""
            self?.phoneNumberTextField.setFlag(countryCode: country.flag)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: Constants.thanks, message: Constants.thanksMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: Constants.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: { [weak self] in
            if let weakSelf = self {
                weakSelf.viewModel.resetValues()
                weakSelf.resetTextFieldes()
            }
        })
    }
    
    fileprivate func setUpView() {
        navigationController?.navigationBar.barTintColor = UIColor.primaryBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        
        cardView.backgroundColor = UIColor.veryLightPink
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.shadowOpacity = 0.7
        
        recipientView.updateAvailable = true
        recipientView.delegate = self
        
        recieveTextField.isUserInteractionEnabled = false
        sendButton.backgroundColor = UIColor.primaryBlue
        
        phoneNumberTextField.addDoneButtonOnKeyboard()
        phoneNumberTextField.keyboardAppearance = .dark
        phoneNumberTextField.applyPenguinTextFieldStyle()
    }

    fileprivate func resetTextFieldes() {
        for view in scrollView.subviews[0].subviews[0].subviews {
            if let textField = view as? UITextField {
                textField.text = ""
            }
        }
        
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil);
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @objc func dismissCountries() {
        listController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - DropDownViewDelegate

extension PaymentController: DropDownViewDelegate {
    func updateSelectedCountry(to newCountry: Country) {
        viewModel.changeCountryCode(to: newCountry.alpha3Code)

    }
    
    func pickerWillShow() {
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = CGFloat(Constants.keyboardHeight)
        scrollView.contentInset = contentInset
    }
    
    func pickerWillHide() {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

// MARK: - UITextFieldDelegate
extension PaymentController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch(textField.tag) {
        case 0,1:
            return true
        case 3:
            let aSet = NSCharacterSet(charactersIn:"01 ").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if(string == numberFiltered) {
                if let text = textField.text,
                   let textRange = Range(range, in: text) {
                    let updatedText = text.replacingCharacters(in: textRange,
                                                               with: string)
                    self.viewModel.senderAmountUpdatedTo(amount: updatedText)
                }
                return true
            }else {
                return false
            }
        case 4:
            return false
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch(textField.tag) {
        case 0:
            self.viewModel.updateRecipientFirstName(firstName: textField.text ?? "")
        case 1:
            self.viewModel.updateRecipientLastName(lastName: textField.text ?? "")
        case 2:
            self.viewModel.updateRecipientPhoneNumber(number: textField.text ?? "")
        default:
            break
        }
    }
}

// MARK: - FPNTextFieldDelegate
extension PaymentController: FPNTextFieldDelegate {
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        textField.rightView = UIImageView(image: isValid ? #imageLiteral(resourceName: "success") : #imageLiteral(resourceName: "error"))
        self.viewModel.isValidPhoneNumber(flag: isValid)
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
        self.viewModel.changeCountryCode(to: code)
    }
    
    func fpnDisplayCountryList() {
        let navigationViewController = UINavigationController(rootViewController: listController)
        listController.title = Constants.conuntries
        listController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(dismissCountries))
        self.present(navigationViewController, animated: true, completion: nil)
    }
}

