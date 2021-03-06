//
//  HomeViewController.swift
//  vTweetz
//
//  Created by Vinu Charanya on 2/19/16.
//  Copyright © 2016 vnu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {


    @IBOutlet weak var tweetsTableView: UITableView!
    
    var isMoreDataLoading = false
    var reachedAPILimit = false
    
    let tweetCellId = "com.vnu.tweetcell"
    let tweetStatus = "home_timeline.json"
    let detailSegueId = "com.vnu.tweetDetail"
    let profileViewSegue = "ProfileViewSegue"
    let refreshControl = UIRefreshControl()
    
    let replySegueId = "com.vnu.ReplySegue"
    let homeComposeSegue = "HomeComposeSegue"
    
    private var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle())
        tweetsTableView.registerNib(cellNib, forCellReuseIdentifier: tweetCellId)

        tweetsTableView.estimatedRowHeight = 200
        tweetsTableView.rowHeight = UITableViewAutomaticDimension
        setTweetyNavBar()
        fetchTweets()

        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tweetsTableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    func setTweetyNavBar(){
        let logo = UIImage(named: "Twitter_logo_blue_32")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    
    @IBAction func onLogout(sender: UIBarButtonItem) {
        User.currentUser?.logout()
    }
    
    //Fetch Tweets
    func fetchTweets(){
        TwitterAPI.sharedInstance.fetchTweets(tweetStatus, parameters: NSDictionary(), completion: onFetchCompletion)
    }
    
    func onFetchCompletion(tweets: [Tweet]?, error: NSError?){
        if tweets != nil{
            self.tweets = tweets!
            tweetsTableView.reloadData()
        }else{
            print("ERROR OCCURED: \(error?.description)")
        }
        if refreshControl.refreshing{
            refreshControl.endRefreshing()
        }
        
    }
    
    //Segue into Detail View
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == detailSegueId {
            if let destination = segue.destinationViewController as? TweetViewController {
                if let cell = sender as? TweetCell{
                    let indexPath = self.tweetsTableView!.indexPathForCell(cell)
                    let index = indexPath!.row
                    destination.tweet = tweets[index]
                }
                destination.hidesBottomBarWhenPushed = true
            }
        }else if(segue.identifier == replySegueId){
            if let destination = segue.destinationViewController as? ComposeViewController {
                let cell = sender as! TweetCell
                destination.fromTweet = cell.tweet
                destination.delegate = self
                destination.toScreenNames = ["@\(cell.tweet.user!.screenName!)"]
                destination.hidesBottomBarWhenPushed = true
            }
        }else if(segue.identifier == homeComposeSegue){
            if let destination = segue.destinationViewController as? ComposeViewController {
                destination.delegate = self
                destination.hidesBottomBarWhenPushed = true
            }
        }else if(segue.identifier == profileViewSegue){
            if let destination = segue.destinationViewController as? ProfileViewController {
                if let cell = sender as? TweetCell{
                    let indexPath = self.tweetsTableView!.indexPathForCell(cell)
                    let index = indexPath!.row
                    destination.user = tweets[index].user!
                }
            }
            
        }
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.fetchTweets()
    }
    
    func loadMoreTweets(){
        if tweets.count > 0{
        let maxTweetId = tweets.last?.tweetId!
        let parameters = ["max_id":maxTweetId!]
        TwitterAPI.sharedInstance.loadMoreTweets(tweetStatus, parameters: parameters) { (tweets, error) -> Void in
            if tweets != nil{
                self.tweets = self.tweets + tweets!
                self.tweetsTableView.reloadData()
                if(self.isMoreDataLoading){
                    self.isMoreDataLoading = false
                }
            }else{
                print("ERROR OCCURED: \(error?.description)")
            }
            
        }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results

            let scrollViewContentHeight = tweetsTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - (tweetsTableView.bounds.size.height)
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tweetsTableView.dragging && !reachedAPILimit) {
                isMoreDataLoading = true
                loadMoreTweets()
            }

        }
    }
}

extension HomeViewController: ComposeViewControllerDelegate{
    func composeViewController(composeViewController: ComposeViewController, onCreateTweet value: Tweet) {
        tweets.insert(value, atIndex: 0)
        tweetsTableView.reloadData()
    }
}

extension HomeViewController:UITableViewDelegate, UITableViewDataSource, TweetCellDelegate{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tweetCellId) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath) as!TweetCell
        self.performSegueWithIdentifier(detailSegueId, sender: selectedCell)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tweetCell(tweetCell: TweetCell, onTweetReply value: Tweet) {
        print ("On reply delegate")
        self.performSegueWithIdentifier(replySegueId, sender: tweetCell)
    }
    
    func tweetCell(tweetCell: TweetCell, onProfileImageTap value: Tweet) {
        print("on image delegate")
           self.performSegueWithIdentifier(profileViewSegue, sender: tweetCell)
    }
    
}
