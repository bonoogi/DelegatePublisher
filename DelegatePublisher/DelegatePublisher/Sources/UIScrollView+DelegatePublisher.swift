//
//  UIScrollView+DelegatePublisher.swift
//  DelegatePublisher
//
//  Created by 구본욱 on 2022/11/19.
//

import Combine
import UIKit

public extension UIScrollView {

    var delegatePublsher: DelegatePublisher {
        return DelegatePublisher(scrollView: self)
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
            scrollView.delegate = subscription
            subscriber.receive(subscription: subscription)
        }
    }

    class DelegateSubscription<Target: Subscriber>: NSObject, Subscription, UIScrollViewDelegate where Target.Input == DelegateEvent, Target.Failure == Never {

        private var scrollView: UIScrollView
        private var target: Target?

        init(with target: Target, scrollView: UIScrollView) {
            self.target = target
            self.scrollView = scrollView
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            scrollView.delegate = nil
            target = nil
        }

        // MARK: Conform UIScrollViewDelegate

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            _ = target?.receive(.didScroll(scrollView))
        }
    }
}
