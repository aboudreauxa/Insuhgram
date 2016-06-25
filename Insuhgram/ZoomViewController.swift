//  ZoomViewController.swift
//  Insuhgram
//
//  Created by Alexina Boudreaux-Allen on 6/22/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ZoomViewController: UIViewController{
    
 
    @IBAction func homeButton(sender: AnyObject) {
   
    }
    @IBOutlet weak var zoomPhoto: PFImageView!
    
    var post: PFObject!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        self.tabBarController?.tabBar.hidden = true
        
        if (post["media"] != nil) {
            let imageFile = post["media"] as! PFFile
            imageFile.getDataInBackgroundWithBlock({ (data: NSData?, error: NSError?) ->
                Void in
                
                if let error = error {
                    NSLog("Unable to get image data for table cell")
                }
                else {
                    let image = UIImage(data: data!)
                    self.zoomPhoto.image = image
                }
            })
        }


 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

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
