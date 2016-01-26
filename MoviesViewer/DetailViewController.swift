//
//  DetailViewController.swift
//  MoviesViewer
//
//  Created by Veronika Kotckovich on 1/24/16.
//  Copyright © 2016 Veronika Kotckovich. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var OverviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    
    
    
    var movie: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backButton.frame = CGRect(x: 0, y: 0, width: 320, height: 64)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as? String
        titleLabel.text = title
        
        let Overview = movie["overview"] as! String
        OverviewLabel.text = Overview
        
        OverviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        //        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
        let placeholderImage = UIImage(named: "placeholder")
        
        posterImageView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: placeholderImage,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    self.posterImageView.alpha = 0.0
                    self.posterImageView.image = image
                    UIView.animateWithDuration(1.5, animations: { () -> Void in
                        self.posterImageView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    self.posterImageView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        }
        print(movie)
        
        self.navigationController?.navigationBarHidden = true
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func goBack(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
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
