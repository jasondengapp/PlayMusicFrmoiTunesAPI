//
//  NetWorkResponse.swift
//  PlayMusicFrmoAppleAPI
//
//  Created by Jason Deng on 2022/1/5.
//

import Foundation
import Alamofire

class NetWorkResponse: NSObject, Codable {
    static let shared: NetWorkResponse = NetWorkResponse()
    
    override init() {
        
    }
    var keyword = "" {
        didSet {
            guard let paremater = "/search?term=\(keyword)&media=music".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return}
            urlPath  =  host + paremater
        }
    }
    var host = "https://itunes.apple.com"
    var urlPath = ""
    
    func getMusic(url: String,  completionHandler: @escaping (_ data: Data)->Void){
        guard let url = URL(string: url) else { return }
        // 使用 Alamofire 獲取 url 上的資料
        Alamofire.request(url).responseData{ (response) in
                // 判斷 result 是 SUCCESS 還是 FAILURE
                switch response.result {
                case .success(let data):
                    // 如果獲取到，則會把獲取的 value 轉成 JSON
                    completionHandler(data)
                    
                case .failure(let error):
                    // 印出錯誤
                    print(error)
                }
        }
    }
    
    func parseJson<T:Codable>(_ data: Data) -> T? {
        let decode = JSONDecoder()
        do {
            return try decode.decode(T.self, from: data)
        } catch  {
            print(error.localizedDescription)
            return nil
        }
    }
    
    

}
