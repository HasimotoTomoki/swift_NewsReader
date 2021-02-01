//
//  ListViewController.swift
//  NewsReader
//
//  Created by 橋本智樹 on 2020/12/11.
//  Copyright © 2020 hasimoto　tomoki. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController, XMLParserDelegate{
    var parser: XMLParser! // 解析するデータを入れる
    var items = [Item]()   // 記事の配列
    var item: Item?        // Itemクラスのプロパティ
    var currentString = "" // 解析で抽出した文字列一時保管
    var urllist = [String]() //　文字列の格納
    
    // 画面を表示するときに１回だけ呼ばれるメソッド
    override func viewDidLoad() {
        print("viewdidloadが呼ばれた") //最初にviewdidloadが呼ばれる
       let  refresh = UIRefreshControl() //UIRefreshController　更新
        refresh.addTarget(self, action: #selector(ListViewController.startDownloud),
                          //addTarget()下に引っ張ったときに何を渡すのかを記述 selector()に何を起動させるか記述
                       for: UIControl.Event.valueChanged) //valuechanged(更新のクルクル)が実行されたら
        self.refreshControl = refresh //　更新
        let ud = UserDefaults.standard // 保存した記事をudに入れる
        if let list = ud.object(forKey: "urllist") as? [String] { // 保存された記事がurllistにlinkの追加されたものが既読対象
            urllist = list
        }
    }
    
     // セクションの中にある記事のカウント数を返す
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    //　表示するセルを返す
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //cellを取得
        cell.textLabel?.text = items[indexPath.row].title // 何番めのセルを呼ぶのか
        let URL = items[indexPath.row].link // これから表示する記事のリンク
        if(urllist.contains(URL)) { // urllist.contains(URL)に渡されたurlが入ったら既読
            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            
    
        }else{
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17) //　未読
        }
        
        return cell
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDownloud()
    }
    override func viewDidDisappear(_ animated: Bool) { //　画面が消えた時動く
        let userdefaults = UserDefaults.standard
        userdefaults.set(urllist, forKey: "urllist")
    }
    // データのダウンロード
    @objc func startDownloud() {
        print("stardownloadが呼ばれた")
        self.items = [] // 記事を空にする
        if let url = URL( // URL指定
            string: "https://wired.jp/rssfeeder/"){
            if let parser = XMLParser(contentsOf: url){
                self.parser = parser //解析するデータを入れる
                self.parser.delegate = self  // デリゲートを自分に指定
                self.parser.parse()  // 解析スタート
            }
        }
    }
    // 開始タグを見つけると動く
    func parser(_ parser: XMLParser,  
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String: String]) {
        self.currentString = ""  // 保存先の箱を空にする
        if elementName == "item" {  // 要素名がitemの場合記事(item)を入れるItemクラスの箱を作る
            self.item = Item()
        }
    } // タグ内に文字列があったとき動く
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        self.currentString += string // タグ内に文字列を見つけたらcurrentStringに内容が追加される
    }
    //終了タグが見つかった時動く
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        switch elementName{
            case "title" : self.item?.title = currentString //要素名がtitleの場合currentStingの内容をitem?.titleに入れる
            case "link"  : self.item?.link = currentString  //要素名がlinkの場合currentStingの内容をitem?.linkに入れる
            case "item"  : self.items.append(self.item!)    //要素名がitemの場合ここまで取得してきたデータをitemsに入れる
        default : break
        }
    }
    //解析終了
    func parserDidEndDocument(_ parser: XMLParser) {
        self.tableView.reloadData()  //再読み込み
        self.refreshControl?.endRefreshing() //アニメーションの停止
    }
    // クリックした記事のデータを次の画面に渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.tableView.indexPathForSelectedRow { // クリックした記事をindexPathに入れる
            let item = items[indexPath.row] // items配列から該当する記事 (item)を取得
            let controller = segue.destination as! DetailViewController // controllerに遷移先のビューコントローラーの指定
            controller.title = item.title // 遷移先に記事のタイトルをいれる
            controller.link = item.link  // 遷移先に記事のURLをいれる
            urllist.append(item.link) //　記事のlinkを既読の配列に追加
        }
    }
}
