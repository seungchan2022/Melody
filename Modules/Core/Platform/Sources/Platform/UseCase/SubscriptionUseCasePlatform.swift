import Combine
import Domain
import MusicKit

// MARK: - SubscriptionUseCasePlatform

public struct SubscriptionUseCasePlatform {
  public init() { }
}

// MARK: SubscriptionUseCase

extension SubscriptionUseCasePlatform: SubscriptionUseCase {
  public var subscription: () -> AnyPublisher<MusicEntity.Subscription.Response, CompositeErrorRepository> {
    {
      Future<MusicEntity.Subscription.Response, CompositeErrorRepository> { promise in
        Task {
          for await subscription in MusicSubscription.subscriptionUpdates {
            let response = MusicEntity.Subscription.Response(
              canPlayCatalogContent: subscription.canPlayCatalogContent,
              canBecomeSubscriber: subscription.canBecomeSubscriber)

            return promise(.success(response))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}
