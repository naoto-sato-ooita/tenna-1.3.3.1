//
//  CircularProfileImageView.swift
//  air
//
//  Created by Naoto Sato on 2024/03/24.
//

import SwiftUI

struct ProfileImageView: View {
    
    //@EnvironmentObject var image_manager : ImageManager
    //@State private var uiImage: UIImage? = nil
    var user :User?
    let size: ProfileImageSize
    
    var body: some View {
        ImageContainer {
            if let urlString = user?.pathUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.dimension, height: size.dimension)
                        .clipShape(Circle())
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: size.dimension, height: size.dimension)
                        .foregroundStyle(profileBack)
                }
            }
        }
    }
}

struct ImageContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
    }
}



enum ProfileImageSize{
    case xxSmall
    case xSmall
    case small
    case medium
    case large
    case xlarge
    
    var dimension: CGFloat{
        switch self {
        case .xxSmall: return 28
        case .xSmall: return 32
        case .small: return 40
        case .medium: return 56
        case .large: return 64
        case .xlarge: return 80
        }
    }
}

#Preview {
    ProfileImageView(user: UserService.shared.currentUser ?? User.MOCK_USER,size: .medium)
}
