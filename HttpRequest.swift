//
//  HttpRequest.swift
//
//
//  Created by Fenfan on 16/5/27.
//  Copyright (c) 2016年 梁雅軒. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class HttpRequest {
    
    private var mUrl:String!;
    private var mMethod:Method = Method.Post;
    private var mParams:Dictionary<String, AnyObject>!;
    private var hasFile = false;
    var progress:((Float) -> Void)?;
    
    enum DataType:String {
        case Image = "image/jpeg";
        case Sound = "audio/caf";
        case Video = "video/mov";
    }
    
    enum Method:String {
        case Get = "GET";
        case Post = "POST";
    }
    
    init(_ url:String, _ method:Method) {
        mUrl = String(url);
        mMethod = method;
        mParams = Dictionary<String, AnyObject>();
    }
    
    deinit {
        mUrl = nil;
        mParams = nil;
    }
    
    ///取得請求網址
    /// - Returns:String
    func getUrl() -> String {
        return mUrl;
    }
    
    ///添加值
    /// - Parameter value:String
    /// - Parameter key:關鍵字
    func addValue(key:String, _ value:String) {
        mParams[key] = value as AnyObject?;
    }
    
    ///添加值
    /// - Parameter value:Int
    /// - Parameter key:關鍵字
    func addValue(key:String, _ value:Int) {
        mParams[key] = value as AnyObject?;
    }
    
    ///添加值
    /// - Parameter value:Float字串
    /// - Parameter key:關鍵字
    func addValue(key:String, _ value:Float) {
        mParams[key] = value as AnyObject?;
    }
    
    ///添加值
    /// - Parameter value:Double
    /// - Parameter key:關鍵字
    func addValue(key:String, _ value:Double) {
        mParams[key] = value as AnyObject?;
    }
    
    ///添加陣列值
    /// - Parameter value:[String]
    /// - Parameter key:關鍵字
    func addValueArray(key:String, _ ary:Array<String>) {
        for i in 0 ..< ary.count {
            let keys = String(format: "%@[%d]", key, i);
            mParams[keys] = ary[i] as AnyObject?;
        }
    }
    
    ///添加檔案
    /// - Parameter dataType:檔案類型
    /// - Parameter key:關鍵字
    /// - Parameter fileData:檔案
    /// - Parameter fileName:檔案名稱
    func addData(key:String, dataType:DataType, fileData:Data, fileName:String) {
        let opt = Upload();
        opt.fileData = fileData;
        opt.fileName = fileName;
        opt.mimeType = dataType.rawValue;
        mParams[key] = opt;
        hasFile = true;
    }
    
    ///添加檔案路徑
    /// - Parameter dataType:檔案類型
    /// - Parameter key:關鍵字
    /// - Parameter fileUrl:檔案路徑
    /// - Parameter fileName:檔案名稱
    func addFileUrl(key:String, dataType:DataType, fileUrl:URL, fileName:String) {
        let opt = Upload();
        opt.fileUrl = fileUrl;
        opt.fileName = fileName;
        opt.mimeType = dataType.rawValue;
        mParams[key] = opt;
        hasFile = true;
    }
    
    func startSynchronous(response:@escaping ((String?) -> Void)) {
        if (mMethod == Method.Get) {
            getRequest(params: mParams, url: mUrl, response: response)
        }
        else {
            
            if (hasFile) {
                upload(params: mParams, url: mUrl, response: response, progress: progress)
            }
            else {
                postRequest(params: mParams, url: mUrl, response: response)
            }
        }
    }
    
    private func postRequest(params:[String:AnyObject],url:String,response:@escaping ((String?) -> Void))  {
        Alamofire.request(url, method: .post ,parameters:params).response { (mResponse) in
            if let data = mResponse.data, let utf8Text = String(data: data, encoding: .utf8) {
                response(utf8Text)
            }else{
                response("")
            }
        }
        
    }
    
    private func getRequest(params:[String:AnyObject],url:String,response:@escaping ((String?) -> Void)) {
        Alamofire.request(url, method: .get ,parameters:params).response { (mResponse) in
            if let data = mResponse.data, let utf8Text = String(data: data, encoding: .utf8) {
                response(utf8Text)
            }
        }
    }
    
    private func upload(params:[String:AnyObject],url:String,response:@escaping ((String?) -> Void),progress:((Float) -> Void)?) {
        
        let setEncodingCompletion = {(encodingResult:SessionManager.MultipartFormDataEncodingResult) -> Void in
            switch (encodingResult) {
                
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (mResponse) in
                    if let data = mResponse.data, let utf8Text = String(data: data, encoding: .utf8) {
                        response(utf8Text)
                    }else{
                        response("")
                    }
                })
            case .failure(_):
                response(nil)
            }
        }
        
        let setMultipartformdata = { (multipartFormData:MultipartFormData) -> Void in
            for (key,value) in params {
                
                if (value is Upload){
                    let info = value as! Upload;
                    if let data = info.fileData {
                        
                        multipartFormData.append(data, withName: key, fileName: info.fileName, mimeType: info.mimeType)
                    }
                    else if let fileUrl = info.fileUrl {
                        
                        multipartFormData.append(fileUrl, withName: key, fileName: info.fileName, mimeType: info.mimeType)
                    }
                }
                else if (value is String) {
                    let str = value as! String;
                    multipartFormData.append(str.data(using: String.Encoding.utf8)!, withName: key)
                }
            }
        }
        
        Alamofire.upload(multipartFormData: setMultipartformdata, to: url, encodingCompletion: setEncodingCompletion)
    }
}

private class Upload:NSObject {
    var fileData:Data?;
    var fileName:String!;
    var mimeType:String!;
    var fileUrl:URL?;
    
    deinit {
        fileData = nil;
        fileName = nil;
        mimeType = nil;
        fileUrl = nil;
    }
}
