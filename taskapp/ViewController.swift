import UIKit
import RealmSwift   // Lesson6_6.6で追加
import UserNotifications    // Lesson6_7.4で追加


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()   // Lesson6_6.6で追加
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // Lesson6_6.6で追加
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //  ここから、メンターの添削で挿入したサーチバー
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        //  ここまで、メンターの添削
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count   // Lesson6_6.7で修正する
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する.  ---  // Lesson6_6.7でここから追加 ---
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- Lesson6_6.7でここまで追加 ---
        
        return cell
    }
    
    // ViewControllerの各セルをタップした時に呼ばれて、タスク入力画面に遷移させるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil) // +ボタンのsegueのIDを指定して遷移させるメソッドを追加
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時にローカル通知をキャンセルし、データベースからタスクを削除するメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここからLesson6_6.7で追加 ---
        if editingStyle == .delete{
            // Lesson6_7.4 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // Lesson6_7.4 ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // セルをアニメーションさせながら、データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }  // メソッドがエラーを発生させてもても、エラーはtry!と記述することで無視する
            // --- ここまでLesson6_6.7で追加 ---
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
            // --- ここまで変更 ---
        }
    }
    
    //  ここから、メンターの添削で挿入したサーチバー
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        taskArray = try! Realm().objects(Task.self).filter("category == %@", searchBar.text!)
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        searchBar.text = ""
        tableView.reloadData()
    }
    //  ここまで、メンターの添削
    
    // segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //すでに作成済みのタスクを編集するときは"cellSegue"
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            // +ボタンをタップした時はTaskクラスのインスタンスを生成
            let task = Task()
            
            let allTask = realm.objects(Task.self)
            if allTask.count != 0 {
                task.id = allTask.max(ofProperty: "id")! + 1
            }  // すでに存在しているタスクのidのうち最大のものを取得し、1を足すことで他のidと重ならない値を指定
            
            inputViewController.task = task
            
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}
