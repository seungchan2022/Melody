import Foundation
import MusicKit

// MARK: - MusicEntity.AlbumDetail

extension MusicEntity {
  public enum AlbumDetail {
    public enum Track { }
  }
}

extension MusicEntity.AlbumDetail.Track {
  public struct Request: Equatable, Codable, Sendable {
    public let album: Album

    public init(album: Album) {
      self.album = album
    }
  }

  public struct Response: Equatable, Codable, Sendable {
    public let tracks: MusicItemCollection<Track>?

    public init(tracks: MusicItemCollection<Track>? = .none) {
      self.tracks = tracks
    }
  }
}
