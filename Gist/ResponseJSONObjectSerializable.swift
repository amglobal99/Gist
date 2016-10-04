//
//  ResponseJSONObjectSerializable.swift
//  Gist
//


import Foundation
import SwiftyJSON


public protocol ResponseJSONObjectSerializable {
    
    init?(json: SwiftyJSON.JSON)
    
}
