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

let closeTicketColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1)
let openTicketColor = UIColor(red: 164/255, green: 214/255, blue: 68/255, alpha: 1)

class TicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tblTickets: UITableView!
    var allTickets: NSArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tblTickets.rowHeight=UITableViewAutomaticDimension;
        tblTickets.estimatedRowHeight=200.0;

    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Chat"
        getTickets("new,open,closed,solved")
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
        return 72 ;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TicketCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! RMTicketTableViewCell
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        let requestDetails: Tickets = allTickets[indexPath.row] as! Tickets
        
        cell.lblTicketTitle.text = requestDetails.ticketSubject
        cell.lblTicketDescription.text = requestDetails.ticketDescription
        cell.lblTime.text = requestDetails.createdDate
        
        if isTicketOpen(requestDetails.ticketStatus) {
            cell.statusView.backgroundColor = openTicketColor
        }
        else {
            cell.statusView.backgroundColor = closeTicketColor
        }
        
        
        return cell
        
    }
    
    func isTicketOpen(status: String) -> Bool {
        
        if status == "open" || status == "new" {
            return true
        }
        else {
            return false
        }
        
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
