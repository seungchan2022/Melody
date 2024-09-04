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

    var fetchTrackItem: FetchState.Data<MusicEntity.AlbumDetail.Track.Response?> = .init(isLoading: false, value: .none)

    var fetchRelatedAlbum: FetchState.Data<MusicEntity.AlbumDetail.RelatedAlbum.Response?> = .init(isLoading: false, value: .none)

    /// 앨범에 포함된 트랙들.
    var trackItemList: MusicItemCollection<Track>?

    var relatedAlbumList: MusicItemCollection<Album>?

    /// - NOTE: 앨범 상세 뷰가 플레이어에 재생 대기열을 설정했을 때 `true`.
    var isPlaybackQueueSet = false

    ///    var musicSubscription: MusicSubscription?
    var musicSubscription: MusicEntity.Subscription.Response?

    /// 앨범 상세 뷰가 Apple Music에 대한 구독 제안을 표시할지 제어하는 상태.
    var isShowingSubscriptionOffer = false

    /// Apple Music 구독 제안의 옵션.
    var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default

    var fetchSubscription: FetchState.Data<MusicEntity.Subscription.Response?> = .init(isLoading: false, value: .none)
  }

  enum Action: Equatable, BindableAction {
    case binding(BindingAction<State>)
    case teardown

    case getTrack(Album)
    case fetchTrackItem(Result<MusicEntity.AlbumDetail.Track.Response, CompositeErrorRepository>)

    case getRelatedAlbum(Album)
    case fetchRelatedAlbum(Result<MusicEntity.AlbumDetail.RelatedAlbum.Response, CompositeErrorRepository>)

    case getSubscription
    case fetchSubscription(Result<MusicEntity.Subscription.Response, CompositeErrorRepository>)

    case routeToDetail(Album)

    case throwError(CompositeErrorRepository)
  }

  enum CancelID: Equatable, CaseIterable {
    case teardown
    case requestTrackItem
    case requestRelatedAlbum
    case requestSubscription
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

      case .getTrack(let item):
        state.fetchTrackItem.isLoading = true
        return sideEffect
          .getTrack(.init(album: item))
          .cancellable(pageID: pageID, id: CancelID.requestTrackItem, cancelInFlight: true)

      case .getRelatedAlbum(let item):
        state.fetchRelatedAlbum.isLoading = true
        return sideEffect
          .getRelatedAlbum(.init(album: item))
          .cancellable(pageID: pageID, id: CancelID.requestRelatedAlbum, cancelInFlight: true)

      case .getSubscription:
        state.fetchSubscription.isLoading = true
        return sideEffect
          .getSubscription()
          .cancellable(pageID: pageID, id: CancelID.requestSubscription, cancelInFlight: true)

      case .fetchTrackItem(let result):
        state.fetchTrackItem.isLoading = false
        switch result {
        case .success(let item):
          state.fetchTrackItem.value = item
          state.trackItemList = item.tracks
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchRelatedAlbum(let result):
        state.fetchRelatedAlbum.isLoading = false
        switch result {
        case .success(let item):
          state.fetchRelatedAlbum.value = item
          state.relatedAlbumList = item.albums
          return .none

        case .failure(let error):
          return .run { await $0(.throwError(error)) }
        }

      case .fetchSubscription(let result):
        state.fetchSubscription.isLoading = false
        switch result {
        case .success(let item):
          state.fetchSubscription.value = item
          state.musicSubscription = item
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
  private let sideEffect: AlbumDetailSideEffect

}
