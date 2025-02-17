import SwiftUI
import LinkPresentation
import UniformTypeIdentifiers

struct FileLinkView: View {
    
    @ObservedObject var viewModel: PreviewViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 107, maxHeight: 107)
                    .clipped()
                    .cornerRadius(16)
            }
            
            VStack(alignment: .leading, spacing: 1, content: {
                if let title = viewModel.title {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
                
                if let url = viewModel.url {
                    Text(url)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
            })
            .padding(.top, 16)
            .padding(.bottom, 9)
            .padding(.trailing, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: 100)
    }
}

struct FileLinkView_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            Text("Preview")
            FileLinkView(
                viewModel: PreviewViewModel("https://qiita.com/shiz/items/93a33446f289a8a9b65d")
            )
        }
    }
}
