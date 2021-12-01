//
//  Observable.swift
//  Bonjour
//
//  Created by Fitzgerald Afful on 13/11/2021.
//

import Foundation

public class Observable<T> {

    var value: T {
        didSet {
            listener?(value)
        }
    }

    private var listener: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
}
