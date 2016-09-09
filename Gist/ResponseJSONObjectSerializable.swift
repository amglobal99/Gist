//
//  ResponseJSONObjectSerializable.swift
//  Gist
//
//  Created by Dad on 6/21/16.
//  Copyright © 2016 Natsys. All rights reserved.
//

import Foundation
import SwiftyJSON


public protocol ResponseJSONObjectSerializable {
    
    init?(json: SwiftyJSON.JSON)
    
}