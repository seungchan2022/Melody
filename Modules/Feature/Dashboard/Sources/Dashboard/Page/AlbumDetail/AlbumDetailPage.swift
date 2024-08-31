import ComposableArchitecture
import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage

struct AlbumDetailPage {

  // MARK: Internal

  @Bindable var store: StoreOf<AlbumDetailReducer>

  /// 이 앨범에 포함된 트랙들.
  @State var tracks: MusicItemCollection<Track>?

  // MARK: Private

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어.
  private let player = ApplicationMusicPlayer.shared

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어의 상태.
  @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state

  /// - NOTE: 앨범 상세 뷰가 플레이어에 재생 대기열을 설정했을 때 `true`.
  @State private var isPlaybackQueueSet = false

  @State private var musicSubscription: MusicSubscription?

  /// 앨범 상세 뷰가 Apple Music에 대한 구독 제안을 표시할지 제어하는 상태.
  @State private var isShowingSubscriptionOffer = false

  /// Apple Music 구독 제안의 옵션.
  @State private var subscriptionOfferOptions: MusicSubscriptionOffer.Options = .default

}

extension AlbumDetailPage {
  /// 앨범 상세 뷰가 Play/Pause 버튼을 비활성화해야 할 때 `true`.
  private var isPlayButtonDisabled: Bool {
    let canPlayCatalogContent = musicSubscription?.canPlayCatalogContent ?? false
    return !canPlayCatalogContent
  }

  /// 앨범 상세 뷰가 사용자가 Apple Music 구독을 제안해야 할 때 `true`.
  /// 구독 상태이거나, 불가능 상태이면 false
  private var shouldOfferSubscription: Bool {
    let canBecomeSubscriber = musicSubscription?.canBecomeSubscriber ?? false
    return canBecomeSubscriber
  }

  /// - NOTE: 플레이어가 재생 중일 때 `true`.
  private var isPlaying: Bool {
    playerState.playbackStatus == .playing
  }

  /// 구독 제안의 표시 상태를 계산합니다.
  private func handleSubscriptionOfferButtonSelected() {
    subscriptionOfferOptions.messageIdentifier = .playMusic
    subscriptionOfferOptions.itemID = store.item.id
    isShowingSubscriptionOffer = true
  }

  /// - NOTE: 사용자가 트랙 목록에서 트랙을 탭할 때 수행할 작업.
  private func handleTrackSelected(_ track: Track, loadedTracks: MusicItemCollection<Track>) {
    player.queue = ApplicationMusicPlayer.Queue(for: loadedTracks, startingAt: track)
    isPlaybackQueueSet = true
    beginPlaying()
  }

  private func handlePlayButtonSelected() {
    if !isPlaying {
      if !isPlaybackQueueSet {
        player.queue = [store.item]
        isPlaybackQueueSet = true
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

  /// 트랙 가져옴
  private func loadTracksAndRelatedAlbums() async throws {
    let detailedAlbum = try await store.item.with([.tracks])
    update(tracks: detailedAlbum.tracks)
  }

  @MainActor
  private func update(tracks: MusicItemCollection<Track>?) {
    withAnimation {
      self.tracks = tracks
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
          .disabled(isPlayButtonDisabled)
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

      if let loadedTracks = tracks, !loadedTracks.isEmpty {
        LazyVStack {
          ForEach(loadedTracks) { item in
            ItemComponent(viewState: .init(item: item)) {
              handleTrackSelected(item, loadedTracks: loadedTracks)
            }
          }
        }
        .padding(.top, 32)
      }
    }
    // 뷰가 나타날 때, 트랙과 관련된 앨범을 비동기적으로 로드합니다.
    .task {
      try? await loadTracksAndRelatedAlbums()
    }
    // 음악 구독 상태의 변경을 관찰하기 시작합니다.
    .task {
      for await subscription in MusicSubscription.subscriptionUpdates {
        musicSubscription = subscription
      }
    }
    // 적절한 시점에 구독 제안을 표시합니다.
    .musicSubscriptionOffer(isPresented: $isShowingSubscriptionOffer, options: subscriptionOfferOptions)
    .navigationTitle(store.item.title)
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      store.send(.getItem(store.item))
    }
  }
}
