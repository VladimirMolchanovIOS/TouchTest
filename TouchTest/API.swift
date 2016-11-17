//
//  API.swift
//  TouchTest
//
//  Created by Владимир Молчанов on 16/11/2016.
//  Copyright © 2016 Владимир Молчанов. All rights reserved.
//

import Alamofire
import SwiftyJSON
import RxSwift

class ApiError: Swift.Error {
    let code: Int
    let description: String
//    let requestParams = [String: Any]()
    
    init(errorCode: Int, errorMessage: String) {
        self.code = errorCode
        self.description = errorMessage
    }
}


//MARK: VK API URLs
let kCommonPart = "https://api.vk.com/method"

let kGetWallPosts = kCommonPart + "/wall.get"

class API: NSObject {
    //MARK: API methods
    func getWallPosts(ownerId: Int, ownerShortName: String?, offset: Int? = nil, count: Int? = nil, filter: String? = nil, extended: Bool = false, additionalFieldsToReturn: [String]? = nil) -> Observable<Result<[WallPostModel]>> {
        var params = [String: Any]()
        if let domain = ownerShortName {
            params["domain"] = domain
        } else {
            params["owner_id"] = ownerId
        }
        if offset != nil {
            params["offset"] = offset!
        }
        if count != nil {
            params["count"] = count!
        }
        if let filt = filter, filt != "all" {
            params["filter"] = filt
        }
        if extended {
            if let addFields = additionalFieldsToReturn {
                params["extended"] = 1
                params["fields"] = addFields.joined(separator: ",")
            }
        }
        
        return self.failableResultObservable(url: kGetWallPosts, method: .get, params: params, transform:
            { response in
                switch response {
                case .success(let val):
                    let json = JSON.parse(val.result.value!)
                    var respArray = json["response"].arrayValue
                    respArray.removeFirst()
                    let posts = respArray
                    let postModels = posts.map { WallPostModel(json: $0)}
                    return Result.success(postModels)
                case .failure(let error):
                    return Result.failure(error)
                }
        }
        )
    }
    
    
    
    private func failableResultObservable<T>(url: URLConvertible, method: HTTPMethod, params: [String: Any]?, transform: @escaping (Result<DataResponse<String>>) -> T) -> Observable<T> {
        return Observable<Result<DataResponse<String>>>.create { (observer) -> Disposable in
            request(url, method: method, parameters: params).responseString { (response) in
                if response.result.isFailure {
                    observer.onNext(Result.failure(ApiError(errorCode: 1, errorMessage: "Unknown error occured")))
                    observer.onCompleted()
                } else {
                    if let preResValue = response.result.value {
                        print(preResValue)
                        let json = JSON.parse(preResValue)
                        if json.type == .null {
                            observer.onNext(Result.success(response))
                            observer.onCompleted()
                        } else if let unknownTypeError = json.error {
                            observer.onNext(Result.failure(ApiError(errorCode: unknownTypeError.code, errorMessage: unknownTypeError.localizedDescription)))
                        } else {
                            let errorJSON = json["error"]
                            if errorJSON.exists() {
                                let errorCode = errorJSON["error_code"].intValue
                                let errorMessage = errorJSON["error_msg"].stringValue
                                observer.onNext(Result.failure(ApiError(errorCode: errorCode, errorMessage: errorMessage)))
                                observer.onCompleted()
                            } else {
                                observer.onNext(Result.success(response))
                                observer.onCompleted()
                            }
                        }
                    } else {
                        observer.onNext(Result.failure(ApiError(errorCode: 1, errorMessage: "Unknown error occured")))
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
            }.map(transform)
    }

    
    
}
