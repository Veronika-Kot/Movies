//
//  CollectionViewController.swift
//  MoviesViewer
//
//  Created by Veronika Kotckovich on 1/8/16.
//  Copyright © 2016 Veronika Kotckovich. All rights reserved.
//

import UIKit
import AFNetworking


class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    
    var movies:[NSDictionary]?
    var filteredMovies : [NSDictionary]?
    var endpoint : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        let image = UIImage(named: "square")
        self.navigationItem.backBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: self, action: nil)
//        navigationItem.titleView =
        
        navigationController!.navigationBar.barTintColor = UIColor(red: 199.0/255.0, green: 50.0/255.0, blue: 112.0/255.0, alpha: 1.0)
        searchBar.barTintColor = UIColor(red: 199.0/255.0, green: 76.0/255.0, blue: 125.0/255.0, alpha: 1)
        searchBar.tintColor = UIColor.whiteColor()
        //self.collectionView.backgroundColor = UIColor(red: 245.0/255.0, green: 187.0/255.0, blue: 27.0/255.0, alpha: 1.0)


        collectionView.dataSource = self
        collectionView.delegate = self
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.filteredMovies = self.movies
                            self.collectionView.reloadData()
                    }
                }
        });
        task.resume()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        searchBar.hidden=true
        collectionView.frame = CGRect(x: 0, y: 64, width: 320, height: 460)
    }
    
    @IBAction func buttonClicked(sender: UIButton) {
        if  (self.searchBar.hidden == true) {
            
             self.searchBar.hidden=false
             collectionView.frame = CGRect(x: 0, y: 108, width: 320, height: 460)
        }else {
            
             self.searchBar.hidden=true
             collectionView.frame = CGRect(x: 0, y: 64, width: 320, height: 460)
             searchBar.text = ""
             searchBar.resignFirstResponder()
             self.filteredMovies = self.movies
             self.collectionView.reloadData()
      }
    }

   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = searchText.isEmpty ? movies : movies!.filter({ (movie: NSDictionary) -> Bool in
            return (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
            
        })
        self.collectionView.reloadData()
        
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredMovies?.count ?? 0        
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
//        let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionViewCell/Users/Veronika-Kot/GitHub/Movies/MoviesViewer/CollectionViewController.swift
        
        let cell: CollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! CollectionViewCell
        let movie = filteredMovies![indexPath.row]
    //    let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
 //       let imageUrl = NSURL(string: baseUrl + posterPath)
        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        let placeholderImage = UIImage(named: "placeholder")
//(named: "film_placeholder")
        
        cell.posterCollection.setImageWithURLRequest(
            
            imageRequest,
            placeholderImage: placeholderImage,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterCollection.alpha = 0.0
                    cell.posterCollection.image = image
                    UIView.animateWithDuration(1.5, animations: { () -> Void in
                        cell.posterCollection.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterCollection.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
       
      //  cell.posterCollection.setImageWithURL(imageUrl!)
        
        cell.titleCollection.text = title
        
        print("row\(indexPath.row)")
        return cell
    }

    
//    @IBAction func didPressMenuButton(sender: AnyObject) {
//        
//        dismissViewControllerAnimated(false, completion: nil)
//    }
//    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.filteredMovies = self.movies
        self.collectionView.reloadData()
        self.searchBar.hidden=true
        collectionView.frame = CGRect(x: 0, y: 64, width: 320, height: 460)
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        //let movie = movies![indexPath!.row]
        let movie = filteredMovies![indexPath!.row]
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        print("Prepare for segue")

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
