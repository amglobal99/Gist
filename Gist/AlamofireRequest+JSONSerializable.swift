//
//  AlamofireRequest+JSONSerializable.swift
//  Gist


import Alamofire
import SwiftyJSON


extension Alamofire.Request {
    
    public func responseObject<T: ResponseJSONObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<T, NSError>        { request, response, data, error in
                
                guard error == nil else {
                    return .Failure(error!)
                }
                
                guard let responseData = data else {
                    let failureReason = "Array could not be serialized because input data was nil."
                    let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                    return .Failure(error)
                }
                
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
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
                    case .Failure(let error):
                        return .Failure(error)
                    case .Success(let value):
                        let json = SwiftyJSON.JSON(value)
                    
                        if let errorMessage = json["message"].string {
                            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: errorMessage)
                            return .Failure(error)
                        }
                        
                        guard let object = T(json: json) else {
                            let failureReason = "Object could not be created"
                            let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                            return .Failure(error)
                        }
                        
                        return .Success(object)
                    
                }  // end switch
                
        }  //end closure
        
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
        
  }  //end function
    
    
    public func responseArray<T: ResponseJSONObjectSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<[T], NSError>
            { request, response, data, error in
                    guard error == nil else {
                        return .Failure(error!)
                    }
            
                    guard let responseData = data else {
                        let failureReason = "Array could not be serialized because input data was nil."
                        let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                        return .Failure(error)
                    }
            
                let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
                let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
                switch result {
                case .Failure(let error):
                    return .Failure(error)
                case .Success(let value):
                    let json = SwiftyJSON.JSON(value)
                    if let errorMessage = json["message"].string {
                            let error = Error.errorWithCode(.DataSerializationFailed, failureReason: errorMessage)
                            return .Failure(error)
                    }
                    
                    var objects: [T] = []
                    for (_, item) in json {
                        if let object = T(json: item) {
                            objects.append(object)
                        }
                    }  // end for loop
                    
                    return .Success(objects)
                } // end switch
           } // end closure
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    
    }  //end func

    
}  // end extension