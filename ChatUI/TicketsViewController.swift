//
//  TicketsViewController.swift
//  ChatUI
//
//  Created by Basawaraj on 23/03/16.
//  Copyright © 2016 Basawaraj. All rights reserved.
//

import UIKit

let Segue_Chat_Details = "goto_chat_vc"
let Segue_Pre_Chat = "goto_pre_chat"

class TicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblTickets: UITableView!
    var allTickets: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Chat"
        getTickets("new,open")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: GetTickets By Status
    func getTickets(status: String) {
        
        SVProgressHUD.show()
        
        RMTickets.sharedInstance.getHelpCenterTicketsByStatus(status) { (tickets, error) -> Void in
            
            SVProgressHUD.dismiss()
            
            if tickets != nil {
                
                self.allTickets = tickets!
                
                self.tblTickets.reloadData()

            }
            
            
        }
        
        
    }
    //MARK:  UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTickets.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TicketCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell.textLabel?.font = UIFont.systemFontOfSize(15)
        
        let requestDetails: Tickets = allTickets[indexPath.row] as! Tickets
        
        cell.textLabel?.text = requestDetails.ticketSubject
        cell.detailTextLabel?.text = requestDetails.ticketDescription
        
        return cell
        
    }
    
    //MARK:  UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let ticketDetails = allTickets[indexPath.row]
        
        self.performSegueWithIdentifier(Segue_Chat_Details, sender: ticketDetails)
    }

    
    @IBAction func onClickNewChat(sender: AnyObject) {
        
        self.performSegueWithIdentifier(Segue_Pre_Chat, sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Segue_Chat_Details {
            
            let destinationVC = segue.destinationViewController as! ViewController
            let ticket = sender as! Tickets
            destinationVC.subject = ticket.ticketSubject
            destinationVC.ticketId = ticket.ticketId
        }
        else if segue.identifier == Segue_Pre_Chat {
            
        }
        
    }
    

}
