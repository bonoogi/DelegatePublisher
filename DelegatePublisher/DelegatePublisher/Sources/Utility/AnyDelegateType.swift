//
//  AnyDelegateType.swift
//  DelegatePublisher
//
//  Created by 구본욱 on 2022/11/21.
//

import Foundation

// [Swift Type Erase Pattern 이해하기](https://blog.burt.pe.kr/posts/skyfe79-blog.contents-1118038013-post-44/)를 참고

protocol DelegateType {
    associatedtype Delegate

    var delegate: Delegate { get }
}

fileprivate class AnyDelegateTypeBase<Delegate>: DelegateType {
    var delegate: Delegate { fatalError() }
}

fileprivate class AnyDelegateTypeContainer<ConcreteDelegateType: DelegateType>: AnyDelegateTypeBase<ConcreteDelegateType.Delegate> {
    var concrete: ConcreteDelegateType

    override var delegate: ConcreteDelegateType.Delegate {
        return concrete.delegate
    }

    init(_ concrete: ConcreteDelegateType) {
        self.concrete = concrete
    }
}

public class AnyDelegateType<Delegate>: DelegateType {
    private let container: AnyDelegateTypeBase<Delegate>

    var delegate: Delegate {
        return container.delegate
    }

    init<ConcreteDelegateType: DelegateType>(_ concrete: ConcreteDelegateType) where ConcreteDelegateType.Delegate == Delegate {
        self.container = AnyDelegateTypeContainer(concrete)
    }
}
