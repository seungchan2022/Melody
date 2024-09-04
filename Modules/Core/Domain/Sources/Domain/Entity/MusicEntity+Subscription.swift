import Foundation
import MusicKit

// MARK: - MusicEntity.Subscription

extension MusicEntity {
  public enum Subscription { }
}

// MARK: - MusicEntity.Subscription.Response

extension MusicEntity.Subscription {
  public struct Response: Equatable, Codable, Sendable {
    public let canPlayCatalogContent: Bool
    public let canBecomeSubscriber: Bool

    public init(
      canPlayCatalogContent: Bool,
      canBecomeSubscriber: Bool)
    {
      self.canPlayCatalogContent = canPlayCatalogContent
      self.canBecomeSubscriber = canBecomeSubscriber
    }
  }
}
