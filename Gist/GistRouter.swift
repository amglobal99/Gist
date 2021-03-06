
//  GistRouter.swift
//  

import Foundation
import Alamofire
import SwiftyJSON


enum GistRouter: URLRequestConvertible {
    
    
    // The URLRequestConvertible can be found in Alamorefire.swift
    
    
    static let baseURLString:String = "https://api.github.com/"
    
      
    case getPublic() // GET https://api.github.com/gists/public
    case getMyStarred() // GET https://api.github.com/gists/starred
    case getMine() // GET https://api.github.com/gists
    case isStarred(String) // GET https://api.github.com/gists/\(gistId)/star
    case getAtPath(String) // GET at given path
    case star(String) // PUT https://api.github.com/gists/\(gistId)/star
    case unstar(String) // DELETE https://api.github.com/gists/\(gistId)/star
    case delete(String) // DELETE https://api.github.com/gists/\(gistId)
    case create([String: AnyObject]) // POST https://api.github.com/gists
    
    
    
    var URLRequest: NSMutableURLRequest {
    
        
        // +++++++++++++ which HTTP method ? ++++++++++++++++++
        var method: Alamofire.Method {
            switch self {
            case .getPublic, .getAtPath, .getMine, .getMyStarred, .isStarred:
                return .GET
            case .star:
                return .PUT
            case .unstar, .delete:
                return .DELETE
            case .create:
                return .POST
            }
        }
        
        
        
        // ++++++++++++++++ obtain URL +++++++++++++++++++++++++
        
        let url:URL = {
            // build up and return the URL for each endpoint
            let relativePath:String?
            switch self {
            case .getAtPath(let path):
                // already have the full URL, so just return it
                return Foundation.URL(string: path)!
            case .getPublic():
                relativePath = "gists/public"
            case .getMyStarred:
                relativePath = "gists/starred"
            case .getMine():
                relativePath = "gists"
            case .isStarred(let id):
                relativePath = "gists/\(id)/star"
            case .star(let id):
                relativePath = "gists/\(id)/star"
            case .unstar(let id):
                relativePath = "gists/\(id)/star"
            case .delete(let id):
                relativePath = "gists/\(id)"
            case .create:
                relativePath = "gists"
            }
            
            var URL = Foundation.URL(string: GistRouter.baseURLString)!
            if let relativePath = relativePath {
                URL = URL.appendingPathComponent(relativePath)
            }
            return URL
        }()
        
        
        // ++++++++++++++ obtain params ++++++++++++++++++++++++++++++
        let params: ([String: AnyObject]?) = {
            switch self {
            case .getPublic, .getAtPath, .getMyStarred, .getMine, .isStarred, .star, .unstar, .delete:
                return nil
            case .create(let params):
                return params
            }
        }()
        
        
        
        //  +++++++++++++ create NSMutableRequest object that we wil  return ++++++++++
        let URLRequest = NSMutableURLRequest(url: url)
        
        // Set OAuth token if we have one
        if let token = GitHubAPIManager.sharedInstance.OAuthToken {
            URLRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let encoding = Alamofire.ParameterEncoding.json
        let (encodedRequest, _) = encoding.encode(URLRequest, parameters: params)
        
        encodedRequest.httpMethod = method.rawValue
        
        
        // +++++++  return NSMutableURLRequest object +++++++++++
        return encodedRequest
        
    }  // var URLRequest

    
    
    
    
}   // end enum






