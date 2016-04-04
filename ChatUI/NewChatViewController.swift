//
//  NewChatViewController.swift
//  ChatUI
//
//  Created by Basawaraj on 17/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

let Segue_Chat_UI = "goto_chat_ui"

class NewChatViewController: UIViewController, UITextFieldDelegate {

    //MARK: IBOutlets
    @IBOutlet var txtfldSubject: UITextField!
    @IBOutlet var btnNext: UIBarButtonItem!
    @IBOutlet var lblTextLengthCount: UILabel!
    
    let stringLenght = 25
    
    //MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
         self.navigationController?.navigationBar.topItem?.title = "New Chat"
         lblTextLengthCount.text = "\(stringLenght)"
         btnNext.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        txtfldSubject.text = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextfield Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        txtfldSubject.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textLenght = (textField.text?.characters.count)! + (string.characters.count - range.length)
        
        if textLenght == 0 {
            btnNext.enabled = false
        }
        else {
            btnNext.enabled = true
        }
        
        updateCountLabel(textLenght)
        
        let isValidLenght = textLenght <= stringLenght
        
        return isValidLenght
    }
    
    
    func updateCountLabel(inputTextcount: Int) {
        
        if inputTextcount <= stringLenght {
            lblTextLengthCount.text = "\(stringLenght - inputTextcount)"
        }
        
    }

    
    //MARK: IBActions
    @IBAction func onClickOfNext(sender: AnyObject) {
        
        let ticketRequest: TicketRequest = TicketRequest()
        ticketRequest.ticketSubject = txtfldSubject.text!
        ticketRequest.ticketDescription = "Description will contain machine details and other important information once integrated in main app."
        
        SVProgressHUD.show()
        
        RMTickets.sharedInstance.createTicketRequest(ticketRequest) { (response, error) -> Void in
            
            SVProgressHUD.dismiss()
            
            if error == nil {
                
                let response: ZDKDispatcherResponse = response as! ZDKDispatcherResponse
                
                do {
                    let anyObj = try NSJSONSerialization.JSONObjectWithData(response.data, options: []) as! NSDictionary
                    let requestData = anyObj["request"] as! NSDictionary
                    let ticketId = requestData["id"]
                    self.txtfldSubject.resignFirstResponder()
                    self.performSegueWithIdentifier(Segue_Chat_UI, sender: ticketId)
                    
                    // use anyObj here
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
 
            }

        }
        
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Segue_Chat_UI {
            
            let destinationVC = segue.destinationViewController as! ViewController
            destinationVC.subject = txtfldSubject.text!
            destinationVC.ticketId = sender as! String
            
        }
        
    }
    

}
