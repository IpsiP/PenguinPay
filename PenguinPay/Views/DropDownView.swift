//
//  DropDownView.swift
//  PenguinPay
//
//

import UIKit

protocol DropDownViewDelegate: class {
    func updateSelectedCountry(to newCountry: Country)
    func pickerWillShow()
    func pickerWillHide()
}

class DropDownView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dropDownImage: UIImageView!
    
    
    fileprivate var picker  = UIPickerView()
    fileprivate var toolBar = UIToolbar()
    var options = Array<Country>()
    
    var delegate: DropDownViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    var selectedValue: String? {
        didSet {
            guard let value = selectedValue else { return }
            if let selectedCountry = options.first(where: { (country) -> Bool in
                country.alpha3Code.contains(value)
            }) {
                title.text = countryFlag(countryCode: String(value.prefix(2))) + " " + selectedCountry.alpha3Code
            }
        }
    }

    
    var updateAvailable: Bool? {
        didSet {
            if(updateAvailable == true) {
                dropDownImage.isHidden = false
            }else {
                dropDownImage.isHidden = true
            }
        }
    }

    
    fileprivate func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(view)
        createPickerView()
        view.backgroundColor = UIColor.primaryBlue
        dropDownImage.image = dropDownImage.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        dropDownImage.tintColor = UIColor.veryLightPink
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    fileprivate func createPickerView() {
        picker = UIPickerView()
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.veryLightPink
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.selectRow(0, inComponent: 0, animated: true)
        title.text = options.count > 0 ? options[0].alpha3Code : ""
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .blackTranslucent
        toolBar.items = [UIBarButtonItem.init(title: Constants.done, style: .done, target: self, action: #selector(onDoneButtonTapped))]
    }
    
    fileprivate func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    fileprivate func countryFlag(countryCode: String) -> String {
        return String(String.UnicodeScalarView(
                        countryCode.unicodeScalars.compactMap(
                            { UnicodeScalar(127397 + $0.value) })))
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if(updateAvailable ?? false) {
            delegate?.pickerWillShow()
            self.findViewController()?.view.addSubview(picker)
            self.findViewController()?.view.addSubview(toolBar)
        }
    }
    
    @objc func onDoneButtonTapped() {
        delegate?.pickerWillHide()
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
    }
    
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension DropDownView: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCountry = options[row]
        let selectedCountryCode = options[row].alpha3Code
        let countryFlagString = countryFlag(countryCode: options[row].alpha2Code)
        title.text =  countryFlagString + "  " + selectedCountryCode
        delegate?.updateSelectedCountry(to: selectedCountry)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let selectedCountry = options[row].alpha3Code
        let countryFlagString = countryFlag(countryCode: options[row].alpha2Code)
        var label: UILabel
        if let view = view as? UILabel {
            label = view
        }else {
            label = UILabel()
        }
        
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.lightGray
        label.textAlignment = .center
        label.text = countryFlagString + "  " +  selectedCountry
        return label
    }
}
