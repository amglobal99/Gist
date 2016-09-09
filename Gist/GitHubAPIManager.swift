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
    var OAuthTokenCompletionHandler:(NSError? -> Void)?
    
    
    
    var OAuthToken: String? {
        set {
            guard let newValue = newValue else {
                let _ = try? Locksmith.deleteDataForUserAccount("github")
                return
            }
            
            guard let _ = try? Locksmith.updateData(["token": newValue], forUserAccount: "github") else {
                let _ = try? Locksmith.deleteDataForUserAccount("github")
                return
            }
        }
        get {
            // try to load from keychain
            Locksmith.loadDataForUserAccount("github")
            let dictionary = Locksmith.loadDataForUserAccount("github")
            return dictionary?["token"] as? String
        }
    }


    
    
    //MARK: - Supporting Functions
    
    func clearCache()-> Void  {
        let cache = NSURLCache.sharedURLCache()
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
    
    func checkUnauthorized(urlResponse: NSHTTPURLResponse) -> (NSError?) {
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
    
    func fetchGists(urlRequest: URLRequestConvertible, completionHandler:  (Result<[Gist], NSError>, String?) -> Void) {
        
        Alamofire.request(urlRequest)
            .responseArray { (response:Response<[Gist], NSError>) in
                if let urlResponse = response.response,
                    authError = self.checkUnauthorized(urlResponse) {   // checkUnauthorized returns NSError if error present
                    completionHandler(.Failure(authError), nil)
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
    
    func fetchPublicGists(pageToLoad: String?, completionHandler:   (Result<[Gist], NSError>, String?) -> Void   ) {
        
        if let urlString = pageToLoad {
            fetchGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.GetPublic(), completionHandler: completionHandler)
        }
    }
    
    
    func fetchMyStarredGists(pageToLoad: String?, completionHandler:   (Result<[Gist], NSError>, String?) -> Void) {
        if let urlString = pageToLoad {
            fetchGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.GetMyStarred(), completionHandler: completionHandler)
        }
    }
    
    func fetchMyGists(pageToLoad: String?, completionHandler:   (Result<[Gist], NSError>, String?) -> Void) {
        if let urlString = pageToLoad {
            fetchGists(GistRouter.GetAtPath(urlString), completionHandler: completionHandler)
        } else {
            fetchGists(GistRouter.GetMine(), completionHandler: completionHandler)
        }
    }
    
    func imageFromURLString(imageURLString: String, completionHandler: (UIImage?,NSError?)-> Void ) {
        
        
        print("Getting image from URl : " + imageURLString)
        
        
        Alamofire.request(.GET, imageURLString).response {  (request,response,data,error) in
                
                
              //guard error  != nil else {
                guard error == nil else {
                print(error)
                print("An error occurred while getting Image")
                return
            }
 
                
            
            let image = UIImage(data: data! as NSData)
            completionHandler(image, nil)
            
        }  //end closure
        
        
    }  //end fucntion
    
    
    
    

    //MARK: - OAuth 2.0
    func printMyStarredGistsWithOAuth2() -> Void {
        
        print("printMyStarredGistsWithOAuth2: Starting....")
        
        let alamofireRequest = Alamofire.request(GistRouter.GetMyStarred())
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
    private func parseNextPageFromHeaders(response: NSHTTPURLResponse?) -> String?   {
        
        guard let linkHeader = response?.allHeaderFields["Link"] as? String else {
            return nil
        }
        
        let components = linkHeader.characters.split {$0 == ","}.map  {String($0) }
        for item in components {
            let rangeOfNext = item.rangeOfString("rel=\"next\"", options: [])
            guard rangeOfNext != nil else {
                continue
            }
            
            
            let rangeOfPaddedURL = item.rangeOfString( "<(.*)>;", options: .RegularExpressionSearch )
            
            guard let range = rangeOfPaddedURL else {
                return nil
            }
            
            let nextURL = item.substringWithRange(range)
            
            let startIndex = nextURL.startIndex.advancedBy(1)
            let endIndex = nextURL.endIndex.advancedBy(-2)
            let urlRange = startIndex..<endIndex
            return nextURL.substringWithRange(urlRange)
            
            
        } // end for
        
        return nil
        
    }  // end function
    
    
    

    
    // MARK: - OAuth flow
    func URLToStartOAuth2Login()->NSURL? {
        
        let authPath:String = "https://github.com/login/oauth/authorize" +
            "?client_id=\(clientID)&scope=gist&state=TEST_STATE"
        guard let authURL:NSURL = NSURL(string: authPath) else {
            // TODO: handle error
            return nil
        }
        
        return authURL
        
        
        
        
        
    }
    
    func extractCodeFromOAuthStep1Response(url: NSURL) -> String? {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code:String?
        guard let queryItems = components?.queryItems else {
            return nil
        }
        for queryItem in queryItems {
            if (queryItem.name.lowercaseString == "code") {
                code = queryItem.value
                break
            }
        }
        return code
    }
    
    func parseOAuthTokenResponse(json: JSON) -> String? {
        
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
    
    func swapAuthCodeForToken(code: String) {
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
                guard let jsonData = receivedResults.dataUsingEncoding(NSUTF8StringEncoding,
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
    
    func processOAuthStep1Response(url: NSURL) {
        
        
        print("processOAuthStep1Response: url value is " + String(url))
        
        
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
    func isGistStarred(gistId: String, completionHandler: Result<Bool, NSError> -> Void) {
        // GET /gists/:id/star
        Alamofire.request(GistRouter.IsStarred(gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                // 204 if starred, 404 if not
                if let error = error {
                    print(error)
                    if response?.statusCode == 404 {
                        completionHandler(.Success(false))
                        return
                    }
                    completionHandler(.Failure(error))
                    return
                }
                completionHandler(.Success(true))
        }
    }
    
    func starGist(gistId: String, completionHandler: (NSError?) -> Void) {
        Alamofire.request(GistRouter.Star(gistId))
            .validate(statusCode: [204])
            .response { (request, response, data, error) in
                guard error == nil else {
                    print(error)
                    return
                }
                completionHandler(error)
        }
    }
    
    func unstarGist(gistId: String, completionHandler: (NSError?) -> Void) {
        Alamofire.request(GistRouter.Unstar(gistId))
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
    
    func deleteGist(gistId: String, completionHandler: (NSError?) -> Void) {
        Alamofire.request(GistRouter.Delete(gistId))
            .response { (request, response, data, error) in
                if let urlResponse = response, authError = self.checkUnauthorized(urlResponse) {
                    completionHandler(authError)
                    return
                }
                // error will be nil if the call succeeded
                self.clearCache()
                completionHandler(error)
        }
    }

    func createNewGist(description: String, isPublic: Bool, files: [File],  completionHandler: (Result<Bool, NSError>) -> Void) {
        let publicString: String
        if isPublic {
            publicString = "true"
        } else {
            publicString = "false"
        }
        
        var filesDictionary = [String: AnyObject]()
        for file in files {
            if let name = file.filename, content = file.content {
                filesDictionary[name] = ["content": content]
            }
        }
        
        let parameters:[String: AnyObject] = [
            "description": description,
            "isPublic": publicString,
            "files" : filesDictionary
        ]
        
        Alamofire.request(GistRouter.Create(parameters))
            .response { (request, response, data, error) in
                if let urlResponse = response, authError = self.checkUnauthorized(urlResponse) {
                    completionHandler(.Failure(authError))
                    return
                }
                guard error == nil else {
                    print(error)
                    completionHandler(.Failure(error!))
                    return
                }
                self.clearCache()
                completionHandler(.Success(true))
        }
    }
    
    
}   // end class