
//  Created by Shebin Koshy on 2/18/22.
//  Copyright © 2022 Shebin Koshy. All rights reserved.


import Foundation

struct DirectiveData {
    var contentType: String
    var data: Data
}

class KRVoiceServiceClient : NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    let EVENTS_ENDPOINT: String = "\(UserDefaults.standard.value(forKey: settingsBaseUrlUserDefautlsKey)!)/tw/stt/v0/convert?language=en_us&sanitize=\(Settings().profanityFilter)"
    
//    let TIMEOUT = 3600 // 60 minutes per KR recommendation
    let BOUNDARY_TERM = "CUSTOM_BOUNDARY_TERM"
    
    var session: URLSession!
    
    override init() {
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 30.0
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        print("KR Session created")
    }
    
    func postRecording(audioData: Data, completion: @escaping (_ responseData:Any?) -> ()) {
        sendAudio(jsonData: nil, audioData: audioData, completion: completion)
    }
    
    private func sendAudio(jsonData: String?, audioData: Data, completion:@escaping (_ responseData:Any?) -> ()) {

        var request = URLRequest(url: URL(string: EVENTS_ENDPOINT)!)
        request.httpMethod = "POST"
        addAuthHeader(request: &request)
        addContentTypeHeader(request: &request)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        
        var bodyData = Data()
        bodyData.append(getBoundaryTermBegin())
        bodyData.append(addAudioData(audioData: audioData))
        bodyData.append(getBoundaryTermEnd())

        session.uploadTask(with: request, from: bodyData, completionHandler: { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if (error != nil) {
                completion(nil)
                print("Send audio error: \(String(describing: error?.localizedDescription))")
            } else {
                let res = response as! HTTPURLResponse
                print("Send audio status code: \(res.statusCode)")

                if (res.statusCode >= 200 && res.statusCode <= 299) {
                    
                    if let contentTypeHeader = res.allHeaderFields["Content-Type"], let nonNilData = data {
                        let json = try? JSONSerialization.jsonObject(with: nonNilData, options: .mutableContainers)
                        completion(json)
                        print("json\(json)")
                    } else {
                        print("Content type in response is empty")
                    }
                }
            }
        }).resume()
    }
    
    fileprivate func addAuthHeader(request: inout URLRequest) {
    }
    
    fileprivate func addContentTypeHeader(request: inout URLRequest) {
        request.addValue("multipart/form-data; boundary=\(BOUNDARY_TERM)", forHTTPHeaderField: "Content-Type")
    }
    
    fileprivate func addEventData(jsonData: String) -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"metadata\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/json; charset=UTF-8\r\n\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append(jsonData.data(using: String.Encoding.utf8)!)
        bodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }
    
    fileprivate func addAudioData(audioData: Data) -> Data {
        var bodyData = Data()
        bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"123.wav\"\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: String.Encoding.utf8)!)
        bodyData.append(audioData)
        bodyData.append("\r\n".data(using: String.Encoding.utf8)!)
        return bodyData
    }
    
    fileprivate func getBoundaryTermBegin() -> Data {
        return "--\(BOUNDARY_TERM)\r\n".data(using: String.Encoding.utf8)!
    }
    
    fileprivate func getBoundaryTermEnd() -> Data {
        return "--\(BOUNDARY_TERM)--\r\n".data(using: String.Encoding.utf8)!
    }
    
}
