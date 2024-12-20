//
//  ViewController.swift
//  Example
//
//  Created by mac on 12/01/24.
//

import UIKit
import peaq_iOS

class ViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var btnCreateID: UIButton!
    @IBOutlet weak var btnCopy: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblHash: UILabel!
    @IBOutlet weak var stackCopyShare: UIStackView!
    
    @IBOutlet weak var btnCreateLiftOffID: UIButton!
    @IBOutlet weak var lblCreateLiftOffIDHashKey: UILabel!
    @IBOutlet weak var lblCreateLiftOffIDSignature: UILabel!
    
    @IBOutlet weak var btnSubmitTask: UIButton!
    @IBOutlet weak var lblSubmitTask: UILabel!
    
    @IBOutlet weak var btnCreateEmailSignature: UIButton!
    @IBOutlet weak var lblCreateEmailSignature: UILabel!
    
    
    @IBOutlet weak var btnSignData: UIButton!
    @IBOutlet weak var lblSignature: UILabel!
    
    @IBOutlet weak var btnStoreData: UIButton!
    @IBOutlet weak var lblStoreData: UILabel!
    
    @IBOutlet weak var btnGetData: UIButton!
    @IBOutlet weak var lblGetData: UILabel!
    
    @IBOutlet weak var btnVerifyData: UIButton!
    @IBOutlet weak var lblVerifyData: UILabel!
    
    //MARK: - Properties
    let liveOrTest = false
    let peaq_url = "wss://peaq.api.onfinality.io/public-ws"
    let peaq_testnet_url = "wss://wsspc1-qa.agung.peaq.network"
    // dev URL: https://lift-off-campaign-service-jx-devbr.jx.peaq.network
    let peaq_service_url = "https://lift-off-campaign-service-jx-devbr.jx.peaq.network"
    
    // dev APIKEY: aa69cb8e92b2e27eb26996fc9b02f6df24
    let api_key = "aa69cb8e92b2e27eb26996fc9b02f6df24"
    
    // dev P-APIKEY: all_0821fcaa69
    let project_api_key = "all_0821fcaa69"
    
    // custom tag for testing is "TEST" - unique task identifier per project
    let tag = "TEST"
    
    // custom task tag + identifier to track the specific task
    // it determines the item type on chain
    // Format: [<YOUR_CUSTOM_TASK_TAG>] + [-] + [a-zA-Z0-9-_]
    let itemType = "TEST-"
    
    var lastStoredItemType = "TEST-1234"
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnSignData.layer.cornerRadius = 10
        btnStoreData.layer.cornerRadius = 10
        btnGetData.layer.cornerRadius = 10
        btnVerifyData.layer.cornerRadius = 10
        btnCreateID.layer.cornerRadius = 10
        btnCopy.layer.cornerRadius = 10
        btnShare.layer.cornerRadius = 10
        btnCreateLiftOffID.layer.cornerRadius = 10
        btnSubmitTask.layer.cornerRadius = 10
        
        hiddenShowViews(ishidden: true)
        
        lblSignature.isHidden = true
        lblStoreData.isHidden = true
        lblGetData.isHidden = true
        lblVerifyData.isHidden = true
        lblCreateLiftOffIDHashKey.isHidden = true
        lblCreateLiftOffIDSignature.isHidden = true
        lblSubmitTask.isHidden = true
    }
    
    //MARK: - Functions
    func hiddenShowViews(ishidden: Bool) {
        lblHash.isHidden = ishidden
        btnCopy.isHidden = ishidden
        btnShare.isHidden = ishidden
        stackCopyShare.isHidden = ishidden
    }
    
    func hiddenLiftOffViews(ishidden: Bool) {
        lblCreateLiftOffIDSignature.isHidden = ishidden
        lblCreateLiftOffIDHashKey.isHidden = ishidden
    }
    
    //MARK: - Actions
    @IBAction func createMachineID(_ sender: UIButton) {
        createMachineID()
    }
    
    @IBAction func createLiftOffID(_ sender: UIButton) {
        Task { @MainActor in
            try await createMachineIDLiftOff()
        }
    }

    @IBAction func submitTaskData(_ sender: UIButton) {
        Task { @MainActor in
            try await storeLiftOff(data: "Hello World")
        }
    }
    
    @IBAction func createEMailSignature(_ sender: UIButton) {
        let eMail = "robin@brainstem.health"
        
        Task { @MainActor in
            let postdata = [
                "email": eMail,
                "did_address": lblHash.text,
                "tag": tag
            ]
            let signature = try await createEMailSign(data: postdata as [String : Any])
            
            lblCreateEmailSignature.text = signature
        }
    }
    
    @IBAction func signData(_ sender: UIButton) {
        lblSignature.isHidden = true
        lblSignature.text = ""
        let machineSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        let signature = signData(machineSeed: machineSeed, data: "Hello World")
        if signature != nil && !signature!.isEmpty {
            lblSignature.isHidden = false
            lblSignature.text = signature
        }
    }
    
    @IBAction func storeBtn(_ sender: UIButton) {
        lblStoreData.isHidden = true
        lblStoreData.text = ""
        store(data: "Hello World")
    }
    
    @IBAction func getDataBtn(_ sender: UIButton) {
        lblGetData.isHidden = true
        lblGetData.text = ""
        fetchStorageData(itemType: itemType)
    }
    
    @IBAction func verifyData(_ sender: UIButton) {
        lblVerifyData.isHidden = true
        lblVerifyData.text = ""
        verifyData()
    }
    
    //MARK: - Functions
    func createMachineID() {
        self.hiddenShowViews(ishidden: true)
        IndicatorManager.showLoader()
        let mainSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        do {
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: mainSeed) { [self] isSuccess, err in
                if isSuccess {
                    
                    let (seed, error) = peaq.shared.generateMnemonicSeed()
                    let (seed2, error2) = peaq.shared.generateMnemonicSeed()
                    
                    if let seed = seed, let seed2 = seed2 {
                        print("SEED", seed)
                        
                        let (publicKey, _, address, addressGetError) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed)
                        let (publicKey2, _, address2, _) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed2)
                        if addressGetError != nil {
                            
                            IndicatorManager.hideLoader()
                            alert(addressGetError?.localizedDescription ?? "Something went wrong.")
                            
                        } else if let publicKey = publicKey, let address2 = address2, let address = address, let publicKey2 = publicKey2 {
                            
                            print("publicKey", publicKey)
                            print("address", address)
                            
                            if let dIdDoc = peaq.shared.createDidDocument(ownerAddress: address, machineAddress: address2, machinePublicKey: publicKey2, customData: [DIDDocumentCustomData(id: "12", type: "custom_data", data: "{\"id\":1, \"name\":\"sensor 1\"}")]) {
                                do {
                                    try peaq.shared.createDid(name: "did:peaq:\(address)", value: dIdDoc) { hashKey, err in
                                        
                                        IndicatorManager.hideLoader()
                                        guard err == nil else {
                                            self.alert(err!.localizedDescription)
                                            return
                                        }
                                        self.lblHash.text = hashKey
                                        self.hiddenShowViews(ishidden: false)
                                    }
                                } catch {
                                    IndicatorManager.hideLoader()
                                    alert(error.localizedDescription)
                                }
                            } else {
                                IndicatorManager.hideLoader()
                                alert("Something went wrong.")
                            }
                        } else {
                            IndicatorManager.hideLoader()
                            alert("Something went wrong.")
                        }
                    } else {
                        IndicatorManager.hideLoader()
                        alert((error?.localizedDescription ?? "Something went wrong.") + (error2?.localizedDescription ?? ""))
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }
    
    func createEMailSign(data: [String: Any]) async throws -> String {
        IndicatorManager.showLoader()
        var signature = ""
        
        do {
            signature = try await peaq.shared.createEmailSignature(data: data, api_key: api_key, project_api_key: project_api_key, peaq_service_url: peaq_service_url)
        }
        catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
        
        IndicatorManager.hideLoader()
        return signature
    }
    
    func createMachineIDLiftOff() async throws {
        self.hiddenLiftOffViews(ishidden: true)
        IndicatorManager.showLoader()
        let mainSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        
        let eMail = "robin@brainstem.health"
        
        do {
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: mainSeed) { [self] isSuccess, err in
                if isSuccess {
                    
                    let (seed, error) = peaq.shared.generateMnemonicSeed()
                    let (seed2, error2) = peaq.shared.generateMnemonicSeed()
                    
                    if let seed = seed, let seed2 = seed2 {
                        print("SEED", seed)
                        
                        let (publicKey, _, address, addressGetError) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed)
                        let (publicKey2, _, address2, _) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed2)
                        if addressGetError != nil {
                            
                            IndicatorManager.hideLoader()
                            alert(addressGetError?.localizedDescription ?? "Something went wrong.")
                            
                        } else if let publicKey = publicKey, let address2 = address2, let address = address, let publicKey2 = publicKey2 {
                            
                            print("publicKey", publicKey)
                            print("address", address)
                            
                            var signature = ""
                            
                            Task {
                                let postdata = [
                                    "email": eMail,
                                    "did_address": address2,
                                    "tag": tag
                                ]
                                
                                signature = try await peaq.shared.createEmailSignature(data: postdata, api_key: api_key, project_api_key: project_api_key, peaq_service_url: peaq_service_url)
                                
                                self.lblCreateLiftOffIDSignature.text = signature
                            }
                            
                            if let dIdDoc = peaq.shared.createDidDocument(ownerAddress: address, machineAddress: address2, machinePublicKey: publicKey2, customData: [DIDDocumentCustomData(id: "12", type: "custom_data", data: "{\"id\":1, \"name\":\"sensor 1\"}"), DIDDocumentCustomData(id:"#emailSignature", type: "emailSignature", data: signature)]) {
                                do {
                                    try peaq.shared.createDid(name: "did:peaq:\(address)", value: dIdDoc) { hashKey, err in
                                        
                                        IndicatorManager.hideLoader()
                                        guard err == nil else {
                                            self.alert(err!.localizedDescription)
                                            return
                                        }
                                        self.lblCreateLiftOffIDHashKey.text = hashKey
                                        self.hiddenLiftOffViews(ishidden: false)
                                    }
                                } catch {
                                    IndicatorManager.hideLoader()
                                    alert(error.localizedDescription)
                                }
                            } else {
                                IndicatorManager.hideLoader()
                                alert("Something went wrong.")
                            }
                        } else {
                            IndicatorManager.hideLoader()
                            alert("Something went wrong.")
                        }
                    } else {
                        IndicatorManager.hideLoader()
                        alert((error?.localizedDescription ?? "Something went wrong.") + (error2?.localizedDescription ?? ""))
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }

    
    func register() {
        self.hiddenShowViews(ishidden: true)
        IndicatorManager.showLoader()
        let mainSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        do {
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: mainSeed) { [self] isSuccess, err in
                if isSuccess {
                    
                    let (seed, error) = peaq.shared.generateMnemonicSeed()
                    let (seed2, error2) = peaq.shared.generateMnemonicSeed()
                    
                    if let seed = seed, let seed2 = seed2 {
                        print("SEED", seed)
                        
                        let (publicKey, _, address, addressGetError) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed)
                        let (publicKey2, _, address2, _) = peaq.shared.getPublicPrivateKeyAddressFromMachineSeed(machineSeed: seed2)
                        if addressGetError != nil {
                            
                            IndicatorManager.hideLoader()
                            alert(addressGetError?.localizedDescription ?? "Something went wrong.")
                            
                        } else if let publicKey = publicKey, let address2 = address2, let address = address, let publicKey2 = publicKey2 {
                            
                            print("publicKey", publicKey)
                            print("address", address)
                            
                            if let dIdDoc = peaq.shared.createDidDocument(ownerAddress: address, machineAddress: address2, machinePublicKey: publicKey2, customData: [DIDDocumentCustomData(id: "12", type: "custom_data", data: "{\"id\":1, \"name\":\"sensor 1\"}")]) {
                                do {
                                    try peaq.shared.createDid(name: "did:peaq:\(address)", value: dIdDoc) { hashKey, err in
                                        
                                        IndicatorManager.hideLoader()
                                        guard err == nil else {
                                            self.alert(err!.localizedDescription)
                                            return
                                        }
                                        self.lblHash.text = hashKey
                                        self.hiddenShowViews(ishidden: false)
                                    }
                                } catch {
                                    IndicatorManager.hideLoader()
                                    alert(error.localizedDescription)
                                }
                            } else {
                                IndicatorManager.hideLoader()
                                alert("Something went wrong.")
                            }
                        } else {
                            IndicatorManager.hideLoader()
                            alert("Something went wrong.")
                        }
                    } else {
                        IndicatorManager.hideLoader()
                        alert((error?.localizedDescription ?? "Something went wrong.") + (error2?.localizedDescription ?? ""))
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }
    
    func signData(machineSeed: String, data: String) -> String? {
        let signature = peaq.shared.signData(plainData: data, machineSecretPhrase: machineSeed, format: .sr25519)
        print("signature", signature ?? "")
        return signature
    }
    
    func store(data: String) {
        IndicatorManager.showLoader()
        let machineSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        do {
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: machineSeed) { [self] isSuccess, err in
                if isSuccess {
                    if let signature = signData(machineSeed: machineSeed, data: data) {
                        do {
                            lastStoredItemType = itemType + randomString(length: 6)
                            try peaq.shared.storeMachineDataHash(ownerSeed: machineSeed, value: signature, key: lastStoredItemType) { [self] str, err in
                                IndicatorManager.hideLoader()
                                guard err == nil else {
                                    self.alert(err!.localizedDescription)
                                    return
                                }
                                lblStoreData.isHidden = false
                                lblStoreData.text = str
                            }
                        } catch {
                            IndicatorManager.hideLoader()
                            alert(error.localizedDescription)
                        }
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }
    
    func storeLiftOff(data: String) {
        IndicatorManager.showLoader()
        let machineSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        let eMail = "robin@brainstem.health"
        
        do {
            lastStoredItemType = itemType + randomString(length: 6)
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: machineSeed) { [self] isSuccess, err in
                if isSuccess {
                    var response = ""
                    
                    Task {
                        let postdata = [
                            "item_type": lastStoredItemType,
                            "email": eMail,
                            "tag": tag
                        ]
                        
                        response = try await peaq.shared.registerTaskCompletion(data: postdata, api_key: api_key, project_api_key: project_api_key, peaq_service_url: peaq_service_url)
                        
                        self.lblSubmitTask.text = response
                    }
                    
                    if let signature = signData(machineSeed: machineSeed, data: data) {
                        do {                            
                            try peaq.shared.storeMachineDataHash(ownerSeed: machineSeed, value: signature, key: lastStoredItemType) { [self] str, err in
                                IndicatorManager.hideLoader()
                                guard err == nil else {
                                    self.alert(err!.localizedDescription)
                                    return
                                }
                                lblStoreData.isHidden = false
                                lblStoreData.text = str
                            }
                        } catch {
                            IndicatorManager.hideLoader()
                            alert(error.localizedDescription)
                        }
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }

    
    func fetchStorageData(itemType: String) {
        IndicatorManager.showLoader()
        let machineSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        do {
            try peaq.shared.createInstance(baseUrl: liveOrTest ? peaq_url : peaq_testnet_url, secretPhrase: machineSeed) { [self] isSuccess, err in
                if isSuccess {
                    if let address = peaq.shared.getAddressFromMachineSeed(machineSeed: machineSeed) {
                        do {
                            let data = try peaq.shared.fetchStorageData(address: address, key: lastStoredItemType)
                            IndicatorManager.hideLoader()
                            lblGetData.isHidden = false
                            lblGetData.text = data?.stringValue
                        } catch {
                            IndicatorManager.hideLoader()
                            alert(error.localizedDescription)
                        }
                    } else {
                        IndicatorManager.hideLoader()
                        alert("Getting error in address")
                    }
                } else {
                    IndicatorManager.hideLoader()
                    alert(err?.localizedDescription ?? "Something went wrong.")
                }
            }
        } catch {
            IndicatorManager.hideLoader()
            alert(error.localizedDescription)
        }
    }
    
    func verifyData() {
        let machineSeed = "speed movie excess amateur tent envelope few raise egg large either antique"
        let data = "Hello World"
        let publicKey = peaq.shared.getPublicKey(machineSeed: machineSeed, format: .sr25519)
        if let signature = signData(machineSeed: machineSeed, data: data) {
            let isVerify = peaq.shared.verifyData(machinePublicKey: publicKey ?? "", plainDataHex: data, signature: signature)
            print("isVerify", isVerify)
            
            lblVerifyData.isHidden = false
            lblVerifyData.text = isVerify ? "Verified successfully!!" : "Verification failed!!"
        }
    }
    
    @IBAction func btnCopy(_ sender: UIButton) {
        UIPasteboard.general.string = self.lblHash.text
        alert("Copied")
    }
    
    @IBAction func shareBtn(_ sender: UIButton) {
        let textToShare = [ self.lblHash.text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func alert(_ message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
}
