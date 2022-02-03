//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    let sentimentClassifier = TweetSentimentClassifier()
    
    
    let swifter = Swifter(consumerKey: "API KEY", consumerSecret: "API CONSUMER SECRET")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
       fetchTweets()
    }
    
    func fetchTweets() {
        
        if let searchText = textField.text,
           searchText != "" {
            swifter.searchTweet(using: searchText,
                                lang: "en",
                                count: tweetCount,
                                tweetMode: .extended) { result, searchMetadata in
                
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<self.tweetCount  {
                    if let tweet = result[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                self.makePrediction(with: tweets)
                
            } failure: { error in
                print("Could not get results from the Twitter APi: \(error)")
            }
        }
    }

    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var score = 0
            
            for prediction in predictions {
                if prediction.label == "Pos" {
                    score += 1
                } else if prediction.label == "Neg" {
                    score -= 1
                }
            }
            updateUI(with: score)
        } catch {
            print(error)
        }
    }
    
    func updateUI(with score: Int) {
        switch score {
        case 20... :
            self.sentimentLabel.text = "😍"
        case 10..<20 :
            self.sentimentLabel.text = "😀"
        case 1..<10 :
            self.sentimentLabel.text = "🙂"
        case 0 :
            self.sentimentLabel.text = "😐"
        case -10..<0 :
            self.sentimentLabel.text = "😕"
        case -20 ..< -10 :
            self.sentimentLabel.text = "😡"
        default:
            self.sentimentLabel.text = "🤮"
        }
    }
}

