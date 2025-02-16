//
//  CreateTipsView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2025/01/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct CreateTipsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = TipsViewModel.shared
    @StateObject private var imageManager = ImageManager.shared
    
    @State private var content = ""

    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedImageData: UIImage?
    
    private let userDefaults = UserDefaults.standard
    private let dailyTipsKey = "dailyTipsCount"
    private let dateKey = "lastTipsDate"
    private let maxDailyTips = 10
    
    private let dailyLimitKey = "dailyTipsCount"
    private let lastDateKey = "lastTipsDate"
    
    @State private var remainingTips: Int = 10
    @State private var showLimitAlert = false
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""


    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack {
                    HStack{
                        Text("List")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        Spacer()
                    }
                    .padding(.top,20)

                        // Bookmarked Tips List
                        List {
                            ForEach(viewModel.bookmarkedTips) { tip in
                                TipsCardView(isShow: .constant(true), tips: tip)
                                    .frame(height: 90)
                                    .listRowBackground(Color.clear)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    let tip = viewModel.bookmarkedTips[index]
                                    Task {
                                        await viewModel.toggleLike(for: tip.id)
                                        viewModel.bookmarkedTips.remove(at: index)
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                    
                    Divider()
                        .padding(.vertical)
                    
                    HStack{
                        Text("Create")
                            .font(.subheadline)
                            .foregroundStyle(fontColor.opacity(0.8))
                            .padding(.leading)
                        Spacer()
                    }
                    
                    TextField("Share your tips...", text: $content, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    if let selectedImageData = selectedImageData {
                        Image(uiImage: selectedImageData)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    } else {
                        
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            AsyncImage(url: nil) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .onChange(of: selectedImage) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    await MainActor.run {
                                        selectedImageData = uiImage
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    
                    Button {
                        saveTips()
                    } label: {
                        
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(content.isEmpty ? .gray : Color.black, lineWidth: 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundStyle(content.isEmpty ? .gray : sw_neg)
                                )
                                .frame(width: 300, height: 40)
                            
                            HStack {
                                Text("Share")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "flame")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .frame(width: 20,height: 20)
                            }
                        }
                        
                    }
                    .disabled(content.isEmpty || !canCreateTips())
                    
                    HStack{
                        Text("Remaining tips today:")
                        Text("\(remainingTips)")
                    }
                    .font(.caption)
                    .foregroundStyle(.gray)
                    
                    
                    
                }
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
                
                
                
            }
            .toolbarTitleDisplayMode(.inline)  // Add this line
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(backArrow)
                                .frame(width: 40,height: 40)
                        }
                    ).tint(.black)
                }
                ToolbarItem(placement: .principal) {
                    Text("Tips")
                        .font(.custom(fontx, size: 22))
                        .foregroundStyle(fontColor)
                        .fontWeight(.thin)
                }
                
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(White2,for: .navigationBar)

        }
        .disabled(isLoading)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            checkAndUpdateDailyLimit()
            viewModel.loadBookmarkedTips()
        }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You can create up to 10 tips per day.")
        }
    }
    
    private func canCreateTips() -> Bool {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let lastDate = userDefaults.object(forKey: dateKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDate(currentDate, inSameDayAs: lastDate) {
            userDefaults.set(0, forKey: dailyTipsKey)
            userDefaults.set(currentDate, forKey: dateKey)
            return true
        }
        
        let currentCount = userDefaults.integer(forKey: dailyTipsKey)
        return currentCount < maxDailyTips
    }
    
    private func saveTips() {
        isLoading = true
        let currentCount = UserDefaults.standard.integer(forKey: dailyLimitKey)
        
        if currentCount >= maxDailyTips {
            showLimitAlert = true
            return
        }
        
        Task {
            do {
                try await viewModel.createTips(content: content, image: selectedImage)
                
                // Update UserDefaults on main thread
                DispatchQueue.main.async {
                    let currentCount = UserDefaults.standard.integer(forKey: dailyLimitKey)
                    UserDefaults.standard.set(currentCount + 1, forKey: dailyLimitKey)
                    isLoading = false
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    showError = true
                    isLoading = false
                }
            }
        }
    }
    
    private func checkAndUpdateDailyLimit() {
        let currentDate = Calendar.current.startOfDay(for: Date())
        let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date ?? Date.distantPast
        
        if !Calendar.current.isDate(currentDate, inSameDayAs: lastDate) {
            UserDefaults.standard.set(currentDate, forKey: lastDateKey)
            UserDefaults.standard.set(0, forKey: dailyLimitKey)
        }
        
        let currentCount = UserDefaults.standard.integer(forKey: dailyLimitKey)
        remainingTips = maxDailyTips - currentCount
    }
}
