
import Combine

extension Publisher {
    
    public func replaceEmpty<P: Publisher>(_ newPublisher: @autoclosure () -> P) -> Publishers.ReplaceEmptyWithPublisher<P, Self> {
        return Publishers.ReplaceEmptyWithPublisher(upstream: self, newPublisher: newPublisher())
    }
    
}

extension Publishers {
    public struct ReplaceEmptyWithPublisher<NewPublisher: Publisher, Upstream: Publisher>: Publisher where NewPublisher.Failure == Upstream.Failure, NewPublisher.Output == Upstream.Output {
        
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        let upstream: Upstream
        let newPublisher: NewPublisher
        
        init(upstream: Upstream, newPublisher: NewPublisher) {
            self.upstream = upstream
            self.newPublisher = newPublisher
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = OriginalSubscriber(upstream: upstream, downstream: newPublisher, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
        
    }

}

extension Publishers.ReplaceEmptyWithPublisher {
    
    fileprivate final class OriginalSubscriber<OriginalPublisher: Publisher, ReplacingPublisher: Publisher, S: Subscriber>: Subscriber, Subscription
    where S.Input == OriginalPublisher.Output, ReplacingPublisher.Output == OriginalPublisher.Output, ReplacingPublisher.Failure == OriginalPublisher.Failure, S.Failure == OriginalPublisher.Failure {
        
        typealias Input = OriginalPublisher.Output
        typealias Failure = OriginalPublisher.Failure
        
        private var replacingPublisher: ReplacingPublisher
        private var originalPublisher: OriginalPublisher
        private let subscriber: S
        
        private var subscription: Subscription?
        
        private var didReceiveAtLeastOneValue = false
        
        init(upstream: OriginalPublisher, downstream: ReplacingPublisher, subscriber: S) {
            self.originalPublisher = upstream
            self.replacingPublisher = downstream
            self.subscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            originalPublisher.receive(subscriber: self)
        }
        
        func cancel() {
            subscription?.cancel()
            subscription = nil
        }
        
        func receive(subscription: Subscription) {
            self.subscription = subscription
            subscription.request(.unlimited)
        }
        
        func receive(_ input: OriginalPublisher.Output) -> Subscribers.Demand {
            didReceiveAtLeastOneValue = true
            return subscriber.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<OriginalPublisher.Failure>) {
            switch completion {
            case .failure,
                 .finished where didReceiveAtLeastOneValue:
                subscriber.receive(completion: completion)
                subscription = nil
            default:
                let fallthroughSubscriber = FallthroughSubscriber(subscriber: subscriber)
                replacingPublisher.receive(subscriber: fallthroughSubscriber)
                subscription = nil
            }
        }
    }
}

