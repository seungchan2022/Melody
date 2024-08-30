import Architecture
import Combine
import CombineExt
import ComposableArchitecture
import Foundation

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

extension AlbumDetailSideEffect { }
