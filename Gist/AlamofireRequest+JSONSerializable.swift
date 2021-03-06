//
//  AlamofireRequest+JSONSerializable.swift
//  Gist


import Alamofire
import SwiftyJSON


extension Alamofire.Request {
    
    public func responseObject<T: ResponseJSONObjectSerializable>(_ completionHandler: (Response<T, NSError>) -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<T, NSError>        { request, response, data, error in
                
                guard error == nil else {
                    return .failure(error!)
                }
                
                guard let responseData = data else {
                    let failureReason = "Array could not be serialized because input data was nil."
                    let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: failureReason)
                    return .failure(error)
                }
                
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .allowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
                
                /*
                
                if result.isSuccess {
                    if let value = result.value {
                        let json = SwiftyJSON.JSON(value)
                        if let newObject = T(json: json) {
                            return .Success(newObject)
                        }
                    }
                } // end if
                
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: "JSON could not be converted to object")
                return .Failure(error)
        
        
                */
                
                
                switch result {
                    case .failure(let error):
                        return .failure(error)
                    case .success(let value):
                        let json = SwiftyJSON.JSON(value)
                    
                        if let errorMessage = json["message"].string {
                            let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: errorMessage)
                            return .failure(error)
                        }
                        
                        guard let object = T(json: json) else {
                            let failureReason = "Object could not be created"
                            let error = Alamofire.Error.errorWithCode(.jsonSerializationFailed, failureReason: failureReason)
                            return .failure(error)
                        }
                        
                        return .success(object)
                    
                }  // end switch
                
        }  //end closure
        
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
        
  }  //end function
    
    
    public func responseArray<T: ResponseJSONObjectSerializable>(_ completionHandler: (Response<[T], NSError>) -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<[T], NSError>
            { request, response, data, error in
                    guard error == nil else {
                        return .failure(error!)
                    }
            
                    guard let responseData = data else {
                        let failureReason = "Array could not be serialized because input data was nil."
                        let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: failureReason)
                        return .failure(error)
                    }
            
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .allowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
                switch result {
                case .failure(let error):
                    return .failure(error)
                case .success(let value):
                    let json = SwiftyJSON.JSON(value)
                    if let errorMessage = json["message"].string {
                            let error = Alamofire.Error.errorWithCode(.dataSerializationFailed, failureReason: errorMessage)
                            return .failure(error)
                    }
                    
                    var objects: [T] = []
                    for (_, item) in json {
                        if let object = T(json: item) {
                            objects.append(object)
                        }
                    }  // end for loop
                    
                    return .success(objects)
                } // end switch
           } // end closure
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    
    }  //end func

    
}  // end extension
