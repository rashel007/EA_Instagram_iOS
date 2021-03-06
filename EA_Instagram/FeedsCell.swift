//
//  FeedsCell.swift
//  EA_Instagram
//
//  Created by Estique on 11/5/17.
//  Copyright © 2017 Estique. All rights reserved.
//

import UIKit
import Firebase

class FeedsCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var likeCount: UILabel!
    
    
    @IBOutlet var likeBtn: UIButton!
    @IBOutlet var unlikeBtn: UIButton!
    
    var postID: String!
    
    
    @IBAction func likeBtnPressed(_ sender: Any) {
        self.likeBtn.isEnabled = false
        
        let ref = Database.database().reference()
        
        let keyToPost = ref.child("posts").childByAutoId().key
        
        ref.child("posts").child(self.postID).observe(.value, with: { (snapshot) in
            if let post = snapshot.value as? [String : AnyObject] {
                
                let updateLikes: [String : Any] = ["peopleWhoLikes/\(keyToPost)" : Auth.auth().currentUser?.uid]
                ref.child("posts").child(self.postID).updateChildValues(updateLikes, withCompletionBlock: { (error, reff) in
                    if error == nil {
                        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snap) in
                            if let properties = snap.value as? [String : AnyObject] {
                                if let likes = properties["peopleWhoLikes"] as? [String : AnyObject] {
                                    let count = likes.count
                                    self.likeCount.text = "\(count) Likes"
                                    
                                    let update = ["likes" : count]
                                    ref.child("posts").child(self.postID).updateChildValues(update)
                                    
                                    self.likeBtn.isHidden = true
                                    self.unlikeBtn.isHidden = false
                                    self.likeBtn.isEnabled = true
                                }
                            }
                        })
                    }
                })
                
            }
        })
        
        ref.removeAllObservers()
    }
    
    @IBAction func unlikeBtnPressed(_ sender: Any) {
           self.unlikeBtn.isEnabled = false
         let ref = Database.database().reference()
        
        ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let properties = snapshot.value as? [String : AnyObject] {
                
                if let peopleWhoLikes = properties["peopleWhoLikes"] as? [String : AnyObject] {
                    for (id, person) in peopleWhoLikes {
                        
                        if person as? String == Auth.auth().currentUser?.uid {
                            ref.child("posts").child(self.postID).child("peopleWhoLikes").child(id).removeValue(completionBlock: { (error, reff) in
                                if error == nil {
                                    ref.child("posts").child(self.postID).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let prop = snapshot.value as? [String : AnyObject] {
                                            
                                            if let likes = prop["peopleWhoLikes"] as? [String : AnyObject] {
                                                let count = likes.count
                                                self.likeCount.text = "\(count) Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : count])
                                            }else {
                                                self.likeCount.text = "0 Likes"
                                                ref.child("posts").child(self.postID).updateChildValues(["likes" : 0])
                                            }
                                            
                                     
                                        }
                                    })
                                }
                            })
                            self.likeBtn.isHidden = false
                            self.unlikeBtn.isHidden = true
                            self.unlikeBtn.isEnabled = true
                            break
                      
                        }
                    }
                }
                
            }
        })
        
        ref.removeAllObservers()
    }
    
    
}
