//
//  usersViewController.swift
//  lalzumayaApp
//
//  Created by Lujain Z on 20/07/2021.
//

import UIKit
import SQLite3

class usersViewController: UIViewController {
    
    @IBOutlet weak var usersTableView: UITableView!
    var UsersArray = [Datum]()
    
    var db: OpaquePointer?
    
    let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usersTableView.delegate = self
        self.usersTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readUsers()
    }
    
    func readUsers(){
        
        let url = "https://gorest.co.in/public-api/users"
        guard let url = URL(string: url) else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async{
                if  error != nil {
                    print("Error: \(String(describing: error))")
                }
                else if let data = data {
                    do{
                        let decoder = JSONDecoder()
                        do {
                            let response = try decoder.decode(Users.self, from: data)
                            if  response.code == 200 {
                                self.creatDatabase()
                                self.creatTable(tableName: "users")
                                for user in response.data {
                                    self.UsersArray.append(user)
                                    self.storToDatabase(user)
                                }
                                self.closeDatabase()
                            }
                            
                        } catch let error  {
                            print("Parsing Failed \(error.localizedDescription)")
                        }
                    }
                }
                self.usersTableView.reloadData()
            }
        }.resume()
        
    }
    
    func creatDatabase(){
        
        let fileURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("lalzumayaDatabase.sqlite")
        //open database
        guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return
        }
    }
    
    func creatTable(tableName: String) ->() {
        
        if sqlite3_exec(db, "create table if not exists \(tableName) (id integer primary key autoincrement, name TEXT, email TEXT, iid INTEGER, gender TEXT, status TEXT);", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    fileprivate func storToDatabase(_ user: Datum) {
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "insert into users (iid, name, email, gender, status) values (?, ?, ?, ?, ?)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
        }
        
        if sqlite3_bind_text(statement, 1, "\(user.id)", -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user id: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 2, user.name, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user name: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 3, user.email, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user email: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 4, user.gender, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user gender: \(errmsg)")
        }
        if sqlite3_bind_text(statement, 5, user.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding user status: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting user: \(errmsg)")
        }
        
        if sqlite3_reset(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error resetting prepared statement: \(errmsg)")
        }
        
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
    }
    
    func closeDatabase() -> () {
        
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
    }
    
}
extension usersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UsersArray.count
    }
    
    fileprivate func isActive(_ indexPath: IndexPath) -> Bool {
        if (UsersArray[indexPath.row].status == "active"){
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! userTableViewCell
        
        cell.userName.text = UsersArray[indexPath.row].name
        cell.userEmail.text = UsersArray[indexPath.row].email
        cell.userStatus.text = "● "+UsersArray[indexPath.row].status
        cell.userGender.text = UsersArray[indexPath.row].gender
        if isActive(indexPath){
            cell.userStatus.textColor = UIColor(named: "lighGreen")
        } else {
            cell.userStatus.textColor = UIColor.red
        }
        
        return cell
    }
}

// MARK: - Users
struct Users: Codable {
    let code: Int
    let meta: Meta
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable, Identifiable {
    var id: Int
    var name, email, gender, status: String
}

// MARK: - Meta
struct Meta: Codable {
    let pagination: Pagination
}

// MARK: - Pagination
struct Pagination: Codable {
    let total, pages, page, limit: Int
}
