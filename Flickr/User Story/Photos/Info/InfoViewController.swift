//
//  InfoViewController.swift
//  Flickr
//
//  Created by Alexey Bukhtin on 09/08/2018.
//  Copyright © 2018 F3 Software. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView! {
        didSet {
            if let infoURL = Bundle.main.url(forResource: "Info", withExtension: "pdf") {
                webView.loadRequest(URLRequest(url: infoURL))
            }
        }
    }
}
