//
//  GitHubAPIManager.swift

import Foundation
import Alamofire
import SwiftyJSON
import Locksmith


class GitHubAPIManager {
    
    static let sharedInstance = GitHubAPIManager()
    //var alamofireManager: Alamofire.Manager
    let clientID: String = "52c236ee0538eb2d784d"
    let clientSecret = "f7de13b794087bc479d279f6f3a44661a78da7e6"
    var isLoadingOAuthToken: Bool = false
    
    static let ErrorDomain = "com.error.GitHubAPIManager"
    
    // handler for the OAuth process
    // stored as vars since sometimes it requires a round trip to safari which
    // makes it hard to just keep a reference to it
    var OAuthTokenCompletionHandler:((NSError?) -> Void)?
    
    
    
    var OAuthToken: String? {
        set {
            guard let newValue = newValue else {
                let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "github")
                return
            }
            
            guard let _ = try? Locksmith.updateData(data: ["token": newValue], forUserAccount: "github") else {
                let _ = try? Locksmith.deleteDataForUserAccount(userAccount: "github")
                return
            }
        }
        get {
            // try to load from keychain
            Locksmith.loadDataForUserAccount(userAccount: "github")
            let dictionary = Locksmith.loadDataForUserAccount(userAccount: "github")
            return dictionary?["token"] as? String
        }
    }


    
    
    //MARK: - Supporting Functions
    
    func clearCache()-> Void  {
        let cache = URLCache.shared
        cache.removeAllCachedResponses()
    }
    
    func hasOAuthToken() -> Bool {
        
        
        if let token = self.OAuthToken {
            print("hasOAuthToken: Returning : " + String(!token.isEmpty))
            return !token.isEmpty
        }
        
        
        
        print("hasOAuthToken: Returning false")
        return false
    }
    
    func checkUnauthorized(_ urlResponse: HTTPURLResponse) -> (NSError?) {
        if (urlResponse.statusCode == 401) {
            self.OAuthToken = nil
            let lostOAuthError = NSError(domain: NSURLErrorDomain,
                                         code: NSURLErrorUserAuthenticationRequired,
                                         userInfo: [NSLocalizedDescriptionKey: "Not Logged In",
                                            NSLocalizedRecoverySuggestionErrorKey: "Please re-enter your GitHub credentials"])
            return lostOAuthError
        }
        return nil
    }

    

    // MARK: - API Calls
    
    /**
    This is the generic method that does the loading of gists
    A completeion handler variable is passed in by calling method.
     The completion handler variable is originally defined in GistsViewController under 'loadGists' method
    */
    
    func fetchGists(_ urlRequest: URLRequestConvertible, completionHandler:  @escaping (Result<[Gist]>, String?) -> Void) {
        
        Alamofire.request(urlRequest)
            .responseArray { (response:DataResponse<[Gist]>) in
                if let urlResponse = response.response,
                    let authError = self.checkUnauthorized(urlResponse) {   // checkUnauthorized returns NSError if error present
                    completionHandler(.failure(authError), nil)
                    return
                }
                // need to figure out if this is the last page
                // check the link header, if present
                let next = self.parseNextPageFromHeaders(response.response)
                completionHandler(response.result, next)
        }
    }
    
    
    
    /**
     The calls come into this method from the GistsViewController's loadGists method
     A completon handler variable is alos passed in from there
     This method calls the generic 'fetchGists'   method
    */
    
    func fetchPublicGists(_ pageToLoad: String?, completionHandler:   @escaping (Result<[Gist]>, String?) -> Void   ) {
        
        if let urlString = pageToLoad {
            fetchGists(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.getPublic(), completionHandler: completionHandler)
        }
    }
    
    
    func fetchMyStarredGists(_ pageToLoad: String?, completionHandler:   @escaping (Result<[Gist]>, String?) -> Void) {
        if let urlString = pageToLoad {
            fetchGists(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.getMyStarred(), completionHandler: completionHandler)
        }
    }
    
    func fetchMyGists(_ pageToLoad: String?, completionHandler:   @escaping (Result<[Gist]>, String?) -> Void) {
        if let urlString = pageToLoad {
            fetchGists(GistRouter.getAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.getMine(), completionHandler: completionHandler)
        }
    }
    
    func imageFromURLString(_ imageURLString: String, completionHandler: @escaping (UIImage?,NSError?)-> Void ) {
        
        
        print("Getting image from URl : " + imageURLString)
        
        
        Alamofire.request(.GET, imageURLString).response {  (request,response,data,error) in
                
                
              //guard error  != nil else {
                guard error == nil else {
                print(error)
                print("An error occurred while getting Image")
                return
            }
 
                
            
            let image = UIImage(data: data! as Data)
            completionHandler(image, nil)
            
        }  //end closure
        
        
    }  //end fucntion
    
    
    
    

    //MARK: - OAuth 2.0
    func printMyStarredGistsWithOAuth2() -> Void {
        
        print("printMyStarredGistsWithOAuth2: Starting....")
        
        let alamofireRequest = Alamofire.request(GistRouter.getMyStarred())
            .responseString { response in
                guard let receivedString = response.result.value else {
                    print("printMyStarredGistsWithOAuth2: Notice an error")
                    print( response.result.error!)
                    self.OAuthToken = nil
                    return
                }
                print("printMyStarredGistsWithOAuth2: Result : \n" + receivedString)
        } //end closure
        
        
        
        
        print("printMyStarredGistsWithOAuth2:  printing debug output")
        
        debugPrint(alamofireRequest)
    }
    
    
    
    
    
    //MARK: - Pagination
    fileprivate func parseNextPageFromHeaders(_ response: HTTPURLResponse?) -> String?   {
        
        guard let linkHeader = response?.allHeaderFields["Link"] as? String else {
            return nil
        }
        
        let components = linkHeader.characters.split {$0 == ","}.map  {String($0) }
        for item in components {
            let rangeOfNext = item.range(of: "rel=\"next\"", options: [])
            guard rangeOfNext != nil else {
                continue
            }
            
            
            let rangeOfPaddedURL = item.range( of: "<(.*)>;", options: .regularExpression )
            
            guard let range = rangeOfPaddedURL else {
                return nil
            }
            
            let nextURL = item.substring(with: range)
            
            let startIndex = nextURL.characters.index(nextURL.startIndex, offsetBy: 1)
            let endIndex = nextURL.characters.index(nextURL.endIndex, offsetBy: -2)
            let urlRange = startIndex..<endIndex
            return nextURL.substring(with: urlRange)
            
            
        } // end for
        
        return nil
        
    }  // end function
    
    
    

    
    // MARK: - OAuth flow
    func URLToStartOAuth2Login()->URL? {
        
        let authPath:String = "https://github.com/login/oauth/authorize" +
            "?client_id=\(clientID)&scope=gist&state=TEST_STATE"
        guard let authURL:URL = URL(string: authPath) else {
            // TODO: handle error
            return nil
        }
        
        return authURL
        
        
        
        
        
    }
    
    func extractCodeFromOAuthStep1Response(_ url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var code:String?
        guard let queryItems = components?.queryItems else {
            return nil
        }
        for queryItem in queryItems {
            if (queryItem.name.lowercased() == "code") {
                code = queryItem.value
                break
            }
        }
        return code
    }
    
    func parseOAuthTokenResponse(_ json: JSON) -> String? {
        
        print("parseOAuthTokenResponse: Started")
        
        
        var token: String?
        
        for (key, value) in json {
            switch key {
            case "access_token":
                token = value.string
            case "scope":
                // TODO: verify scope
                print("SET SCOPE")
            case "token_type":
                // TODO: verify is bearer
                print("CHECK IF BEARER")
            default:
                print("got more than I expected from the OAuth token exchange")
                print(key)
            }
        }
        
        print("parseOAuthTokenResponse: Returing token.")
        return token
    }
    
    func swapAuthCodeForToken(_ code: String) {
        print("swapAuthCodeForToken: starting ..")
        let getTokenPath:String = "https://github.com/login/oauth/access_token"
        let tokenParams = ["client_id": clientID,
                           "client_secret": clientSecret,
                           "code": code]
        let jsonHeader = ["Accept": "application/json"]
        Alamofire.request(.POST, getTokenPath, parameters: tokenParams,
            headers: jsonHeader)
            .responseString { response in
                guard response.result.error == nil,
                    let receivedResults = response.result.value else {
                        print(response.result.error!)
                        self.OAuthTokenCompletionHandler?(NSError(domain: GitHubAPIManager.ErrorDomain,
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey:
                                "Could not obtain an OAuth token",
                                NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"]))
                        self.isLoadingOAuthToken = false
                        return
                }
                
                // extract the token from the response
                guard let jsonData = receivedResults.data(using: String.Encoding.utf8,
                    allowLossyConversion: false) else {
                        print("no data received or data not JSON")
                        self.OAuthTokenCompletionHandler?(NSError(domain: GitHubAPIManager.ErrorDomain, code: -1,
                            userInfo: [NSLocalizedDescriptionKey:
                                "Could not obtain an OAuth token",
                                NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"]))
                        self.isLoadingOAuthToken = false
                        return
                }
                let jsonResults = JSON(data: jsonData)
                self.OAuthToken = self.parseOAuthTokenResponse(jsonResults)
                self.isLoadingOAuthToken = false
                
                if (self.hasOAuthToken()) {
                    self.OAuthTokenCompletionHandler?(nil)
                } else  {
                    self.OAuthTokenCompletionHandler?(NSError(domain: GitHubAPIManager.ErrorDomain,
                        code: -1, userInfo:
                        [NSLocalizedDescriptionKey: "Could not obtain an OAuth token",
                            NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"]))
                }
        }
    }
    
    func processOAuthStep1Response(_ url: URL) {
        
        
        print("processOAuthStep1Response: url value is " + String(describing: url))
        
        
        // extract the code from the URL
        guard let code = extractCodeFromOAuthStep1Response(url) else {
            self.isLoadingOAuthToken = false
            self.OAuthTokenCompletionHandler?(NSError(domain: GitHubAPIManager.ErrorDomain, code: -1,
                userInfo: [NSLocalizedDescriptionKey:
                    "Could not obtain an OAuth code",
                    NSLocalizedRecoverySuggestionErrorKey: "Please retry your request"]))
            return
        }
        
        print("processOAuthStep1Response: calling swapAuthCodeForToken")
        
        swapAuthCodeForToken(code)
 
 
    }   // end fucntion
    
   
    
    // MARK: Starring / Unstarring / Star status
    func isGistStarred(_ gistId: String, completionHandler: @escaping (Result<Bool>) -> Void) {
        // GET /gists/:id/star
        Alamofire.request(GistRouter.isStarred(gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                // 204 if starred, 404 if not
                if let error = error {
                    print(error)
                    if response?.statusCode == 404 {
                        completionHandler(.success(false))
                        return
                    }
                    completionHandler(.failure(error))
                    return
                }
                completionHandler(.success(true))
        }
    }
    
    func starGist(_ gistId: String, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(GistRouter.star(gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                guard error == nil else {
                    print(error)
                    return
                }
                completionHandler(error)
        }
    }
    
    func unstarGist(_ gistId: String, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(GistRouter.unstar(gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                guard error == nil else {
                    print(error)
                    return
                }
                completionHandler(error)
        }
    }
    
    

    // MARK: - Create / Delete Gists
    
    func deleteGist(_ gistId: String, completionHandler: @escaping (NSError?) -> Void) {
        Alamofire.request(GistRouter.delete(gistId))
            .response { (request, response, data, error) in
                if let urlResponse = response, let authError = self.checkUnauthorized(urlResponse) {
                    completionHandler(authError)
                    return
                }
                // error will be nil if the call succeeded
                self.clearCache()
                completionHandler(error)
        }
    }

    func createNewGist(_ description: String, isPublic: Bool, files: [File],  completionHandler: @escaping (Result<Bool>) -> Void) {
        let publicString: String
        if isPublic {
            publicString = "true"
        } else {
            publicString = "false"
        }
        
        var filesDictionary = [String: AnyObject]()
        for file in files {
            if let name = file.filename, let content = file.content {
                filesDictionary[name] = ["content": content]
            }
        }
        
        let parameters:[String: AnyObject] = [
            "description": description as AnyObject,
            "isPublic": publicString as AnyObject,
            "files" : filesDictionary as AnyObject
        ]
        
        Alamofire.request(GistRouter.create(parameters))
            .response { (request, response, data, error) in
                if let urlResponse = response, let authError = self.checkUnauthorized(urlResponse) {
                    completionHandler(.failure(authError))
                    return
                }
                guard error == nil else {
                    print(error)
                    completionHandler(.failure(error!))
                    return
                }
                self.clearCache()
                completionHandler(.success(true))
        }
    }
    
    
}   // end class
