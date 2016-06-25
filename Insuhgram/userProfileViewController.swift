//
//  userProfileViewController.swift
//  Insuhgram
//
//  Created by Alexina Boudreaux-Allen on 6/23/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class userProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var posts: [PFObject]? = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        self.profileLabel.text = PFUser.currentUser()?.username
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // imagePicker.delegate = self
        let query = PFQuery(className: "Post")
        query.whereKey("author", equalTo: PFUser.currentUser()!)
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        
        // fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (posts: [PFObject]?, error: NSError?) -> Void in
            if let posts = posts {
                self.posts = posts
                self.collectionView.reloadData()
                print("working")
            } else {
                // handle error
            }
        }
        


        // Do any additional setup after loading the view.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let posts = posts{
            
            return posts.count
        }
        else{
            return 0
        }
        

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InstaCollectionCell", forIndexPath:indexPath) as! InstaCollectionCell
        
        let post = posts![indexPath.row]
        let author = post["author"]
        let username = author.username

        
        if (posts?[indexPath.section]["media"] != nil) {
            let imageFile = posts?[indexPath.row]["media"] as! PFFile
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) ->
                Void in
                
                if let error = error {
                    NSLog("Unable to get image data for table cell \(indexPath.section)\nError: \(error)")
                }
                else {
                    
                    
                    let image = UIImage(data: data!)
                    cell.userPhotos.image = image
                    
                 
                 
                }
            })
        }
        
        
        print("row \(indexPath.row)")
        
        return cell
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?){
        let post = PFObject(className: "Post")
        post["media"] = getPFFileFromImage(image)
        post["author"] = PFUser.currentUser()
        post["caption"] = caption
        post["likesCount"] = 0
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
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
