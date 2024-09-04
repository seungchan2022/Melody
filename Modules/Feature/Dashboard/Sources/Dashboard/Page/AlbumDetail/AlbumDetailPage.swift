import ComposableArchitecture
import Domain
import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage

struct AlbumDetailPage {

  // MARK: Internal

  @Bindable var store: StoreOf<AlbumDetailReducer>

  // MARK: Private

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어.
  private let player = ApplicationMusicPlayer.shared

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어의 상태.
  @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state

}

extension AlbumDetailPage {
  /// 앨범 상세 뷰가 Play/Pause 버튼을 비활성화해야 할 때 `true`.
  private var isPlayButtonDisabled: Bool {
    let canPlayCatalogContent = store.musicSubscription?.canPlayCatalogContent ?? false
    return canPlayCatalogContent
  }

  /// 앨범 상세 뷰가 사용자가 Apple Music 구독을 제안해야 할 때 `true`.
  /// 구독 상태이거나, 불가능 상태이면 false
  private var shouldOfferSubscription: Bool {
    let canBecomeSubscriber = store.musicSubscription?.canBecomeSubscriber ?? false
    return canBecomeSubscriber
  }

  /// - NOTE: 플레이어가 재생 중일 때 `true`.
  private var isPlaying: Bool {
    playerState.playbackStatus == .playing
  }

  /// 구독 제안의 표시 상태를 계산합니다.
  private func handleSubscriptionOfferButtonSelected() {
    store.subscriptionOfferOptions.messageIdentifier = .playMusic
    store.subscriptionOfferOptions.itemID = store.item.id
    store.isShowingSubscriptionOffer = true
  }

  /// - NOTE: 사용자가 트랙 목록에서 트랙을 탭할 때 수행할 작업.
  private func handleTrackSelected(_ track: Track, loadedTracks: MusicItemCollection<Track>) {
    player.queue = ApplicationMusicPlayer.Queue(for: loadedTracks, startingAt: track)
    store.isPlaybackQueueSet = true
    beginPlaying()
  }

  private func handlePlayButtonSelected() {
    if !isPlaying {
      if !store.isPlaybackQueueSet {
        player.queue = [store.item]
        store.isPlaybackQueueSet = true
        beginPlaying()
      } else {
        Task {
          do {
            try await player.play()
          } catch {
            print("재생을 다시 시작하는 데 실패했습니다: \(error).")
          }
        }
      }
    } else {
      player.pause()
    }
  }

  private func beginPlaying() {
    Task {
      do {
        try await player.play()
      } catch {
        print("재생 준비에 실패했습니다: \(error).")
      }
    }
  }
}

// MARK: View

extension AlbumDetailPage: View {
  var body: some View {
    ScrollView {
      /// header 뷰
      VStack {
        if let artwork = store.item.artwork {
          ArtworkImage(artwork, width: 320)
            .cornerRadius(8)
        }
        Text(store.item.artistName)
          .font(.title2.bold())

        HStack {
          Button(action: handlePlayButtonSelected) {
            HStack {
              Image(systemName: isPlaying ? "pause.fill" : "play.fill")
              Text(isPlaying ? "Pause" : "Play")
            }
            .padding(4)
            .frame(maxWidth: 200)
          }
          .disabled(!isPlayButtonDisabled)
          .buttonStyle(.borderedProminent)
          .animation(.easeIn(duration: 0.1), value: isPlaying)

          if shouldOfferSubscription {
            Button(action: handleSubscriptionOfferButtonSelected) {
              HStack {
                Image(systemName: "applelogo")
                Text("Join")
              }
              .padding(4)
              .frame(maxWidth: 200)
            }
            .buttonStyle(.borderedProminent)
          }
        }
        .padding(.horizontal, 16)
      }

      if let loadedTracks = store.trackItemList, !loadedTracks.isEmpty {
        LazyVStack(alignment: .leading, spacing: 8) {
          Text("TRACKS")
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)

          Divider()

          ForEach(loadedTracks) { item in
            TrackComponent(viewState: .init(item: item)) {
              handleTrackSelected(item, loadedTracks: loadedTracks)
            }
          }
        }
        .padding(.top, 32)
      }

      if let relatedAlbumList = store.relatedAlbumList, !relatedAlbumList.isEmpty {
        LazyVStack(alignment: .leading, spacing: 8) {
          Text("RELATED ALBUMS")
            .foregroundColor(.secondary)
            .padding(.horizontal, 16)

          Divider()

          ForEach(relatedAlbumList) { item in
            RelatedAlbumComponent(
              viewState: .init(item: item),
              tapAction: { store.send(.routeToDetail($0)) })
          }
        }
        .padding(.top, 32)
      }
    }
    // 적절한 시점에 구독 제안을 표시합니다.
    .musicSubscriptionOffer(isPresented: $store.isShowingSubscriptionOffer, options: store.subscriptionOfferOptions)
    .navigationTitle(store.item.title)
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      store.send(.getTrack(store.item))
      store.send(.getRelatedAlbum(store.item))
      store.send(.getSubscription)
    }
  }
}
