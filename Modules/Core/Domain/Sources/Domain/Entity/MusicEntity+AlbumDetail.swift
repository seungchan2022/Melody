import Foundation
import MusicKit

// MARK: - MusicEntity.AlbumDetail

extension MusicEntity {
  public enum AlbumDetail {
    public enum Track { }
    public enum RelatedAlbum { }
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

extension MusicEntity.AlbumDetail.RelatedAlbum {
  public struct Request: Equatable, Codable, Sendable {
    public let album: Album

    public init(album: Album) {
      self.album = album
    }
  }

  public struct Response: Equatable, Codable, Sendable {
    public let albums: MusicItemCollection<Album>

    public init(albums: MusicItemCollection<Album>) {
      self.albums = albums
    }
  }
}
