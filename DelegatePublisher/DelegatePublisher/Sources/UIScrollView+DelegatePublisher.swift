//
//  UIScrollView+DelegatePublisher.swift
//  DelegatePublisher
//
//  Created by 구본욱 on 2022/11/19.
//

import Combine
import UIKit

public extension UIScrollView {

    var delegatePublisher: AnyPublisher<DelegateEvent, Never> {
        let objectIdentifier = ObjectIdentifier(DelegatePublisher.self)
        let id = Int(bitPattern: objectIdentifier)
        let rawPointer = UnsafeRawPointer(bitPattern: id)!

        if let publisher = objc_getAssociatedObject(self, rawPointer) as? DelegatePublisher {
            return publisher.eraseToAnyPublisher()
        } else {
            let publisher = DelegatePublisher(scrollView: self)
            objc_setAssociatedObject(self, rawPointer, publisher, .OBJC_ASSOCIATION_ASSIGN)
            return publisher.eraseToAnyPublisher()
        }
    }

    enum DelegateEvent {
        case didScroll(UIScrollView)
    }

    struct DelegatePublisher: Publisher {

        public typealias Output = DelegateEvent
        public typealias Failure = Never

        private let scrollView: UIScrollView

        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, UIScrollView.DelegateEvent == S.Input {
            let subscription = DelegateSubscription<S>(
                with: subscriber,
                scrollView: scrollView
            )
            subscriber.receive(subscription: subscription)
            scrollView.delegate = subscription
        }
    }

    class DelegateSubscription<Target: Subscriber>: NSObject, Subscription, UIScrollViewDelegate where Target.Input == DelegateEvent, Target.Failure == Never {

        private weak var scrollView: UIScrollView?
        private weak var formerDelegate: UIScrollViewDelegate?
        private var target: Target?

        init(with target: Target, scrollView: UIScrollView) {
            self.target = target
            self.scrollView = scrollView
            self.formerDelegate = scrollView.delegate
        }

        deinit {
            print("DEINIT-DelegateSubscription")
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            target = nil
        }

        // MARK: Conform UIScrollViewDelegate

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidScroll?(scrollView)
            _ = target?.receive(.didScroll(scrollView))
        }
    }
}
