//
//  DetailViewController.swift
//  NewsReader
//
//  Created by 橋本智樹 on 2020/12/12.
//  Copyright © 2020 hasimoto　tomoki. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController : UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    var link: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: self.link) { //urlインスタンス生成
            let request = URLRequest(url: url) //データの保存方法を設定
            self.webView.load(request) //クリックした記事の内容をロードしてWebviewに表示
        }
    }
    
    
}
