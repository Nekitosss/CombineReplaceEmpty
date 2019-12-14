
import Combine

extension Publisher {
    
    public func replaceError<P: Publisher>(_ newPublisher: @autoclosure () -> P) -> Publishers.ReplaceErrowWithPublisher<P, Self> {
        return Publishers.ReplaceErrowWithPublisher(upstream: self, newPublisher: newPublisher())
    }
    
}

extension Publishers {
    public struct ReplaceErrowWithPublisher<NewPublisher: Publisher, Upstream: Publisher>: Publisher where NewPublisher.Output == Upstream.Output {
        
        public typealias Output = Upstream.Output
        public typealias Failure = NewPublisher.Failure
        
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


extension Publishers.ReplaceErrowWithPublisher {
    
    fileprivate final class OriginalSubscriber<OriginalPublisher: Publisher, ReplacingPublisher: Publisher, S: Subscriber>: Subscriber, Subscription
        where
        S.Input == OriginalPublisher.Output,
        ReplacingPublisher.Output == OriginalPublisher.Output,
        S.Failure == ReplacingPublisher.Failure{
        
        typealias Input = OriginalPublisher.Output
        typealias Failure = OriginalPublisher.Failure
        
        private var replacingPublisher: ReplacingPublisher
        private var originalPublisher: OriginalPublisher
        private let subscriber: S
        
        private var subscription: Subscription?
        
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
        
        func receive(_ input: Input) -> Subscribers.Demand {
            return subscriber.receive(input)
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            switch completion {
            case .failure:
                let fallthroughSubscriber = FallthroughSubscriber(subscriber: subscriber)
                replacingPublisher.receive(subscriber: fallthroughSubscriber)
                subscription = nil
            case .finished:
                subscriber.receive(completion: .finished)
                subscription = nil
            }
        }
    }
}

