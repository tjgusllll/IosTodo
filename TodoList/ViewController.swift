//
//  ViewController.swift
//  TodoList
//
//  Created by 조서현 on 2019. 2. 7..
//  Copyright © 2019년 조서현. All rights reserved.
//

import UIKit
import Alamofire



struct Login {
    var isLogined: Bool?
}

 var log = Login()
class ViewController: UIViewController {
   
    let url = UrlData().url
    
    @IBOutlet weak var IdText: UITextField!
    @IBOutlet weak var PwText: UITextField!
    @IBOutlet weak var LoginBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginBtn.layer.cornerRadius = 10
    }

    
    func LoginCheck (_ param : Parameters) {
        print("----------LoginCheck func----------")
        
        let params = param
        
        
        Alamofire.request(url+"login", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            print("Success : \(response.result.isSuccess)")
            print("Response JSON : \(response.result.value!)")
            
            let jsdata:Data? = response.data
            
            if let data = jsdata {
                //json 데이터를 [String:Any] 형태의 Dictionary로 타입캐스팅을 해준다.
                //이떄, Dictionary의 key와 vlaue의 자료형은 파싱할 json 데이터의 형식과 같아야한다.
                var dataDicT:[String:Any]?
                //JSONSerializtion은 파라미터로 data를 받으므로 response.data를 jsdata라는 Data타입의 변수에 담아 넣어주었다.
                dataDicT = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                
                if let dataDic = dataDicT {
                    //key의 이름이 isLogined인 데이터의 value를 isLogined에 담아준다.
                    if let isLogined = dataDic["isLogined"]
                        {
                        print(">>>>dataDic<<<<")
                        print("isLogined: \(isLogined)")
                        
                        
                        let logLogined:Bool = isLogined as! Bool
                        
                        log.isLogined = logLogined
                        
                        print(">>>>isLogined Compare<<<<")
                        if log.isLogined! {
                            print("Login Success!")
                            
                            self.performSegue(withIdentifier: "todolistSegue", sender: self)
                            
                        } else {
                            print("Login Fail!")
                            let dialog = UIAlertController(title: "LoginCheck!", message: "ID또는 PW를 확인해주세요", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            dialog.addAction(okAction)
                            self.present(dialog,animated: true, completion: nil)
                        }
                        
                    }
                }
            }
        }
    }
    
    
    @IBAction func Login(_ sender: Any) {
        print("----------LoginButton Action----------")
        if let id = IdText.text,
            let pw = PwText.text {
            
            let params: Parameters = ["id":id, "pw":pw ]
            LoginCheck(params)
          
        }else {print("id/pw is nil")}
        
    }
    
    
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "todolistSegue") {
//            _ = segue.destination as! TodoListTableViewController
//        }
//        print("**GoTo TodoListTableViewController**")
//    }
    
}

