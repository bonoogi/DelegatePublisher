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

        if let publisher = objc_getAssociatedObject(self, rawPointer) as? AnyPublisher<DelegateEvent, Never> {
            return publisher
        } else {
            let publisher = DelegatePublisher(scrollView: self).share().eraseToAnyPublisher()
            objc_setAssociatedObject(self, rawPointer, publisher, .OBJC_ASSOCIATION_RETAIN)
            return publisher
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

    internal struct DelegatePublisher: Publisher {

        public typealias Output = DelegateEvent
        public typealias Failure = Never

        private let scrollView: UIScrollView

        init(scrollView: UIScrollView) {
            self.scrollView = scrollView
        }

        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, UIScrollView.DelegateEvent == S.Input {
            let subscription = DelegateSubscription<S>(
                with: subscriber,
                originalDelegate: scrollView.delegate
            )
            subscriber.receive(subscription: subscription)
            scrollView.delegate = subscription
        }
    }

    internal class DelegateSubscription<S: Subscriber>: NSObject, Subscription, UIScrollViewDelegate where S.Input == DelegateEvent, S.Failure == Never {

        private weak var originalDelegate: UIScrollViewDelegate?
        private var subscriber: S?

        init(with subscriber: S, originalDelegate: UIScrollViewDelegate?) {
            self.subscriber = subscriber
            self.originalDelegate = originalDelegate
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling and dragging

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidScroll?(scrollView)
            _ = subscriber?.receive(.didScroll(scrollView))
        }

        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewWillBeginDragging?(scrollView)
            _ = subscriber?.receive(.willBeginDragging(scrollView))
        }

        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            originalDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
        }

        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            originalDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }

        public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            return originalDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
        }

        public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidScrollToTop?(scrollView)
        }

        public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewWillBeginDecelerating?(scrollView)
        }

        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Managing zooming

        public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return originalDelegate?.viewForZooming?(in: scrollView)
        }

        public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            originalDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            originalDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
        }

        public func scrollViewDidZoom(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidZoom?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to scrolling animations

        public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        }

        // MARK: UIScrollViewDelegate - Responding to inset changes

        public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
            originalDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
        }
    }
}
