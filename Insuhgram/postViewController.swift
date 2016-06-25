//
//  postViewController.swift
//  Insuhgram
//
//  Created by Alexina Boudreaux-Allen on 6/22/16.
//  Copyright © 2016 Alexina Boudreaux-Allen. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class postViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var postComment: UITextView!

   
    @IBOutlet weak var imageView: UIImageView!
    
     let imagePicker = UIImagePickerController()
    
    @IBAction func loadImage(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onPost(sender: AnyObject) {
        
            let image = self.imageView.image
            let fileCaption: String = self.postComment.text
            
            self.postUserImage(image, withCaption: fileCaption, withCompletion: { (success: Bool, error:NSError?) in
                if(success){
                    print("Post successfully made")
                    
                }
                else{
                    
                    print("Did not post")
                }
            })
           // self.performSegueWithIdentifier("homeSegue", sender: nil)
        
    }
    
    
    override func viewDidLoad() {
        imagePicker.delegate = self
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        
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
