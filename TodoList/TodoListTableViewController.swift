//
//  TodoListTableViewController.swift
//  TodoList
//
//  Created by 조서현 on 2019. 2. 11..
//  Copyright © 2019년 조서현. All rights reserved.
//

import UIKit
import Alamofire



struct Todo : Codable {
    var todo_no: Int?
    var id_no: Int?
    var todo: String?
    var iscompleted: Bool?
}

struct TodoList : Codable {
    var todos : [Todo]
}


class TodoListTableViewController: UITableViewController {
    //Data.swift 파일의 UrlData 클래스의 url변수 가져옴
    let url = UrlData().url
    
    var todolist : [Todo] = []
    
    //Tableview에서 두개의 Section으로 구분해서 사용하기 위한 용도
    var todoCompleted : [Todo] = []
    var todoNotCompleted : [Todo] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //navigationBar 색 변경
        self.navigationController?.navigationBar.tintColor = UIColor(red: 255/255, green: 158/255, blue: 2/255, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        LoadTodoList()
    }
    
    
    //데이터 가져오기
    func LoadTodoList() {
        //예전에 가져왔던 데이터를 모두 지우고 다시 가져와야지 쌓이지 않음
        self.todolist.removeAll()
        self.todoCompleted.removeAll()
        self.todoNotCompleted.removeAll()
        
        Alamofire.request(url+"getAllTodo", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON() {
            response in
            print(response.result.value!)
            print("-------------------------------")
            
            //JSONDecoder 객체 생성
            //JSONDecoder의 decode메소드를 사용하여 data->인스턴스
            let decoder = JSONDecoder()
            
            //json을 data로 변환
            let data: Data? = response.data
            
            
            //Decode할 타입은 Decodable을 준수해야한다. Todo를 Json타입으로 만들고싶기 때문에 Todo.self 넣어줌
            //jsonserializtion을 사용해서 Foundation객체 만들고 Dictionary로 해당 key값 불러와, 인스턴스 프로퍼티에 대입하던 과정을 try? decoder.decode(TodoList.self, from:data) 한줄로 생략가능
            if let data = data, let myTodo = try? decoder.decode(TodoList.self, from: data) {
                var newTodo = Todo()
                for todo in myTodo.todos {
                    newTodo.id_no = todo.id_no!
                    newTodo.todo_no = todo.todo_no!
                    newTodo.todo = todo.todo!
                    newTodo.iscompleted = todo.iscompleted!
                    self.todolist.append(newTodo)
                    print(self.todolist.count)
                }
                //비동기방식으로 데이터를 가져오는 시점이테이블을 가져오고 난 시점일 수 있으므로 가져와서 반영하는 과정이 필요
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {  //테이블 섹션 개수 결정
        return 2 //섹션 2개 지정
    }
    
    
    //섹션 내에 몇개의 row가 있는지 count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var completed : Int = 0
        var notcompleted : Int = 0
        
        //count 후 iscompleted의 값에 따라 section 구분
        for list in todolist {
            if list.iscompleted == true {
                completed += 1
                self.todoCompleted.append(list)
            } else {
                notcompleted += 1
                self.todoNotCompleted.append(list)
            }
        }
        
        //총 row 개수 return
        if section == 0{
            return notcompleted
        }
        else {
            return completed
        }
    }
    
    
    //테이블뷰에 이미지 넣어서 데이터 불러오기
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoNotCompleted", for: indexPath)
            let list = todoNotCompleted[indexPath.row]
            cell.textLabel?.text = list.todo
            cell.imageView?.image = UIImage(named: "NotCompleted")
            //TodoNotCompleted 이라는 이름의 셀을 얻어와서 내용을 입력해주고 리턴
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCompleted", for: indexPath)
            let list = todoCompleted[indexPath.row]
            cell.textLabel?.text = list.todo
            cell.imageView?.image = UIImage(named: "Completed")
            cell.textLabel?.textColor = UIColor.gray
            return cell
        }
    }
    
    
    //셀 클릭 시 해당 데이터 출력
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //셀을 눌러서 선택하면 alert창에 나오는 textfield를 사용하여 수정
        //textfield에는 선택 셀의 todo 내용이 표시
        //수정 후 OK -> alamofire .post 수정내용 전송 후 success 확인 시 & LoadTodoList() 새로 호출
        //Cancle -> 수정없음
        var selectData : String?
        if indexPath.section == 0 {
            selectData = todoNotCompleted[indexPath.row].todo!
        } else {
            selectData = todoCompleted[indexPath.row].todo!
        }
        
        let dialog = UIAlertController(title: "SelectCell", message: selectData, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        dialog.addAction(okAction)
        self.present(dialog,animated: true, completion: nil)
    }
    
    
    //데이터를 삭제하기위한 함수 - 오른쪽에서 왼쪽으로 스와이프했을때 delete버튼 생성
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var key : Int?
        
        print("Section : \(indexPath.section)")
        //선택한 섹션의 종류에 따라 구분하여 todo_no를 가져와 delete를 위한 key를 만들어줌
        if indexPath.section == 0 {
            let list = todoNotCompleted[indexPath.row]
            key =  list.todo_no
        }
        else {
            let list = todoCompleted[indexPath.row]
            key = list.todo_no
        }
        print("Key : \(key!)")
        
        deleteTodo(key!)
        
    }
    
    //키를 사용하여 해당 셀 데이터 삭제
    func deleteTodo(_ key : Int) {
        struct Success : Codable {
            var result : Int?
        }
        
        //alamofire를 사용하여 url/delete/todo_no를 전송하여 결과값 받음
            Alamofire.request(url + "deleteTodo/\(key)", method: .get, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                print("Response Result : \(response.result.value!)")
                let decoder = JSONDecoder()
                let data: Data? = response.data
                if let data = data, let issuccess = try? decoder.decode(Success.self, from: data) {
                    
                    //서버 과부하를 방지하기위해 todolist에서 삭제하고자 하는 todo_no와 일치하는 데이터를 찾아 remove한다.
                    if issuccess.result == 1 {
                        var i : Int = 0
                        for todo in self.todolist {
                            if todo.todo_no == key {
                                self.todolist.remove(at: i)
                                break
                            } else {
                                i += 1
                            }
                        }
                        
                        //todoCompleted와 todoNotCompleted를 removeAll후 reloadData를 하면 삭제 후의 나머지 데이터를 다시 가져와 반영한다.
                        self.todoCompleted.removeAll()
                        self.todoNotCompleted.removeAll()
                        self.tableView.reloadData()
                    }
                    else {
                        print("DeleteFail")
                    }
                }
            }
    }
    
    
    
   
    @IBOutlet weak var AddText: UITextField!
    
    //Todo 추가하기
    @IBAction func AddTodo(_ sender: Any) {
        struct Success : Codable {
            var result : Int?
        }
        
        if let newTodo = AddText.text {
            let params : Parameters = ["todo" : newTodo]
            
            Alamofire.request(url+"addTodo", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
                
                let decoder = JSONDecoder()
                let data: Data? = response.data
                if let data = data, let issuccess = try? decoder.decode(Success.self, from: data) {
                    
                    //추가 성공시, 서버에서 생성해주는 todo_no와 id, isCompleted를 다시 받아와야한다.
                    if issuccess.result == 1 {
                        self.LoadTodoList()
                        self.AddText.text = ""
                    }
                    else {
                        print("AddFail")
                    }
                }
            }
        }
    }
    
    
    @IBOutlet weak var AddBtn: UIButton!
    
    @IBAction func AddTouchDown(_ sender: Any) {
        AddBtn.tintColor = UIColor(red: 255/255, green: 158/255, blue: 2/255, alpha: 1.0)
    }
    
    @IBAction func AddTouchUpInside(_ sender: Any) {
        AddBtn.tintColor = UIColor(red: 255/255, green: 213/255, blue: 80/255, alpha: 1.0)
    }
    
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
