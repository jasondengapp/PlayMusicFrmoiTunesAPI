//
//  PlayMusicTableViewCell.swift
//  PlayMusicFrmoAppleAPI
//
//  Created by Jason Deng on 2022/1/5.
//

import UIKit

class PlayMusicTableViewCell: UITableViewCell {
    @IBOutlet weak var songImage: UIImageView!{
        didSet{
            songImage.layer.cornerRadius = songImage.bounds.midX
            songImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var singerName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
    
    func configure(for music: Music){
        songName.text = music.trackName
        singerName.text = music.artistName
        songImage.image = nil
        let playImage = music.isPlay! ? UIImage(named: "pause") : UIImage(named: "play")
        playButton.setImage(playImage, for: .normal)
        NetWorkResponse.shared.getMusic(url: music.artworkUrl100!) { (data) in
            guard let image = UIImage(data: data) else{return}
            self.songImage.image = image
        }
    }
    
}
