//
//  PlayMusicTableViewController.swift
//  PlayMusicFrmoAppleAPI
//
//  Created by Jason Deng on 2022/1/5.
//

import UIKit
import Alamofire
import AVFoundation

class PlayMusicTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    let player = AVPlayer()
    var searchController: UISearchController!
    var searchResponse: SearchResponse = SearchResponse(results: [])
    var selectedRow = 0
    var selectedMusic: Music?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myInit()
        
        tableView.register(UINib(nibName: "PlayMusicTableViewCell", bundle: nil), forCellReuseIdentifier: "PlayMusicTableViewCell")
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return searchResponse.results.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "目前播放的歌曲"
        } else {
            return "你搜尋的歌曲"
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayMusicTableViewCell", for: indexPath) as? PlayMusicTableViewCell else { return UITableViewCell()}
        if indexPath.section == 0 {
            if let music = selectedMusic {
                // playButton 狀態初使化
                if  selectedMusic!.isPlay == nil  {
                    selectedMusic!.isPlay = false
                }
                cell.configure(for: music)
                cell.playButton.tag = selectedRow
                cell.playButton.addTarget(self, action: #selector(playMusic(_:)), for: .touchUpInside)
            }
            
        } else {
            
            // playButton 狀態初使化
            if  searchResponse.results[indexPath.row].isPlay == nil  {
                searchResponse.results[indexPath.row].isPlay = false
            }
            
            let music = searchResponse.results[indexPath.row]
            cell.configure(for: music)
            cell.playButton.tag = indexPath.row
            cell.playButton.addTarget(self, action: #selector(playMusic(_:)), for: .touchUpInside)
        }
        
        return cell

    }
    
    
    // MARK: -  tableView delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: true)
        } else { return }
    }
    
    
    // MARK: -  SearchBar
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 去除空白, 換行字元
        let keyword = searchBar.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // 確認SearchBar有輸入關鍵字
        guard keyword.count > 0 else { return }
        NetWorkResponse.shared.keyword = keyword
        NetWorkResponse.shared.getMusic(url: NetWorkResponse.shared.urlPath) { (data) in
            guard let music: SearchResponse = NetWorkResponse.shared.parseJson(data) else{return}
            self.searchResponse = music
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    // MARK: -  Custom func
    private func myInit(){
        // MARK: -  Setting SearchController
        searchController = UISearchController(searchResultsController: nil)
        // iOS 10.0使用
        //        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "搜尋..."
        searchController.searchBar.text = "張學友"
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.sizeToFit()
        // iOS 9使用
        tableView.tableHeaderView = searchController.searchBar
    
        // 音樂播放結束通知
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            
            let row = self.selectedRow
            self.searchResponse.results[row].isPlay = false
            
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
        }
    
    }
   
    @objc func playMusic(_ sender: UIButton){
        guard searchResponse.results.count > 0 else { return }
        let row = sender.tag
        guard let  urlPath = searchResponse.results[row].previewUrl,
              let isPlaying = searchResponse.results[row].isPlay else {
            return
        }

        // 更新play按鈕狀態及之前點選的PlayButton 狀態
        if selectedRow != row {
            searchResponse.results[selectedRow].isPlay = false
        }
        // 更新Row PlayButton狀態
        searchResponse.results[row].isPlay = !isPlaying
        
        // 更新目前所選歌曲內容
        selectedMusic = searchResponse.results[row]

        // 更新目前點選的Row, 及之前點選的Row
        tableView.reloadRows(at: [IndexPath(row: row, section: 1), IndexPath(row: selectedRow, section: 1), IndexPath(row: 0, section: 0)], with: .automatic)
        selectedRow = row
        
        if isPlaying {
            player.pause()
        } else {
            let url = URL(string: urlPath)!
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.play()
        }
    }
    
}
