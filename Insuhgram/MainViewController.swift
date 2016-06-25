//
//  MainViewController.swift
//  Insuhgram
//
//  Created by Alexina Boudreaux-Allen on 6/20/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import Parse
import ParseUI
//import UIScrollView_InfiniteScroll



class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{    
    @IBOutlet weak var tableView: UITableView!
    
    var likes: Int = 0
    
    var posts: [PFObject]? = []
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var refreshControl = UIRefreshControl()
    
    var cellViewController = InstaTableViewCell()
    var requests: Int = 0
   
    
    @IBAction func logoutButton(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            print("you're logged out")
           
        }
       
        //self.performSegueWithIdentifier("logoutSegue", sender: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.tabBar.hidden = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
       // imagePicker.delegate = self
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 5
        
        /*// change indicator view style to white
        tableView.infiniteScrollIndicatorStyle = .White
        
        // Add infinite scroll handler
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
        let tableView = scrollView as! UITableView
            
 */
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                self.posts = posts
                 self.tableView.reloadData()
                   //tableView.finishInfiniteScroll()
                print("working")
            } else {
                // handle error
            }
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadDataFromNetwork(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.insertSubview(refreshControl, atIndex: 0)

    }
 
   
    func loadDataFromNetwork(refreshControl: UIRefreshControl?){
        let query = PFQuery(className: "Post")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 5
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                self.posts = posts
                self.tableView.reloadData()
                refreshControl!.endRefreshing()
                print("refresh working")
            } else {
                // handle error
            }
        }

    
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
   
    

func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
    if let posts = posts{
        
        return posts.count
    }
    else{
        return 0
    }

}



func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("InstaTableViewCell", forIndexPath:indexPath) as! InstaTableViewCell
    
    cell.selectionStyle = .None
    
    let post = posts![indexPath.row]
 
    let postText = post["caption"] as! String
    
        if (posts?[indexPath.section]["media"] != nil) {
            let imageFile = posts?[indexPath.row]["media"] as! PFFile
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) ->
                Void in
                
                if let error = error {
                    NSLog("Unable to get image data for table cell \(indexPath.section)\nError: \(error)")
                }
                else {
                    let image = UIImage(data: data!)
                    cell.photoView.image = image
                }
            })
    }
    
    let formatter = NSDateFormatter()
    formatter.dateStyle = NSDateFormatterStyle.NoStyle
    formatter.timeStyle = .ShortStyle
    
    let dateString = formatter.stringFromDate(post.createdAt!)
    
    let author = post["author"]
    
    let likes = "\(post["likesCount"])"
    
    cell.timeStampLabel.text = dateString
    cell.authorLabel.text = author.username
    cell.commentLabel.text = postText
    cell.likesLabel.text = likes
    //print("likes", likes)
    
    
    
  print("row \(indexPath.row)")
    
    return cell
    
        }
 
    func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?){
        let post = PFObject(className: "Post")
        post["media"] = getPFFileFromImage(image)
        post["author"] = PFUser.currentUser()
        post["caption"] = caption
        post["likesCount"] = cellViewController.like
        post["commentsCount"] = 0
        post.saveInBackgroundWithBlock(completion)
        }
    
    
    
    func getPFFileFromImage(imageView: UIImage?) -> PFFile?{
        if let imageView = imageView{
            if let imageData = UIImagePNGRepresentation(imageView){
                return PFFile(name:"image.png", data: imageData)
                
            }
        }
        return nil
        }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let cell = sender as? UITableViewCell {
            let indexPath = tableView.indexPathForCell(cell)
            let post = posts![indexPath!.row]
        
            let zoomViewController = segue.destinationViewController as! ZoomViewController
            zoomViewController.post = post
            print("prepare for segue")
        }
        }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            isMoreDataLoading = true
            
            // ... Code to load more results ...
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                print("should be animating")
                
                let query = PFQuery(className: "Post")
                query.orderByDescending("createdAt")
                query.includeKey("author")
                requests += 5
                query.limit = requests
                
                // fetch data asynchronously
                query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
                    if let posts = posts {
                        self.posts = posts
                        self.tableView.reloadData()
                        self.loadingMoreView!.stopAnimating()
                        self.isMoreDataLoading = false
                        print("infinite working")
                    } else {
                        // handle error
                    }
                }
                

            }
        }
    }
    
 
 
}
 







