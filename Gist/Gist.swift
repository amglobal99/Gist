//
//  Gist.swift

import Foundation
import SwiftyJSON

class Gist: ResponseJSONObjectSerializable {
    var id: String?
    var description: String?
    var ownerLogin: String?
    var ownerAvatarURL: String?
    var url: String?
    var files:[File]?
    var createdAt:Date?
    var updatedAt:Date?
    
    static let sharedDateFormatter = Gist.dateFormatter()
    
    
    // init for JSON
    required init(json: JSON) {
            self.description = json["description"].string
            self.id = json["id"].string
            self.ownerLogin = json["owner"]["login"].string
            self.ownerAvatarURL = json["owner"]["avatar_url"].string
            self.url = json["url"].string
            
            // files
            self.files = [File]()
            if let filesJSON = json["files"].dictionary {
                for (_, fileJSON) in filesJSON {
                    if let newFile = File(json: fileJSON) {
                        self.files?.append(newFile)
                    } // end if
                } // end for
            }  // end if
            
            
            // Dates
            let dateFormatter = Gist.sharedDateFormatter
            if let dateString = json["created_at"].string {
                self.createdAt = dateFormatter.date(from: dateString)
            }
            if let dateString = json["updated_at"].string {
                self.updatedAt = dateFormatter.date(from: dateString)
            } //end if
            
    } //end init
    
    
    
    required init() {
    }
    
    
    
    
    convenience init(json: [String:Any] ) {
        self.description = json["description"] as? String
        self.id = json["id"] as? String
        //self.ownerLogin = json["owner"]?["login"]? as? String
        //self.ownerAvatarURL = json["owner"]["avatar_url"] as? String
        
        
         ///**************  These adde by JP ******************
        var ownerLogin = json["owner"] as? [String:Any]
        self.ownerLogin = ownerLogin?["login"] as? String
        self.ownerAvatarURL = ownerLogin?["avatar_url"] as? String
        
        
        self.url = json["url"] as? String
        
        // files
        self.files = [File]()
        if let filesJSON = json["files"].dictionary {
            for (_, fileJSON) in filesJSON {
                if let newFile = File(json: fileJSON) {
                    self.files?.append(newFile)
                } // end if
            } // end for
        }  // end if
        
        
        
        
        // Dates
        let dateFormatter = Gist.sharedDateFormatter
        if let dateString = json["created_at"].string {
            self.createdAt = dateFormatter.date(from: dateString)
        }
        if let dateString = json["updated_at"].string {
            self.updatedAt = dateFormatter.date(from: dateString)
        } //end if
        
    } //end init
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    class func dateFormatter() -> DateFormatter {
        let aDateFormatter = DateFormatter()
        aDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        aDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        aDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return aDateFormatter
    } // end funtion
    
    
    
} // end class
