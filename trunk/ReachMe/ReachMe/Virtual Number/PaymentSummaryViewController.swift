//
//  PaymentSummaryViewController.swift
//  ReachMe
//
//  Created by Sachin Kumar Patra on 4/2/18.
//  Copyright © 2018 Kirusa. All rights reserved.
//

import UIKit


class PaymentSummaryViewController: UITableViewController {
    
    @IBOutlet weak var countryImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var timerView: CountdownTimer?
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var totalAmountPriceLabel: UILabel!
    @IBOutlet weak var selectedNumberLabel: UILabel!
    @IBOutlet weak var subscribeButton: DesignableButton!
    @IBOutlet weak var launchOfferLabel: UILabel!
    
    var selectedCountry: [String: Any]!
    var selectedNumber: [String: Any]!
    var lockResponseDisc: [String: Any]!
    var availableStoreProduct: [String: Any]!

    //Mark: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        getAvailabelProductFromStore()
        if let countryname = selectedCountry["country_name"] as? String {
            countryNameLabel.text = countryname
            countryImageView.image = UIImage(named: countryname.replacingOccurrences(of: " ", with: "-"))
        }
        selectedNumberLabel.text = selectedNumber["formattend_number"] as? String

        //Set Timer
        timerView?.delegate = self
        timerView?.isBackwards = true
        timerView?.isActive = true
        timerView?.totalTime = TimeInterval(Int(60 * (lockResponseDisc["lock_minutes"] as! Int)))
        timerView?.elapsedTime = 0

        //Update ProductInfo for any prodcut, so takes first one
       /* SwiftyStoreKit.retrieveProductsInfo([productIds.first!]) { (result) in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.productPriceLabel.text = priceString
                self.totalAmountPriceLabel.text = priceString
                
            } else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            } else {
                print("Error: \(String(describing: result.error))")
            }
        }*/
        
    }

    //MARK: - Button Actions    
    @IBAction func onCancelBtnClicked(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)
    }
    
    func updateAvailabilityProduct() {
        let productPrice = NumberFormatter().number(from: String(describing: availableStoreProduct["price"]!))
        productPriceLabel.text = "\(String(describing: availableStoreProduct["price_currency"]!)) \(String(format: "%.2f", (productPrice?.floatValue)!))"
        totalAmountPriceLabel.text = productPriceLabel.text
        subscribeButton.isEnabled = true
        subscribeButton.alpha = 1.0
        
        var dateComponent = DateComponents()
        dateComponent.day = availableStoreProduct["trial_days"] as? Int
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        launchOfferLabel.text = "You are getting a \(availableStoreProduct["trial_days"] as! Int) days free trail. Your card will only get charged after \(availableStoreProduct["trial_days"] as! Int) days of subscription and You can cancel anytime before \(dateFormatter.string(from: futureDate!))."


        //Start Timer
        timerView?.start()
    }
    
    func getAvailabelProductFromStore() {
        //Collect ProductID's from lock response
        ANLoader.showLoading("", disableUI: true)
        if let storeProductList = lockResponseDisc["vn_list"] as? [[String: Any]] {
            
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "f3a54fc18a0d471e9560716ff62e384e")
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    for product in storeProductList {
                        
                        let productId = Constants.BUNDLE_ID! + ".V1." + (product["product_id"] as! String)
                        // Verify the purchase of a Subscription
                        let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: productId, inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let items):
                            print("\(productId) is valid until \(expiryDate)\n\(String(describing: items.first?.productId))")
                            continue
                        case .expired(let expiryDate, let items):
                            print("\(productId) is expired since \(expiryDate)\n\(String(describing: items.first?.productId))\n")
                            self.availableStoreProduct = product
                            ANLoader.hide()
                            self.updateAvailabilityProduct()
                            return
                        case .notPurchased:
                            print("The user has never purchased \(productId)")
                            self.availableStoreProduct = product
                            ANLoader.hide()
                            self.updateAvailabilityProduct()
                            return
                        }
                    }
                    ANLoader.hide()
                    ReachMeUtility.showAlert(withMessage: "All prodcutes are purchased.")
                    
                case .error(let error):
                    ANLoader.hide()
                    ReachMeUtility.showAlert(withMessage: error.localizedDescription)
                    self.performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)
                }
            }
        }
    }
    
    @IBAction func onSubscribeBtnClicked(_ sender: UIButton) {
        guard Common.isNetworkAvailable() == NETWORK_AVAILABLE else {
            ReachMeUtility.showAlert(withMessage: "NET_NOT_AVAILABLE".localized)
            return
        }
        
        ANLoader.showLoading("", disableUI: true)
        //timerView.pause()
        let purchaseProductReqDic: NSMutableDictionary = ["product_id": self.lockResponseDisc["vn_sub_plan_id"] as Any,
                                                          "pool_id": self.lockResponseDisc["vn_pool_id"] as Any,
                                                          "virtual_num": self.lockResponseDisc["virtual_num"] as Any,
                                                          "sub_id": self.availableStoreProduct["sub_id"] as Any,
                                                          "country_code": self.selectedCountry["country_code"] as Any,
                                                          "guid": Common.getGuid(),
                                                          "purchase_source": "AppleStore"]
        let purchaseProductReqInfoJSONData = try! JSONSerialization.data(withJSONObject: purchaseProductReqDic)
        let purchaseProductReqInfo = String(data: purchaseProductReqInfoJSONData, encoding: .utf8) // Sending this as applicationUsername for product to initiate pending transactions to be complete in Appdelegate
        
        SwiftyStoreKit.purchaseProduct(Constants.BUNDLE_ID! + ".V1." + (availableStoreProduct["product_id"] as! String), atomically: false, applicationUsername: purchaseProductReqInfo!) { result in
            if case .success(let purchase) = result {
                
                SwiftyStoreKit.fetchReceipt(forceRefresh: false, completion: { receiptResult in
                    switch receiptResult {
                    case .success(let receiptdata):
                        
                        let responseDisc: NSMutableDictionary = ["purchaseToken": receiptdata.base64EncodedString(options: []),
                                                                 "ios_trans_id": purchase.transaction.transactionIdentifier!]
                        //For very first time purchase of a product, original transaction ID will be nil, so send crrent transaction ID as original transaction ID
                        if let originalTransID = purchase.originalTransaction?.transactionIdentifier {
                            responseDisc["ios_orig_trans_id"] = originalTransID
                        } else {
                            responseDisc["ios_orig_trans_id"] = purchase.transaction.transactionIdentifier!
                        }
                        
                        if let receiptJSONData = try? JSONSerialization.data(withJSONObject: responseDisc, options: .prettyPrinted) {
                            let receiptJSONType = try? JSONSerialization.jsonObject(with: receiptJSONData, options: [])
                            
                            //Update local server
                            purchaseProductReqDic["purchase_app_response"] = receiptJSONType!
                            let purchaseAPI = InAppPurchaseApi(request: purchaseProductReqDic)
                            NetworkCommon.addData(purchaseProductReqDic, eventType: VIRTUALNUMBER_SUBSCRIPTION)
                            purchaseAPI?.callNetworkRequest(purchaseProductReqDic, withSuccess: {[weak self] (requestAPI, purchaseResponseDisc) in
                                ANLoader.hide()
                                guard purchaseResponseDisc?.value(forKey: STATUS) as! String == STATUS_OK else {
                                    print("Error in purchase product response. api request: \(String(describing: requestAPI?.request))")
                                    return
                                }
                                
                                ReachMeUtility.showAlert(withMessage: "\(purchaseResponseDisc!["virtual_num"] as! String) purchased")

                                SwiftyStoreKit.finishTransaction(purchase.transaction)//Finish Transaction
                                self?.performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)

                                }, failure: { (requestAPI, error) in
                                    ANLoader.hide()
                                    if let nsError = error as NSError? {
                                        if nsError.code == 97 {//Duplicate Purchase
                                            SwiftyStoreKit.finishTransaction(purchase.transaction) //Finish Transaction
                                        } else if nsError.code == 9008 { //Validation Failed
                                            ReachMeUtility.showAlert(withMessage: nsError.userInfo["error_reason"] as! String, title: "Purchase failed")
                                        }                                        
                                    }
                                    print("Error in verify purchased product: \(error.debugDescription)")
                                    self.performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)
                            })
                        }
                        
                    case .error(let error):
                        ANLoader.hide()
                        print("Error in fetch Receipt: \(error.localizedDescription)")
                    }
                })
            }
            
            self.alertForPurchaseResult(result)
        }
    }
    
    func alertForPurchaseResult(_ result: PurchaseResult) {

        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return
            
        case .error(let error):
            ANLoader.hide()
            let errorMessage: String!
            print("Purchase Failed: \(error)")
            
            switch error.code {
            case .unknown:
                errorMessage = error.localizedDescription
            case .clientInvalid: // client is not allowed to issue the request, etc.
                errorMessage = "Not allowed to make the payment"
            case .paymentCancelled: // user cancelled the request, etc.
                print("User Canceld Trancsction")
                return
            case .paymentInvalid: // purchase identifier was invalid, etc.
                errorMessage = "The purchase identifier was invalid"
            case .paymentNotAllowed: // this device is not allowed to make the payment
                errorMessage = "The device is not allowed to make the payment"
            case .storeProductNotAvailable: // Product is not available in the current storefront
                errorMessage = "The product is not available in the current storefront"
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                errorMessage = "Access to cloud service information is not allowed"
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                errorMessage = "Could not connect to the network"
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                errorMessage = "Cloud service was revoked"
            }
            
            ReachMeUtility.showAlert(withMessage: errorMessage, title: "Purchase failed")
            self.performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)
        }
    }
}

// MARK: - TimerDelegate
extension PaymentSummaryViewController: CountdownTimerDelegate {
    func circleCounterTimeDidExpire(circleTimer: CountdownTimer) {
        ANLoader.hide()
        circleTimer.timerLabel?.text = "End"

        let alert = UIAlertController(style: .alert, title: "Purchase timed out", message: "Looks like you couldn't subscribe to the number. Please reselect the number and try again!")
        alert.addAction(title: "OK", style: .default) { (alertAction) in
            self.performSegue(withIdentifier: "showStoreVCUnwindSegueID", sender: nil)
        }
        alert.show()
    }
}
