//
//  MusicList.swift
//  PlayMusicFrmoAppleAPI
//
//  Created by Jason Deng on 2022/1/5.
//

import Foundation


struct SearchResponse: Codable {
    var results: [Music]
}

struct Music: Codable {
    var trackName: String
    var artistName: String
    var artworkUrl100: String?
    var previewUrl: String?
    
    var isPlay: Bool? = false
    
}

