import Combine

public protocol SubscriptionUseCase {
  var subscription: () -> AnyPublisher<MusicEntity.Subscription.Response, CompositeErrorRepository> { get }
}
