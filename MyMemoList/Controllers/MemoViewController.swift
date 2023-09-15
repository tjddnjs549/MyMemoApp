//
//  MemoViewController.swift
//  MyMemoList
//
//  Created by 박성원 on 2023/08/08.
//

import UIKit
import RealmSwift
import Toast

class MemoViewController: UIViewController {
    
    // MARK: - property

    @IBOutlet weak var tableView: UITableView!
    
    
    let localRealm = try! Realm() // local default realm 객체를 열기 위함
    var tasks: Results<MemoList>!
    var likeTasks: Results<MemoList>! //Results: 자동업데이트 컨테이너 (속성이 변할 때마다 자동으로 append 수행)
    var allTasks: Results<MemoList>!
    var searchText: String?
    var searchController:  UISearchController! = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.placeholder = "검색"
        search.searchBar.setValue("취소", forKey: "cancelButtonText")
        search.searchBar.tintColor = .systemOrange
        
        return search
    }()
        
    
    
    // MARK: - viewDidLoad()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        
        
        TableViewCellSetting()
        tabBarSetup()
    }
    
    
    // MARK: - viewWillAppear()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberFormatter = NumberFormatter()
        let memoCount = numberFormatter.string(for: localRealm.objects(MemoList.self).count)! //갯수 가져오기
        navigationItem.title = "\(memoCount)개의 메모" //타이틀 제목
        self.navigationController?.navigationBar.prefersLargeTitles = true //제목 크게 하기 (왼쪽 아래부분으로 가서 크게 함)
        self.navigationItem.hidesSearchBarWhenScrolling = false // 스크롤 할 때 서치부분은 남겨두기(false로 설정하면 스크롤 남길 수 있음)
        tableView.reloadData()
    }
    
    
    
    // MARK: - 테이블뷰 셀 세팅

    func TableViewCellSetting() {
        likeTasks = localRealm.objects(MemoList.self).filter(NSPredicate(format: "%K == true", "like")).sorted(byKeyPath: "date", ascending: false)
        tasks = localRealm.objects(MemoList.self).filter(NSPredicate(format: "%K == false", "like")).sorted(byKeyPath: "date", ascending: false) // 최근 등록일 순
        allTasks = localRealm.objects(MemoList.self).sorted(byKeyPath: "date", ascending: false)
    }
    
    
    // MARK: - 탭바 세팅

    func tabBarSetup() {
        let tabBar = UIToolbar(frame: .init(x: 0, y: 0, width: 100, height: 100))
        view.addSubview(tabBar)
        
        //레이아웃
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0).isActive = true
        tabBar.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 0).isActive = true
        tabBar.trailingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.trailingAnchor, multiplier: 0).isActive = true

        
        var items: [UIBarButtonItem] = []
        
        //유연한 공간을 먼저 만들고 추가하면 유연한 공간이 도구 모음의 대부분을 차지하도록 확장됨에 따라 해당 버튼이 오른쪽 가장자리로 밀림
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)

        let toolbarItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(writeButtonTapped)) //이모지 이벤트 추가
        
        items.append(flexibleSpace)
        items.append(toolbarItem)
        
        items.forEach{(item) in
            item.tintColor = .orange
        }
        tabBar.setItems(items, animated: true)
    }
    
    // MARK: - 탭바 아이템 클릭 시 이벤트 함수

    //클릭 시 메모 작성 화면 이동
    @objc func writeButtonTapped() {
        
        let storyboard = UIStoryboard(name: "CreateMemo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateMemoViewController") as! CreateMemoViewController //이동
        
        vc.successActionHandler = {
            var title = ""
            var content = ""
            //공백일 경우 (trimmingCharacters: 주어진 문자 집합에 포함된 수신자 문자를 양쪽 끝에서 제거하여 만든 새 문자열을 반환)
            if vc.memoTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return
            } else if !vc.memoTextView.text!.contains("\n") { //한 줄일 경우
                title = vc.memoTextView.text!
            } else {  // 개행 있을 경우
                title = String(vc.memoTextView.text!.split(separator: "\n").first!) //첫번째 줄만 넣음 (split: \n나오면 거기까지 저장)
                content = String(vc.memoTextView.text!.dropFirst(title.count + 1)) // 제목 자름 (dropFirst: 요소 다음 거 나옴)
            } // dropFirst: Returns a subsequence containing all but the given number of initial elements
            
            let task = MemoList(memoTitle: title, memoContent: content, memoAll: vc.memoTextView.text, like: false, date: Date())
            
            try! self.localRealm.write {
                self.localRealm.add(task)
                self.tableView.reloadData() //테이블에 나오게
                self.viewWillAppear(false) // 타이틀 수정하기 위해서
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    } // 검색바가 활성화가 돼 있거나 검색창이 비어있지 않으면 참

}


// MARK: - UISearchBarDelegate, UISearchResultsUpdating 채택한 뷰컨트롤 확장

extension MemoViewController: UISearchBarDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        //CONTAINS: 검색창에 포함되어 있는 단어 나오게 하기
        allTasks = localRealm.objects(MemoList.self).filter("memoAll CONTAINS '\(searchController.searchBar.text!)'").sorted(byKeyPath: "date")
        searchText  = searchController.searchBar.text
        tableView.reloadData() //나오게 하기
    }
}



// MARK: - UITableViewDataSource, UITableViewDelegate 채택한 뷰컨트롤 확장

extension MemoViewController: UITableViewDataSource, UITableViewDelegate {
    
    //섹션 수 조정
    func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering() ? 1 : 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isFiltering() ? allTasks.count : likeTasks.count
        } else {
            return tasks.count
        }
    }
    
    //헤더 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       if section == 0{
           return isFiltering() ? "\(allTasks.count)개 찾음" : "고정 메모"
        } else if section == 1 {
            return "메모"
        }
        return nil
    }
    
    //헤더뷰 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as? HeaderTableViewCell else{
            return UITableViewCell()
        }
        cell.headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        cell.headerLabel.font = UIFont.boldSystemFont(ofSize: 23)

        return cell.contentView
    }
    
    // MARK: - 셀 구성 (row)

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let row = isFiltering() ? allTasks[indexPath.row] : likeTasks[indexPath.row]

            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoTableViewCell") as? MemoTableViewCell else{
                return UITableViewCell()
            }
            let format = DateFormatter()
            format.dateFormat = "yyyy. MM. dd. a hh:mm"
            
            //calendar
            let calendarDate = Calendar.current
            //월요일 구하기
            var component = calendarDate.dateComponents([.weekOfYear, .yearForWeekOfYear, .weekday], from: Date())
            component.weekday = 2
            let mondayWeek = calendarDate.date(from: component)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier:"ko_KR")
            let tempRegDate = formatter.string(from: row.date)
            
            for i in 0...6{
                let week = calendarDate.date(byAdding: .day , value: i, to: mondayWeek!)
                let weekStr = formatter.string(from: week!)
                
                if tempRegDate == weekStr{
                    format.dateFormat = "EEEE"
                }
            }
            
            format.locale = Locale(identifier:"ko_KR")
            let date = format.string(from: row.date)
            
            cell.memoTitleLabel.text = row.memoTitle
            cell.memoDateLabel.text = date
            cell.memoContentLabel.text = row.memoContent
            
            
            return cell
        }
        else{
            let row = tasks[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoTableViewCell") as? MemoTableViewCell else{
                return UITableViewCell()
            }
            
            let format = DateFormatter()
            format.dateFormat = "yyyy. MM. dd. a hh:mm"
            
            //calendar
            let calendarDate = Calendar.current
            //월요일 구하기
            var component = calendarDate.dateComponents([.weekOfYear, .yearForWeekOfYear, .weekday], from: Date())
            component.weekday = 2
            let mondayWeek = calendarDate.date(from: component)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier:"ko_KR")
            let tempdate = formatter.string(from: row.date)
            
            for i in 0...6{
                let week = calendarDate.date(byAdding: .day , value: i, to: mondayWeek!)
                let weekStr = formatter.string(from: week!)
                
                if tempdate == weekStr{
                    format.dateFormat = "EEEE"
                }
            }
    
            format.locale = Locale(identifier:"ko_KR")
            let date = format.string(from: row.date)
            
            cell.memoTitleLabel.text = row.memoTitle
            cell.memoDateLabel.text = date
            cell.memoContentLabel.text = row.memoContent
            
            return cell
        }
    }
    //셀 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    //헤더 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //셀 선택시
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "CreateMemo", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateMemoViewController") as! CreateMemoViewController
        
        var taskUpdate = tasks[indexPath.row]
        if indexPath.section == 0{
            taskUpdate = isFiltering() ? allTasks[indexPath.row] : likeTasks[indexPath.row]
        }
        
        vc.memoContentAll = taskUpdate.memoAll
        
        
        vc.successActionHandler = {
            var title = ""
            var content = ""
            
            //공백일 경우
            if vc.memoTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
                try! self.localRealm.write{
                    self.localRealm.delete(taskUpdate) // 지우기
                    tableView.reloadData()
                    self.viewWillAppear(false)// 제목 수정하기위해
                }
                return
            }
            //수정했는데 같을 경우
            else if taskUpdate.memoAll == vc.memoTextView.text{
                return
            }  else if !vc.memoTextView.text!.contains("\n") { //한 줄일 경우
                title = vc.memoTextView.text!
            } else { // 개행 있을 경우
                title = String(vc.memoTextView.text!.split(separator: "\n").first!)
                content = String(vc.memoTextView.text!.dropFirst(title.count + 1))
            }
                        
            try! self.localRealm.write {
                taskUpdate.memoTitle = title
                taskUpdate.memoContent = content
                taskUpdate.memoAll = vc.memoTextView.text
                taskUpdate.date = Date()
            
                self.tableView.reloadData()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //삭제 스와이프
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var row = tasks[indexPath.row]
        if indexPath.section == 0{
            row = isFiltering() ? allTasks[indexPath.row] : likeTasks[indexPath.row]
        }
        
        let alert = UIAlertController(title: row.memoTitle, message: "메모를 삭제해도 되나요?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "예", style: .default){ (action) in
            
            try! self.localRealm.write{
                self.localRealm.delete(row)
                tableView.reloadData()
                self.viewWillAppear(false)// 위에 타이틀 수정하기 위해서
            }
            
            return
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel){ (action) in
            return
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    //즐겨찾기
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        //고정되어있는 섹션
        if indexPath.section == 0 && !searchController.isActive{
            let favoriteAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
                completionHaldler(true)
                let taskUpdate = self.likeTasks[indexPath.row]
                try! self.localRealm.write{
                    taskUpdate.like = !taskUpdate.like
                    tableView.reloadData()
                }
            })
            favoriteAction.backgroundColor = .systemOrange
            favoriteAction.image = UIImage(systemName: "pin.slash.fill")
            
            return UISwipeActionsConfiguration(actions: [favoriteAction])
            
        }
        
        //고정되지 않은 섹션
        else if indexPath.section == 1 {
            let favoriteAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
                completionHaldler(true)
                //5개까지 가능
                if self.likeTasks.count >= 5 {
                    self.view.makeToast("고정 메모는 5개까지 가능합니다.", duration: 2.0, position: .bottom)
                    return
                }
                let taskUpdate = self.tasks[indexPath.row]
                try! self.localRealm.write{
                    taskUpdate.like = !taskUpdate.like
                    tableView.reloadData()
                }
            })
            favoriteAction.backgroundColor = .systemOrange
            favoriteAction.image = UIImage(systemName: "pin.fill")
            
            return UISwipeActionsConfiguration(actions: [favoriteAction])
        }
        else{
            let row = allTasks[indexPath.row]
            let favoriteAction = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
                completionHaldler(true)
                
                if row.like{
                    try! self.localRealm.write{
                        row.like = !row.like
                        tableView.reloadData()
                    }
                }
                else{
                    if self.likeTasks.count >= 5 {
                        self.view.makeToast("고정 메모는 5개까지 가능합니다.", duration: 2.0, position: .top)
                        return
                    }
                    try! self.localRealm.write{
                        row.like = !row.like
                        tableView.reloadData()
                    }
                }
                
            })
            favoriteAction.backgroundColor = .systemOrange
            favoriteAction.image = row.like ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
            
            return UISwipeActionsConfiguration(actions: [favoriteAction])
        }
        
    }
    
}

