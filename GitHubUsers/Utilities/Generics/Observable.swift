//
//  Observable.swift
//  GitHubUsers
//
//  Created by Jeff on 02/09/2021.
//

import Foundation

class Observable<T> {
    var value: T? {
        didSet {
            listner?(value)
        }
    }
    
    init(_ value: T?) {
        self.value = value
    }
    
    private var listner: ((T?)->())?
    
    func bind(_ listner: @escaping (T?)->()){
        listner(value)
        self.listner = listner
    }
}
