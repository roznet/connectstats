//
//  RZSRemoteURLFindValid.swift
//  RZUtilsSwift
//
//  Created by Brice Rosenzweig on 13/08/2017.
//  Copyright © 2017 Brice Rosenzweig. All rights reserved.
//

import Foundation
import RZUtils

public typealias RZRemoteDownloadCompleteHandler = (String?) -> ();

@objc public class RZSRemoteURLFindValid : NSObject, RZRemoteDownloadDelegate {
    
    
    let searchURLs : [String]
    
    var completion : RZRemoteDownloadCompleteHandler?
    var found : String?
    var current : Int
    
    @objc public init( urls: [String]){
        searchURLs = urls
        current = 0
    }
    
    @objc public func search(_ complete:RZRemoteDownloadCompleteHandler?) {
        completion = complete
        next();
    }
    
    func next(){
        if(current < searchURLs.count){
            let _ = RZRemoteDownload(url: searchURLs[current], andDelegate: self)
        }else{
            done()
        }
    }

    
    func done(){
        completion?(found)
        completion = nil
    }
    func invalid(){
        current+=1
        next()
    }
    
    public func downloadFailed(_ connection: RZRemoteDownload!) {
        invalid()
    }
    
    public func downloadArraySuccessful(_ connection: RZRemoteDownload!, array theArray: [Any]!) {
        invalid()
    }
    
    public func downloadStringSuccessful(_ connection: RZRemoteDownload!, string theString: String!) {
        let d = Int(theString)
        if( d != nil){
            found = searchURLs[current];
            done()
        }else{
            invalid()
        }
    }
}
