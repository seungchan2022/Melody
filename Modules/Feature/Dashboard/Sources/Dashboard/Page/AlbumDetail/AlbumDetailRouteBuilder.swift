import Architecture
import LinkNavigator
import MusicKit

struct AlbumDetailRouteBuilder<RootNavigator: RootNavigatorType> {
  static func generate() -> RouteBuilderOf<RootNavigator> {
    let matchPath = Link.Dashboard.Path.albumDetail.rawValue

    return .init(matchPath: matchPath) { navigator, items, diContainer -> RouteViewController? in
      guard let env: DashboardEnvironmentUsable = diContainer.resolve() else { return .none }
      guard let item: Album = items.decoded() else { return .none }

      return DebugWrappingController(matchPath: matchPath) {
        AlbumDetailPage(
          store: .init(
            initialState: AlbumDetailReducer.State(item: item),
            reducer: {
              AlbumDetailReducer(
                sideEffect: .init(
                  useCase: env,
                  navigator: navigator))
            }))
      }
    }
  }
}
