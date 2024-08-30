import ComposableArchitecture
import MusicKit
import SwiftUI

// MARK: - AlbumDetailPage

struct AlbumDetailPage {
  @Bindable var store: StoreOf<AlbumDetailReducer>

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어.
  private let player = ApplicationMusicPlayer.shared

  /// - NOTE: Apple Music 재생을 위한 MusicKit 플레이어의 상태.
  @ObservedObject private var playerState = ApplicationMusicPlayer.shared.state

  /// - NOTE: 앨범 상세 뷰가 플레이어에 재생 대기열을 설정했을 때 `true`.
  @State private var isPlaybackQueueSet = false

  @State private var musicSubscription: MusicSubscription?

  @State var tracks: MusicItemCollection<Track>?
}

extension AlbumDetailPage {
  /// - NOTE: 플레이어가 재생 중일 때 `true`.
  private var isPlaying: Bool {
    playerState.playbackStatus == .playing
  }

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
          .buttonStyle(.borderedProminent)
        }
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
    .task {
      try? await loadTracksAndRelatedAlbums()
    }
    .navigationTitle(store.item.title)
    .navigationBarTitleDisplayMode(.large)
    .onAppear {
      store.send(.getItem(store.item))
    }
  }
}
