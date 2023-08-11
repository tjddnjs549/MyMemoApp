//
//  CreateMemoViewController.swift
//  MyMemoList
//
//  Created by 박성원 on 2023/08/08.
//

import UIKit
import RealmSwift

class CreateMemoViewController: UIViewController, UITextViewDelegate {

    // MARK: -  property

    @IBOutlet weak var memoTextView: UITextView!
    
    let localRealm = try! Realm() // local default realm 객체를 열기 위함
    var tasks: Results<MemoList>? // Realm에서 제공하는 타입(MemoList타입의 객체 모음)
    var memoContentAll = ""
    var successActionHandler: (() -> ())?
    
    
    // MARK: - viewDidLoad(): 앱의 처음 화면이 나올 때

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    // MARK: - viewWillAppear: 뷰가 나타날 것이다

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false //표준 제목 사용
    }
    
    // MARK: - viewDidAppear: 뷰가 나타났다

    override func viewDidAppear(_ animated: Bool) {
        self.memoTextView.becomeFirstResponder() //키보드 올라감
    }
    
    
    // MARK: - iewDidDisappear: 뷰가 사라졌다 (데이터 저장 및 수정(업데이트))

    override func viewWillDisappear(_ animated: Bool) {
        successActionHandler?()
    }
    
    
    // MARK: - saveButtonClicked(): 완료 버튼 눌렀을 시 이벤트

    @objc func saveButtonClicked(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - 초기세팅

    func setup() {
        memoTextView.delegate = self
        memoTextView.text = memoContentAll
                
        var items: [UIBarButtonItem] = []

        let saveItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(saveButtonClicked))

        items.append(saveItem)

        navigationItem.rightBarButtonItems = items
        
        self.navigationController?.navigationBar.tintColor = .orange
    }
    
    @IBAction func backButtenTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
