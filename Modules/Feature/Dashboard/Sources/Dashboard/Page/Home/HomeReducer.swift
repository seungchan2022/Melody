import Architecture
import ComposableArchitecture
import Domain
import Foundation
import MusicKit

@Reducer
struct HomeReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: HomeSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {
    let id: UUID

    var query = ""

    var itemList: MusicItemCollection<Album> = []

    var fetchItem: FetchState.Data<MusicEntity.Search.Album.Composite?> = .init(isLoading: false, value: .none)

    init(id: UUID = UUID()) {
      self.id = id
    }
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case search(String)
    case fetchItem(Result<MusicEntity.Search.Album.Composite, CompositeErrorRepository>)

    case routeToDetail(Album)

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestItem
  }

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(\.query):
        guard !state.query.isEmpty else {
          state.itemList = []
          return .none
        }

        if state.query != state.fetchItem.value?.request.query {
          state.itemList = []
        }

        return .none

      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

      case .search(let query):
        guard !query.isEmpty else {
          return .none
        }
        state.fetchItem.isLoading = true

        return sideEffect
          .getItem(.init(query: query))
          .cancellable(pageID: pageID, id: CancelID.requestItem, cancelInFlight: true)

      case .fetchItem(let result):
        state.fetchItem.isLoading = false
        switch result {
        case .success(let item):
          if state.query == item.request.query {
            state.fetchItem.value = item
            state.itemList = item.response.albums
          }

          if state.itemList.isEmpty {
            sideEffect.useCase.toastViewModel.send(message: "검색 결과가 없습니다.")
          }
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .routeToDetail(let item):
        sideEffect.routeToDetail(item)
        return .none

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: HomeSideEffect

}
