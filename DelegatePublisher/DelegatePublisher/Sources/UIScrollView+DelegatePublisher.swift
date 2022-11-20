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
            objc_setAssociatedObject(self, rawPointer, publisher, .OBJC_ASSOCIATION_RETAIN)
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
                formerDelegate: scrollView.delegate
            )
            subscriber.receive(subscription: subscription)
            scrollView.delegate = subscription
        }
    }

    class DelegateSubscription<S: Subscriber>: NSObject, Subscription, UIScrollViewDelegate where S.Input == DelegateEvent, S.Failure == Never {

        private weak var formerDelegate: UIScrollViewDelegate?
        private var subscriber: S?

        init(with subscriber: S, formerDelegate: UIScrollViewDelegate?) {
            self.subscriber = subscriber
            self.formerDelegate = formerDelegate
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling and dragging

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidScroll?(scrollView)
            _ = subscriber?.receive(.didScroll(scrollView))
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewWillBeginDragging?(scrollView)
            _ = subscriber?.receive(.willBeginDragging(scrollView))
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            formerDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            formerDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }

        public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            return formerDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
        }

        public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidScrollToTop?(scrollView)
        }

        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewWillBeginDecelerating?(scrollView)
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Managing zooming

        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return formerDelegate?.viewForZooming?(in: scrollView)
        }

        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            formerDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            formerDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }

        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidZoom?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling animations

        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to inset changes

        public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
            formerDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
}
