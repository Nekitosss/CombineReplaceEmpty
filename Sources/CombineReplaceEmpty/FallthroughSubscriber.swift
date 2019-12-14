
import Combine

final class FallthroughSubscriber<ResultSubscriber: Subscriber>: Subscriber {
    
    typealias Input = ResultSubscriber.Input
    typealias Failure = ResultSubscriber.Failure
    
    private let subscriber: ResultSubscriber
    
    init(subscriber: ResultSubscriber) {
        self.subscriber = subscriber
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Input) -> Subscribers.Demand {
        return subscriber.receive(input)
    }
    
    func receive(completion: Subscribers.Completion<Failure>) {
        subscriber.receive(completion: completion)
    }
}
