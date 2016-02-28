//
//  ProfileViewController.swift
//  vTweetz
//
//  Created by Vinu Charanya on 2/27/16.
//  Copyright © 2016 vnu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {


    @IBOutlet weak var profileBgImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var websiteLinkLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var tweetsSeparatorView: UIView!
    
    @IBOutlet weak var tweetsView: UIView!
    var tweetsTableView: TweetzTableView!
    
    var user = User.currentUser!
    var tweets = [Tweet]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUserInfo()
        initTweetsTable()
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setUserInfo(){
        nameLabel.text = user.name
        screenNameLabel.text = "@\(user.screenName!)"
        if let profileBgImageUrl = user.profileBgImageUrl{
            profileBgImage.setImageWithURL(NSURL(string: profileBgImageUrl)!)
        }else{
            profileBgImage.backgroundColor = UIColor(hexString: "2B7BB9")
        }
        if let profileImageUrl = user.profileImageUrl{
            profileImage.setImageWithURL(NSURL(string: profileImageUrl)!)
        }
        locationLabel.text = user.location
        websiteLinkLabel.text = user.expandedUrl
        followingLabel.text = "\(user.friendsCount!)"
        followersLabel.text = "\(user.followersCount!)"
    }
    
    func showTweetsWith(endpoint: String){
        print(endpoint)
        tweetsTableView.fetchEndpoint = endpoint
        tweetsTableView.fetchTweets()
    }
    
    func initTweetsTable(){
        print("Came here added something")
        if let tweetsTblView = NSBundle.mainBundle().loadNibNamed("TweetzTableView", owner: self, options: nil).first as? TweetzTableView {
            tweetsTableView = tweetsTblView
            tweetsTableView.initView()
            tweetsTableView.translatesAutoresizingMaskIntoConstraints = false
            tweetsView.addSubview(tweetsTableView)
            setConstraints()
            showTweetsWith("user_timeline.json?screen_name=\(user.screenName!)")
        }
    }
    
    func setConstraints(){
        let views = ["tweetsView": self.tweetsView, "tableView": self.tweetsTableView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[tableView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: views)
        tweetsView.addConstraints(horizontalConstraints)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(-40)-[tableView]-0-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
        tweetsView.addConstraints(verticalConstraints)
    }
    
    //Tweets Buttons
    
    @IBAction func onTweetsTap(sender: UIButton) {
        showTweetsWith("user_timeline.json?screen_name=\(user.screenName!)")
    }
    
    
    @IBAction func onMediaTap(sender: UIButton) {
        showTweetsWith("mentions_timeline.json")
    }
    
    
    @IBAction func onLikesTap(sender: UIButton) {
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
