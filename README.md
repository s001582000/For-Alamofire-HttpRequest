Alamofire 的抽象層

其用法

一般的post 跟 get

let request = HttpRequest("target url", .Post)  //或者.Get
    request.startSynchronous { (response) in
         print(response!)//回應 失敗則空字串
    }
    
帶參數

let request = HttpRequest("target url", .Post) //或者.Get
    request.addValue(key: "userId", "ggrrr")
    request.addValue(key: "pw", "qqccc")
    request.startSynchronous { (response) in
         print(response!)//回應 失敗則空字串
    }

有data

let request = HttpRequest("target url", .Post) //或者.Get
    request.addValue(key: "userId", "57f4a0e62997d5056a92c3b6")
    request.addData(key: "photo", dataType: .Image, fileData: imageData, fileName: "imageData")
    request.startSynchronous { (response) in
        print(response!)//回應 失敗則空字串
    }
