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
    //키를 사용하여 해당 셀 데이터 삭제
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var key : String?
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoNotCompleted", for: indexPath)
            let list = todoNotCompleted[indexPath.row]
            key = "delete/" + String(list.todo_no!)
            //cell.textLabel?.text = list.todo
            //cell.imageView?.image = UIImage(named: "NotCompleted")
            //TodoNotCompleted 이라는 이름의 셀을 얻어와서 내용을 입력해주고 리턴
            return
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCompleted", for: indexPath)
            let list = todoCompleted[indexPath.row]
            key = "delete/" + String(list.todo_no!)
            //cell.textLabel?.text = list.todo
            //cell.imageView?.image = UIImage(named: "Completed")
            //cell.textLabel?.textColor = UIColor.gray
            return
        }
        
        
        
        
        //delete 버튼 눌렀을때 데이터 삭제 (인증이 되있다면 삭제, 그렇지 않으면 에러메세지출력)
        print("delete key :", key)
//        ref.child(key).removeValue{(error: Error?, ref) in
//            guard error == nil else {
//                let dialog = UIAlertController(title: "에러", message: error!.localizedDescription, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
//                dialog.addAction(okAction)
//                self.present(dialog,animated: true, completion: nil)
//                return
//            }
//            print("delete success")
//            self.resolveMovies()
//        }
    }
    
    
    func deleteTodo() {
        
    }
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
