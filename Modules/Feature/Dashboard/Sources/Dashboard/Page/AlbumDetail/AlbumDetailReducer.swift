import _MusicKit_SwiftUI
import Architecture
import ComposableArchitecture
import Domain
import Foundation
import MusicKit

@Reducer
struct AlbumDetailReducer {

  // MARK: Lifecycle

  init(
    pageID: String = UUID().uuidString,
    sideEffect: AlbumDetailSideEffect)
  {
    self.pageID = pageID
    self.sideEffect = sideEffect
  }

  // MARK: Internal

  @ObservableState
  struct State: Equatable, Identifiable {

    // MARK: Lifecycle

    init(
      id: UUID = UUID(),
      item: Album)
    {
      self.id = id
      self.item = item
    }

    // MARK: Internal

    let id: UUID

    var item: Album

    var fetchItem: FetchState.Data<MusicEntity.AlbumDetail.Track.Response?> = .init(isLoading: false, value: .none)

    /// 앨범에 포함된 트랙들.
    var tracks: MusicItemCollection<Track>?

    /// - NOTE: 앨범 상세 뷰가 플레이어에 재생 대기열을 설정했을 때 `true`.
    var isPlaybackQueueSet = false

    var musicSubscription: MusicSubscription?

    /// 앨범 상세 뷰가 Apple Music에 대한 구독 제안을 표시할지 제어하는 상태.
    var isShowingSubscriptionOffer = false

    /// Apple Music 구독 제안의 옵션.
    var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default

  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getItem(Album)
    case fetchItem(Result<MusicEntity.AlbumDetail.Track.Response, CompositeErrorRepository>)

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
      case .binding:
        return .none

      case .teardown:
        return .concatenate(
          CancelID.allCases.map { .cancel(pageID: pageID, id: $0) })

      case .getItem(let item):
        state.fetchItem.isLoading = true
        return sideEffect
          .getItem(.init(album: item))
          .cancellable(pageID: pageID, id: CancelID.requestItem, cancelInFlight: true)

      case .fetchItem(let result):
        state.fetchItem.isLoading = false
        switch result {
        case .success(let item):
          state.fetchItem.value = item
          state.tracks = item.tracks
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .throwError(let error):
        sideEffect.useCase.toastViewModel.send(errorMessage: error.displayMessage)
        return .none
      }
    }
  }

  // MARK: Private

  private let pageID: String
  private let sideEffect: AlbumDetailSideEffect

}
