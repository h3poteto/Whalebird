//
//  ListTableViewController.swift
//  Whalebird
//
//  Created by akirafukushima on 2014/09/16.
//  Copyright (c) 2014年 AkiraFukushima. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct Stream {
        var image: String?
        var name: String
        var type: String
        var uri: String
        var id: String?
    }
    
    
    var streamList: Array<Stream> = [Stream(image: nil, name: "Home", type: "statuses", uri: "/statuses/home_timeline", id: nil)]
    var addItemButton: UIBarButtonItem!
    
    //==============================================
    //  instance method
    //==============================================
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "リスト"
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init() {
        super.init()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.streamList.append(Stream(image: nil, name: "Reply", type: "statuses", uri: "/statuses/mentions_timeline", id: nil))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.addItemButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewItem:")
        self.navigationItem.leftBarButtonItem = self.addItemButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.streamList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = self.streamList[indexPath.row].name

        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            self.streamList.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        // streamListを入れ替える
        var fromCellData = self.streamList[fromIndexPath.row]
        var toCellData = self.streamList[toIndexPath.row]
        self.streamList[fromIndexPath.row] = toCellData
        self.streamList[toIndexPath.row] = fromCellData
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var streamTableView = StreamTableViewController(StreamElement: self.streamList[indexPath.row], PageIndex: indexPath.row, ParentController: self)
        self.navigationController?.pushViewController(streamTableView, animated: true)
    }

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */


    func addNewItem(sender: AnyObject) {
        var stackListTableView = StackListTableViewController(StackTarget: NSURL.URLWithString("https://api.twitter.com/1.1/lists/list.json"))
        self.navigationController?.pushViewController(stackListTableView, animated: true)
    }
}
