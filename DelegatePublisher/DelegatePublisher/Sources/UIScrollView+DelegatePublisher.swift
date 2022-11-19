//
//  UIScrollView+DelegatePublisher.swift
//  DelegatePublisher
//
//  Created by 구본욱 on 2022/11/19.
//

import Combine
import UIKit

public extension UIScrollView {

    // MARK: - 계산 프로퍼티

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

    var didScrollPublisher: AnyPublisher<UIScrollView, Never> {
        return delegatePublisher
            .compactMap { event -> UIScrollView? in
                guard case .didScroll(let scrollView) = event else {
                    return nil
                }
                return scrollView
            }
            .eraseToAnyPublisher()
    }

    var willBeginDraggingPublisher: AnyPublisher<UIScrollView, Never> {
        return delegatePublisher
            .compactMap { event -> UIScrollView? in
                guard case .willBeginDragging(let scrollView) = event else {
                    return nil
                }
                return scrollView
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 내부 타입 선언

    enum DelegateEvent {
        case didScroll(UIScrollView)
        case willBeginDragging(UIScrollView)
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

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            target = nil
        }

        // MARK: Conform UIScrollViewDelegate

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidScroll?(scrollView)
            _ = target?.receive(.didScroll(scrollView))
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewWillBeginDragging?(scrollView)
            _ = target?.receive(.willBeginDragging(scrollView))
        }
    }
}
