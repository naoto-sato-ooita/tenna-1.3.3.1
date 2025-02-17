import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers
import UIKit

final class PreviewViewModel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var title: String?
    @Published var url: String?
    
    let previewURL: URL?
    
    init(_ url: String) {
        self.previewURL = URL(string: url)
        fetchMetadata()
    }
    
    func detectLinks(_ str: String) -> [NSTextCheckingResult] {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let d = detector {
            return d.matches(in: str, range: NSMakeRange(0, str.characters.count))
        } else {
            return []
        }
    }
    
    private func fetchMetadata() {
        guard let previewURL = previewURL else { return }
        let provider = LPMetadataProvider()
        
        Task {
            do {
                let metadata = try await provider.startFetchingMetadata(for: previewURL)
                image = try await convertToImage(metadata.imageProvider)
                title = metadata.title
                url = metadata.url?.host
            } catch {
                // Handle the error
                print(error.localizedDescription)
            }
        }
    }

    private func convertToImage(_ imageProvider: NSItemProvider?) async throws -> UIImage? {
        var image: UIImage?
        
        if let imageProvider = imageProvider {
            let type = String(describing: UTType.image)
            
            if imageProvider.hasItemConformingToTypeIdentifier(type) {
                let item = try await imageProvider.loadItem(forTypeIdentifier: type)
                
                if item is UIImage {
                    image = item as? UIImage
                }
                
                if item is URL {
                    guard let url = item as? URL,
                          let data = try? Data(contentsOf: url) else { return nil }
                    
                    image = UIImage(data: data)
                }
                
                if item is Data {
                    guard let data = item as? Data else { return nil }
                    
                    image = UIImage(data: data)
                }
            }
        }
        
        return image
    }
}
