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
  var getTrack: (MusicEntity.AlbumDetail.Track.Request) -> Effect<AlbumDetailReducer.Action> {
    { req in
      .publisher {
        useCase.albumDetailUseCase
          .track(req)
          .receive(on: main)
          .mapToResult()
          .map(AlbumDetailReducer.Action.fetchTrackItem)
      }
    }
  }

  var getRelatedAlbum: (MusicEntity.AlbumDetail.RelatedAlbum.Request) -> Effect<AlbumDetailReducer.Action> {
    { req in
      .publisher {
        useCase.albumDetailUseCase
          .relatedAlbum(req)
          .receive(on: main)
          .mapToResult()
          .map(AlbumDetailReducer.Action.fetchRelatedAlbum)
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
