//
//  InstaTableViewCell.swift
//  Insuhgram
//
//  Created by Alexina Boudreaux-Allen on 6/21/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class InstaTableViewCell: UITableViewCell {

    
    @IBOutlet weak var photoView: PFImageView!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var myButton: UIButton!
    var like: Int = 0

    @IBAction func likeButton(sender: AnyObject) {
        
        myButton.backgroundColor = UIColor.lightGrayColor()
       
            let post = PFObject(className: "Post")
        
            self.like += 1
  
            post["likesCount"] = self.like
            //post.saveEventually()
        likesLabel.text = String(self.like)
            print("Likes", self.like)
        
        }
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    
    var instagramPost: PFObject!{
        didSet{
            self.photoView.file = instagramPost["image"] as? PFFile
            self.photoView.loadInBackground()
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}
