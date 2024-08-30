import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Domain
import Foundation

// MARK: - HomeSideEffect

struct HomeSideEffect {
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

extension HomeSideEffect {
  var getItem: (MusicEntity.Search.Album.Request) -> Effect<HomeReducer.Action> {
    { req in
      .publisher {
        useCase.searchUseCase
          .album(req)
          .receive(on: main)
          .map {
            MusicEntity.Search.Album.Composite(
              request: req,
              response: $0)
          }
          .mapToResult()
          .map(HomeReducer.Action.fetchItem)
      }
    }
  }
}
