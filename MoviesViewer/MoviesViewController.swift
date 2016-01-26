//
//  MoviesViewController.swift
//  MoviesViewer
//
//  Created by Veronika Kotckovich on 1/7/16.
//  Copyright © 2016 Veronika Kotckovich. All rights reserved.
//

import UIKit
import AFNetworking
import PKHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    
    
    
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
        
    
   
    
    //@IBOutlet weak var scrollView: UIScrollView!
    var movies:[NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var endpoint: String!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
       // filteredMovies = movies
        
        PKHUD.sharedHUD.contentView = PKHUDProgressView()
        PKHUD.sharedHUD.show()
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()){
            
            PKHUD.sharedHUD.hide(afterDelay: 0.5)
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
            
            self.tableView.addSubview(self.refreshControl)
            
    }
        
   //     navigationController!.navigationBar.barTintColor = UIColor(red: 199.0/255.0, green: 50.0/255.0, blue: 112.0/255.0, alpha: 0.5)
        searchBar.barTintColor = UIColor(red: 199.0/255.0, green: 76.0/255.0, blue: 125.0/255.0, alpha: 1)
        searchBar.tintColor = UIColor.whiteColor()
        tableView.dataSource = self
        tableView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            
                            self.filteredMovies = self.movies
                            self.tableView.reloadData()
                    }
                }
        });
        task.resume()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("networkStatusChanged:"), name: ReachabilityStatusChangedNotification, object: nil)
        Reach().monitorReachabilityChanges()
    
        let cell : MovieCell
        
//        tableView.rowHeight = CGSizeMake(<#T##width: CGFloat##CGFloat#>, <#T##height: CGFloat##CGFloat#>)
        //(width: cell.frame.size.width, height: cell.frame.size.height)
    }
    
    override func viewWillAppear(animated: Bool) {
        searchBar.hidden=true
//        self.searchBar.text = ""
//        self.searchBar.resignFirstResponder()
//        
//        self.filteredMovies = self.movies
        self.tableView.reloadData()

        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 606)
    }

   
    @IBAction func buttonClicked(sender: UIButton) {
        if  (self.searchBar.hidden == true) {
            self.searchBar.hidden=false
            tableView.frame = CGRect(x: 0, y: 41, width: 320, height: 606)
        }else {
            self.searchBar.hidden=true
            tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 606)
            searchBar.text = ""
            searchBar.resignFirstResponder()
            self.filteredMovies = self.movies
            self.tableView.reloadData()
        }
    }
    
//    @IBAction func searchButtonTyped(sender: UIBarButtonItem) {
//        self.searchBar.hidden=false
//
//    }
    
    func networkStatusChanged(notification: NSNotification) {
        
        let status = Reach().connectionStatus()
        switch status {
        case .Unknown, .Offline:
            showAlert()
        case .Online(.WWAN):
            dismissAlert()
            print("Connected via WWAN")
        case .Online(.WiFi):
            dismissAlert()
            print("Connected via WiFi")
        }
        
    }
    
    func showAlert() {
        let alertController = UIAlertController(title: "Network error!", message: "", preferredStyle: .Alert)
        //        let subview = alertController.view.subviews.first! as UIView
        //        let alertContentView = subview.subviews.first! as UIView
        //        alertController.view.tintColor = UIColor.whiteColor()
        //        alertContentView.backgroundColor = UIColor.blackColor()
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dismissAlert(){
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            
        })
        self.tableView.reloadData()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0
        }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovies![indexPath.row]
//        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
//        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        let placeholderImage = UIImage(named: "placeholder")
        
        cell.posterView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: placeholderImage,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                   cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(1.5, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                   cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        //cell.posterView.setImageWithURL(imageUrl!)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        //cell.titleLabel.sizeToFit()
        cell.overviewLabel.sizeToFit()
        
        print("row\(indexPath.row)")
        return cell
    }
    
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filteredMovies = self.movies
        self.tableView.reloadData()
        self.searchBar.hidden=true
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 606)
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detail" {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            //let movie = movies![indexPath!.row]
            let movie = filteredMovies![indexPath!.row]
            let detailViewController = segue.destinationViewController as! DetailViewController
            detailViewController.movie = movie
            print("Prepare for segue")
        } else if segue.identifier == "collection" {
            let collectionViewController = segue.destinationViewController as! UINavigationController
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
