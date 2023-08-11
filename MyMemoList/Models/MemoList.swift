//
//  MemoList.swift
//  MyMemoList
//
//  Created by 박성원 on 2023/08/08.
//

import Foundation
import RealmSwift



// MARK: - Realm 라이브러리 사용

class MemoList: Object { // Realm에서 사용할 수 있는 형태로 만들어 주려면 class가 Object를 상속
    @Persisted var memoTitle: String // 프로퍼티는 정의할 때 @Persisted를 붙이기만 하면 됨
    @Persisted var memoContent: String?
    @Persisted var memoAll: String
    @Persisted var like: Bool
    @Persisted var date: Date = Date()
    @Persisted(primaryKey: true) var _key: ObjectId //기본키로 설정
    
    
    // MARK: - 생성자

    convenience init(memoTitle: String, memoContent: String, memoAll: String, like: Bool, date: Date) {
        self.init()
        
        self.memoTitle = memoTitle
        self.memoContent = memoContent
        self.memoAll = memoAll
        self.like = like
        self.date = date
    }
    
}
