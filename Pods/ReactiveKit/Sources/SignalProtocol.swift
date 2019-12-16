//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Dispatch
import Foundation

/// Represents a sequence of events.
public protocol SignalProtocol {

    /// The type of elements generated by the signal.
    associatedtype Element

    /// The type of error that can terminate the signal.
    associatedtype Error: Swift.Error

    /// Register the given observer.
    /// - Parameter observer: A function that will receive events.
    /// - Returns: A disposable that can be used to cancel the observation.
    func observe(with observer: @escaping Observer<Element, Error>) -> Disposable
}

extension SignalProtocol {

    /// Register an observer that will receive events from a signal.
    public func observe<O: ObserverProtocol>(with observer: O) -> Disposable
        where O.Element == Element, O.Error == Error {
            return observe(with: observer.on)
    }

    /// Register an observer that will receive elements from `.next` events of the signal.
    public func observeNext(with observer: @escaping (Element) -> Void) -> Disposable {
        return observe { event in
            if case .next(let element) = event {
                observer(element)
            }
        }
    }

    /// Register an observer that will receive elements from `.failed` events of the signal.
    public func observeFailed(with observer: @escaping (Error) -> Void) -> Disposable {
        return observe { event in
            if case .failed(let error) = event {
                observer(error)
            }
        }
    }

    /// Register an observer that will be executed on `.completed` event.
    public func observeCompleted(with observer: @escaping () -> Void) -> Disposable {
        return observe { event in
            if case .completed = event {
                observer()
            }
        }
    }

    /// Convert the receiver to a concrete signal.
    public func toSignal() -> Signal<Element, Error> {
        return (self as? Signal<Element, Error>) ?? Signal(self.observe)
    }
}

extension SignalProtocol {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveComplete: The closure to execute on completion.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveCompletion: @escaping ((Subscribers.Completion<Error>) -> Void), receiveValue: @escaping ((Element) -> Void)) -> AnyCancellable {
        let disposable = observe { event in
            switch event {
            case .next(let element):
                receiveValue(element)
            case .failed(let error):
                receiveCompletion(.failure(error))
            case .completed:
                receiveCompletion(.finished)
            }
        }
        return AnyCancellable(disposable.dispose)
    }
}

extension SignalProtocol where Error == Never {

    /// Attaches a subscriber with closure-based behavior.
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    /// - parameter receiveValue: The closure to execute on receipt of a value.
    /// - Returns: A cancellable instance; used when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func sink(receiveValue: @escaping ((Element) -> Void)) -> AnyCancellable {
        return sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}

extension SignalProtocol where Error == Never {

    /// Assigns each element from a signal to a property on an object.
    ///
    /// - note: The object will be retained as long as the returned cancellable is retained.
    public func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root) -> AnyCancellable {
        return sink(receiveValue: { object[keyPath: keyPath] = $0 })
    }
}
