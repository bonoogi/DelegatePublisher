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
        let objectIdentifier = ObjectIdentifier(DelegateProxy.self)
        let id = Int(bitPattern: objectIdentifier)
        let rawPointer = UnsafeRawPointer(bitPattern: id)!

        if let proxy = objc_getAssociatedObject(self, rawPointer) as? DelegateProxy {
            return proxy.publisher.eraseToAnyPublisher()
        } else {
            let proxy = DelegateProxy(from: self)
            objc_setAssociatedObject(self, rawPointer, proxy, .OBJC_ASSOCIATION_RETAIN)
            self.delegate = proxy
            return proxy.publisher.eraseToAnyPublisher()
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

    class DelegatePublisher: Publisher {

        public typealias Output = DelegateEvent
        public typealias Failure = Never

        private weak var delegateAppender: UIScrollViewDelegateAppender?

        init(appender: UIScrollViewDelegateAppender) {
            self.delegateAppender = appender
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, UIScrollView.DelegateEvent == S.Input {
            let subscription = DelegateSubscription<S>(with: subscriber)
            subscriber.receive(subscription: subscription)

            let type = AnyDelegateType<UIScrollViewDelegate>(subscription)
            delegateAppender?.append(delegateType: type)
        }
    }

    class DelegateSubscription<S: Subscriber>: NSObject, Subscription, UIScrollViewDelegate, DelegateType where S.Input == DelegateEvent, S.Failure == Never {

        typealias Delegate = UIScrollViewDelegate

        private var subscriber: S?

        var delegate: Delegate {
            return self
        }

        init(with subscriber: S) {
            self.subscriber = subscriber
        }

        deinit {
            print("DelegateSubscription Deinit")
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling and dragging

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            _ = subscriber?.receive(.didScroll(scrollView))
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            _ = subscriber?.receive(.willBeginDragging(scrollView))
        }
    }

    class DelegateProxy: NSObject, UIScrollViewDelegate, UIScrollViewDelegateAppender {

        var delegateTypes: [AnyDelegateType<UIScrollViewDelegate>]

        private weak var scrollView: UIScrollView?
        private weak var originalDelegate: UIScrollViewDelegate?
        private(set) lazy var publisher: DelegatePublisher = {
            return DelegatePublisher(appender: self)
        }()

        init(from scrollView: UIScrollView) {
            self.scrollView = scrollView
            self.originalDelegate = scrollView.delegate
            self.delegateTypes = []
            super.init()
        }

        func append(delegateType: AnyDelegateType<UIScrollViewDelegate>) {
            delegateTypes.append(delegateType)
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidScroll?(scrollView)
            }
            originalDelegate?.scrollViewDidScroll?(scrollView)
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewWillBeginDragging?(scrollView)
            }
            originalDelegate?.scrollViewWillBeginDragging?(scrollView)
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            for type in delegateTypes {
                type.delegate.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
            }
            originalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            for type in delegateTypes {
                type.delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
            }
            originalDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }

        public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            for type in delegateTypes {
                _ = type.delegate.scrollViewShouldScrollToTop?(scrollView)
            }
            return originalDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
        }

        public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidScrollToTop?(scrollView)
            }
            originalDelegate?.scrollViewDidScrollToTop?(scrollView)
        }

        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewWillBeginDecelerating?(scrollView)
            }
            originalDelegate?.scrollViewWillBeginDecelerating?(scrollView)
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidEndDecelerating?(scrollView)
            }
            originalDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Managing zooming

        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            for type in delegateTypes {
                _ = type.delegate.viewForZooming?(in: scrollView)
            }
            return originalDelegate?.viewForZooming?(in: scrollView)
        }

        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            for type in delegateTypes {
                type.delegate.scrollViewWillBeginZooming?(scrollView, with: view)
            }
            originalDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            for type in delegateTypes {
                type.delegate.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
            }
            originalDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }

        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidZoom?(scrollView)
            }
            originalDelegate?.scrollViewDidZoom?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling animations

        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidEndScrollingAnimation?(scrollView)
            }
            originalDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to inset changes

        public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
            for type in delegateTypes {
                type.delegate.scrollViewDidChangeAdjustedContentInset?(scrollView)
            }
            originalDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
}

protocol UIScrollViewDelegateAppender: AnyObject {
    func append(delegateType: AnyDelegateType<UIScrollViewDelegate>)
}
