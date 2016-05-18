//
//  MediaAPIManager.swift
//  Marvel
//
//  Created by Gabriel Massana on 18/5/16.
//  Copyright © 2016 Gabriel Massana. All rights reserved.
//

import UIKit

import CoreNetworking

enum MediaAspectRatio: String {
    
    case Portrait = "portrait_incredible"
}

class MediaAPIManager: NSObject {

    /**
     Retrieves a media asset from Marvel service.
     
     - parameter mediaAspectRatio: desired Media Aspect Ratio for the media asset to be downloaded.
     - parameter comic: Comic object with the information to retrieve the media asset.
     - parameter completion: completion callback returning media asset and Comic object.
     */
    class func retrieveMediaAsset(mediaAspectRatio: MediaAspectRatio, comic: Comic, completion:((imageComic: Comic, mediaImage: UIImage?) -> Void)?) {
        
        let cacheDirectory: String = NSFileManager.cfm_cacheDirectoryPath()
        let absolutePath: String = cacheDirectory.stringByAppendingString(String(format: "/%@_%@", comic.comicID!, mediaAspectRatio.rawValue))
        
        NSFileManager.cfm_fileExistsAtPath(absolutePath) { (fileExists: Bool) -> Void in
            
            if fileExists {
                
                let documentName: String = String(format: "%@_%@", comic.comicID!, mediaAspectRatio.rawValue)
                
                let imageData = NSFileManager.cfm_retrieveDataFromCacheDirectoryWithPath(documentName)
                
                if var _ = imageData {
                    
                    let image: UIImage = UIImage(data: imageData)!
                    
                    if let _ = completion {
                        
                        completion!(imageComic: comic, mediaImage: image)
                    }
                }
                else
                {
                    if let _ = completion {
                        
                        completion!(imageComic: comic, mediaImage: nil)
                    }
                }
            }
            else
            {
                if let thumbnailPath = comic.thumbnailPath {
                    
                    if let thumbnailExtension = comic.thumbnailExtension {
                        
                        let urlString: String = String(format: "%@/%@.%@", thumbnailPath, mediaAspectRatio.rawValue, thumbnailExtension)
                        
                        //TODO create request
                        let request: Request = Request.requestForAPI()
                        request.URL = NSURL(string: urlString)
                        
                        let task: CNMURLSessionDataTask = CNMSession.defaultSession().dataTaskFromRequest(request)
                        
                        task.onCompletion = { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                            
                            if (data != nil) {
                                
                                let image: UIImage = UIImage(data: data!)!
                                
                                if let _ = completion {
                                    
                                    completion!(imageComic: comic, mediaImage: image)
                                }
                                
                                let documentName: String = String(format: "%@_%@", comic.comicID!, mediaAspectRatio.rawValue)
                                
                                NSFileManager.cfm_saveData(data, toCacheDirectoryPath: documentName)
                            }
                            else
                            {
                                if let _ = completion {
                                    
                                    completion!(imageComic: comic, mediaImage: nil)
                                }
                            }
                        }
                        
                        task.resume()
                    }
                }
            }
        }
    }
}
