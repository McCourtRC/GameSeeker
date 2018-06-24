//
//  NetworkHelper.swift
//  GameTracker
//
//  Created by Jeremy Weeks on 5/17/18.
//  Copyright © 2018 Jeremy Weeks. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import SwiftMoment
import PromiseKit

class NetworkHelper {
    private let BASE_URL = "https://www.giantbomb.com/api/"
    public enum Endpoint : String {
        case games = "games"
        case game = "game"
        case search = "search"
        case platforms = "platforms"
    }
    
    private var loading : Bool = true
    private var endpoint : String?
    private var path : String?
    private var offset = 0
    private var forceVisible = false
    private var params = [
        "api_key": SaveManager.shared.apiKey,
        "format": "json"
    ] as [String : Any]
    
    private var result : AnyObject?
    
    var url : URL? {
        get {
            return URL(string: "\(BASE_URL)\(endpoint ?? "")\(path ?? "")")
        }
    }
    
    @discardableResult func set(endpoint: Endpoint, andPath path: String? = nil) -> Self {
        self.endpoint = endpoint.rawValue
        
        if let path = path {
            self.path = "/\(path)"
        }
        
        return self
    }
    
    @discardableResult func set(offset: Int) -> Self {
        params["offset"] = offset as AnyObject?
        self.offset = offset

        return self
    }
    
    @discardableResult func set(limit: Int) -> Self {
        params["limit"] = limit as AnyObject?
        
        return self
    }
    
    @discardableResult func set(params: [String : Any]) -> Self {
        for (key, value) in params {
            self.params.updateValue(value, forKey: key)
        }
        
        return self
    }
    
    @discardableResult func set(loading: Bool) -> Self {
        self.loading = loading
        
        return self
    }
    
    @discardableResult func set(forceVisible: Bool) -> Self {
        self.forceVisible = forceVisible
        
        return self
    }
    
    func get<T : Mappable>() -> Promise<[T]> { return request(withMethod: .get) }
    func post<T : Mappable>() -> Promise<[T]> { return request(withMethod: .post) }
    
    func request<T : Mappable>(withMethod method: HTTPMethod) -> Promise<[T]>{
        return Promise { seal in
            guard let url = url else {
                seal.reject(NSError(domain: "Invalid URL", code: 1, userInfo: [
                    "url": "\(BASE_URL)\(endpoint ?? "")"
                ]))
                return
            }
            
            self.isLoading = true
            if self.loading,
                offset == 0
            {
                MainTabBarController.shared.showLoading()
            }

            Alamofire
                .request(url, method: method, parameters: params)
                .responseObject { (response : DataResponse<ApiResult<T>>) in
                    self.isLoading = false
                    if self.loading {
                        MainTabBarController.shared.hideLoading()
                    }

                    switch response.result {
                    case .success:
                        guard let apiResult = response.result.value,
                            let data = apiResult.results ?? (apiResult.result != nil ? [apiResult.result!] : nil) else {
                                seal.reject(NSError(domain: "Empty Data", code: 1, userInfo: nil))
                                return
                        }
                        
                        guard apiResult.error == "OK" else {
                            seal.reject(NSError(domain: apiResult.error, code: 1, userInfo: nil))
                            return
                        }
                        
                        if let games = data as? [Game] {
                            for (index, game) in games.enumerated() {
                                game.isSearchResult = self.endpoint == Endpoint.search.rawValue || self.forceVisible
                                game.releaseDate = moment(game.releaseDate).add(self.offset + index, .Seconds).date
                            }
                        }
                        
                        self.hasMore = apiResult.offset + apiResult.pageResults < apiResult.totalResults
                        self.set(offset: apiResult.offset + apiResult.limit)
                        
                        seal.fulfill(data)
                    case .failure(let e):
                        let error = NSError(domain: "com.superjai.game-tracker", code: 0, userInfo: [
                            "url" : response.request?.url ?? "URL is nil",
                            "description": e.localizedDescription
                        ])
                        seal.reject(error)
                    }
                }
        }
    }

    var hasMore = true
    var isLoading = false
    func loadMore<T : Mappable>() -> Promise<[T]> {
        guard !isLoading else { return Promise { $0.reject(NSError(domain: "Currently loading", code: 1, userInfo: nil)) }}
        guard hasMore else { return Promise { $0.reject(NSError(domain: "No more to load.", code: 1, userInfo: nil)) }}
        
        return self.get()
    }
}
