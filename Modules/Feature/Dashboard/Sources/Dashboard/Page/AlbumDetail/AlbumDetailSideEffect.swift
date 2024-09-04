import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation
import MusicKit

// MARK: - AlbumDetailSideEffect

struct AlbumDetailSideEffect {
  let useCase: DashboardEnvironmentUsable
  let main: AnySchedulerOf<DispatchQueue>
  let navigator: RootNavigatorType

  init(
    useCase: DashboardEnvironmentUsable,
    main: AnySchedulerOf<DispatchQueue> = .main,
    navigator: RootNavigatorType)
  {
    self.useCase = useCase
    self.main = main
    self.navigator = navigator
  }
}

extension AlbumDetailSideEffect {
  var getItem: (MusicEntity.AlbumDetail.Track.Request) -> Effect<AlbumDetailReducer.Action> {
    { req in
      .publisher {
        useCase.albumDetailUseCase
          .track(.init(album: req.album))
          .receive(on: main)
          .mapToResult()
          .map(AlbumDetailReducer.Action.fetchItem)
      }
    }
  }

  var getSubscription: () -> Effect<AlbumDetailReducer.Action> {
    {
      .publisher {
        useCase.subscriptionUseCase
          .subscription()
          .receive(on: main)
          .mapToResult()
          .map(AlbumDetailReducer.Action.fetchSubscription)
      }
    }
  }
}
