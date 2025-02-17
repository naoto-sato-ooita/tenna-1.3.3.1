//
//  MapView.swift
//  Tenna2
//
//  Created by Naoto Sato on 2024/04/15.
//

import SwiftUI
import MapKit
import Firebase
import GoogleMobileAds

struct MapView: View {
    
    // MARK: - ViewModel
    @EnvironmentObject var authviewModel: AuthManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @ObservedObject var locationManager = LocationManager.shared
    
    @StateObject private var viewSetModel = SettingViewModel.shared
    @StateObject private var groupviewModel = GroupViewModel.shared
    @StateObject private var tipsViewModel = TipsViewModel.shared
    @StateObject private var flowLineViewModel = FlowLineViewModel.shared
    
    // MARK: - Map States
    @State private var cameraPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .camera(MapCamera(centerCoordinate: .userLocation, distance: 50, pitch: 10)))
    @State private var mapRegion: MKCoordinateRegion = .userRegion
    @State private var showMap: Bool = true
    
    // MARK: - Tips States
    @State private var selectedTip: Tips? = nil

    @State private var isShow: Bool = false
    
    // MARK: - Search States
    @State private var isMode: Bool = false
    @Binding var isSearch: Bool
    @State private var isWaiting: Bool = false
    @State private var isAvailable: Bool = true
    @State private var didRotateBeyondThreshold: Bool = false
    
    // MARK: - Timer States
    @State private var timerRunCount: Int = 0
    @State private var timer: Timer?
    @State private var progress: Double = 0.0
    let timerLimit: Int = 10
    
    // MARK: - Animation States
    @State private var isAnimating: Bool = false
    @State private var startAnimation: Bool = false
    @State private var fadeAnimation1: Bool = false
    @State private var fadeAnimation2: Bool = false
    @State private var fadeAnimation3: Bool = false
    
    
    
    // MARK: - FlowLine States
    @State private var selectedAnnotations: [RouteAnnotation] = [] //編集時の並べ替え用、ベースはviewModel参照
    @State var isEditFlow: Bool = false
    @State private var showSaveAlert = false
    @State private var routes: [MKRoute] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 28.52128004667111,
            longitude: 83.0506863753693
        ),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isSelectedAnno = false
    @State private var isEditOK = false
    
    let back = AngularGradient(gradient: Gradient(colors: [.black,White2,.black,.black,White2,.black,.black])
                               ,center: .center, angle: .degrees(-45))
    @State private var isMenu = false
    
    let user : User
    

    
    var body: some View {
        NavigationStack{
            VStack{
                
                Map(position: $cameraPosition) {
                    ForEach(tipsViewModel.aroundTips) { tip in
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: tip.lat, longitude: tip.lng)) {
                            TipsAnnotationView(isSelected: .constant(selectedTip?.id == tip.id), tip: tip)
                                .onTapGesture {
                                    selectedTip = tip
                                    isShow = true
                                }
                        }
                    }
                    ForEach(flowLineViewModel.annotations) { annotation in
                        Annotation("", coordinate: annotation.coordinate) {
                            ZStack{
                                AnnotationView(
                                    annotation: annotation,
                                    isSelectedAnno: $isSelectedAnno,
                                    isEditOK: $isEditOK
                                )
                                
                                if isEditOK {
                                    VStack(spacing: -5) {
                                        ForEach(selectedAnnotations.indices.filter { selectedAnnotations[$0].id == annotation.id }, id: \.self) { index in
                                            Circle()
                                                .fill(new_yellow)
                                                .frame(width: 24, height: 24)
                                                .overlay(
                                                    Text("\(index + 1)")
                                                        .foregroundColor(.black)
                                                        .font(.body)
                                                        .fontWeight(.bold)
                                                )
                                                .offset(x: 20, y: -20)
                                                .zIndex(Double(index))
                                        }
                                    }
                                }
                            }
                            
                            .onTapGesture {
                                isSelectedAnno = true
                                if isEditOK {
                                    handleAnnotationTap(annotation)
                                    
                                }
                            }
                        }
                        // In Map content
                        if !isEditOK {
                            let orderedAnnotations = flowLineViewModel.annotations
                                .sorted { $0.orders.first ?? 0 < $1.orders.first ?? 0 }
                                .filter { !$0.orders.isEmpty }
                            
                            if orderedAnnotations.count >= 2 {
                                ForEach(0..<orderedAnnotations.count - 1, id: \.self) { index in
                                    MapPolyline(coordinates: [
                                        orderedAnnotations[index].coordinate,
                                        orderedAnnotations[index + 1].coordinate
                                    ])
                                    .stroke(.gray, style: StrokeStyle(
                                        lineWidth: 1,
                                        dash: [2, 5]
                                    ))
                                    
                                }
                            }
                            
                        }
                        
                        // Show lines for current selection when editing
                        if isEditOK && selectedAnnotations.count >= 2 {
                            ForEach(0..<selectedAnnotations.count - 1, id: \.self) { index in
                                MapPolyline(coordinates: [
                                    selectedAnnotations[index].coordinate,
                                    selectedAnnotations[index + 1].coordinate
                                ])
                                .stroke(.gray, style: StrokeStyle(
                                    lineWidth: 1,
                                    dash: [2, 5]
                                ))
                                
                                
                            }
                        }
                        
                    }
                    
                    
                    
                    Annotation("",coordinate: locationManager.userLocation) {
                        Circle()
                            .stroke(Color(new_yellow), lineWidth: (isAnimating ? 20 : 0))
                            .frame(width: 100, height: 100)
                            .scaleEffect(isAnimating ? 2 : 1)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(_:Animation.easeOut(duration: 1)
                                .repeatCount(10, autoreverses: true),
                                       value: isAnimating
                            )
                    }
                }
                
                .mapControls {
                    MapUserLocationButton()
                }
                
              
                .overlay(alignment: .bottomTrailing) {
                    VStack {
                        if isMenu {
                            PlusView(isMenu: $isMenu,isEditFlow: $isEditFlow)
                        }
                        
                    }
                    .padding(.bottom, 20)
                    .padding(.trailing, 20)
                }
                .overlay(alignment: .bottomTrailing) {
                    VStack{
                        if isEditFlow {
                            
                            if !isEditOK {
                                ZStack{
                                    Capsule()
                                    .foregroundStyle(White)
                                    .frame(width:50,height:40)
                                        
                                    Button {
                                        isEditOK = true
                                    } label: {
                                        CommonButton(icon: "pencil.line")
                                    }
                                }
                            } else {
                                
                                ZStack{
                                    Capsule()
                                    .foregroundStyle(White)
                                    .frame(width:140,height:40)
                                    
                                    HStack(spacing: 10){
                                        Spacer()
                                        Button {
                                            isEditOK.toggle()
                                            isEditFlow = false
                                        } label: {
                                            CommonButton(icon: "chevron.down")
                                        }
                                        
                                        Button {
                                            selectedAnnotations.removeAll()
                                            routes.removeAll()
                                            Task{
                                                if let userId = Auth.auth().currentUser?.uid {
                                                    try await flowLineViewModel.deleteFlowLine(userId: userId)
                                                }
                                            }
                                            isEditOK.toggle()
                                            isEditFlow = false
                                        } label: {
                                            CommonButton(icon: "trash")
                                                .foregroundStyle(.red)
                                        }
                                        
                                        
                                        Button {
                                            isEditOK.toggle()
                                            isEditFlow = false
                                            Task {
                                                if let userId = Auth.auth().currentUser?.uid {
                                                    try? await flowLineViewModel.saveFlowLine(
                                                        userId: userId,
                                                        orderedAnnotations: selectedAnnotations.isEmpty ? flowLineViewModel.annotations : selectedAnnotations
                                                    )
                                                    // Add this to refresh the displayed orders
                                                    await flowLineViewModel.loadFlowLine(userId: userId)
                                                    showSaveAlert = true
                                                }
                                            }
                                        } label: {
                                            CommonButton(icon: "square.and.arrow.down")
                                        }
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(.bottom, 110)
                    .padding(.trailing, 30)



                }

                
                .overlay(alignment: .bottomLeading){
        
                        ZStack(alignment: .center){
                            
                            Circle()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .foregroundStyle(back)
                                .simpleRotation(didRotateBeyondThreshold: $didRotateBeyondThreshold)
                            
                            
//                            Button{
//                                isMode = true
//                            } label : {
//                                ZStack{
//                                    Capsule()
//                                        .frame(width: 90, height: 16)
//                                        .foregroundStyle(.white)
//                                    
//                                    
//                                    Capsule()
//                                        .frame(width: 80, height: 6)
//                                        .foregroundStyle(isSearch ? .green : .red)
//                                }
//                                .rotationEffect(Angle(degrees: 45))
//                            }
//                            .offset(x: 40, y: 45)
                            
                            Button{
                                isMenu.toggle()
                            } label:{
                                ZStack{
                                    Circle()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .foregroundStyle(White)
                                    
                                    Circle()
                                        .scaledToFill()
                                        .frame(width: 58, height: 58)
                                        .foregroundStyle(new_yellow)
                                    
                                    Image(systemName: "line.horizontal.3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundStyle(.black)
                                    
                                }
                            }

                        }
                        .offset(x: -40,y:0)
                    
                    
                
                }
               

                if purchaseManager.isPremium { //本番は！なし
                    
                } else {
                    AdMobBannerView()
                        .frame(width: 320, height: 50)
                }
            }
            .alert("Route Saved", isPresented: $showSaveAlert) {
                Button("OK") { }
            } message: {
                Text("Your route has been saved successfully.")
            }
            .onChange(of: isEditFlow) { _ in
                updateMapDisplay()
            }
            .sheet(isPresented: $isShow) {
                if isShow {
                    TipsDetailView(isShow: $isShow, tips: selectedTip!)
                        .presentationBackground(Color.clear)
                        .presentationDetents([.height(400)])
                }
            }
            .onChange(of: didRotateBeyondThreshold) {
                
                if isSearch && isAvailable {
                    
                    self.searchTip()
                    self.isAnimating.toggle()
                    self.startTimer()
                    
                } else if isSearch && !isAvailable {
                    isWaiting = true
                }
            }
            
            .onAppear {
                mapRegion = MKCoordinateRegion(center: .userLocation,
                                               latitudinalMeters: 100,
                                               longitudinalMeters: 100)
            }
            
            .onChange(of: locationManager.isLocationAuthorized) { _, _ in
                showMap = true
            }
            
            .alert("Now loading...",isPresented: $isWaiting) {
                Button("Confirm",role: .cancel) {}
            }
            
//            .confirmationDialog("Select Mode", isPresented: $isMode, titleVisibility: .visible) {
//                
//                Button("Search") {
//                    isSearch = true
//                }
//                Button("Lock") {
//                    isSearch = false
//                }
//                Button("Cancel",role: .cancel) {
//                }
//            }

        }
    }
    private func startTimer() {
        
        //Reset
        timer?.invalidate()
        timerRunCount = 0
        
        //Set
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {  _ in
            self.timerRunCount += 1
            self.progress = Double(self.timerRunCount) / Double(timerLimit)
            
            if self.timerRunCount == timerLimit {
                self.progress = 0.0
                self.timer?.invalidate()
                self.isAvailable = true
                
            } else {
                self.isAvailable = false
            }
        }
        
    }
    private func saveFlowLine() {
        Task {
            if let userId = Auth.auth().currentUser?.uid {
                // Update orders based on selection sequence
                let updatedAnnotations = selectedAnnotations.enumerated().map { index, annotation in
                    var updatedAnnotation = annotation
                    updatedAnnotation.orders.append(index)
                    return updatedAnnotation
                }
                
                try? await flowLineViewModel.saveFlowLine(
                    userId: userId,
                    orderedAnnotations: updatedAnnotations
                )
                showSaveAlert = true
            }
        }
    }
    private func performAnimation() {
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) { //元のまま
            startAnimation = true
        }
        
        withAnimation(.linear(duration: 0.7)
            .delay((1.5/360) * (90 - 105))
            .repeatForever(autoreverses: true)) {
                fadeAnimation1 = true
            }
        
        withAnimation(.easeInOut(duration: 0.7)
            .delay((1.5/360) * (90 - 80))
            .repeatForever(autoreverses: true)) {
                fadeAnimation2 = true
            }
        
        withAnimation(.linear(duration: 0.5)
            .delay((1.5/360) * (90 - 25))
            .repeatForever(autoreverses: true)) {
                fadeAnimation3 = true
            }
        
    }
    private func searchTip(){
        
        let radiusInM: Double = purchaseManager.isPremium ? 1000 : 300
        let numUser: Int = purchaseManager.isPremium ? 10 : 3
        Task{
            await tipsViewModel.searchTips(center: locationManager.userLocation, radiusInM: radiusInM, targetNum: numUser)
        }
    }
    // カメラ位置参照アノテーションを読み込んだベースAnnotationsの位置に変更
    private func updateMapDisplay() {
        withAnimation {
            if let firstAnnotation = flowLineViewModel.annotations.first { // 最初の要素を指定
                cameraPosition = .region(MKCoordinateRegion(
                    center: firstAnnotation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }
    
    

    private func handleAnnotationTap(_ annotation: RouteAnnotation) {
        selectedAnnotations.append(annotation)
        if selectedAnnotations.count >= 2 {
            calculateRoute(
                from: selectedAnnotations[selectedAnnotations.count - 2],
                to: selectedAnnotations[selectedAnnotations.count - 1]
            )
        }
    }

    private func calculateRoute(from: RouteAnnotation, to: RouteAnnotation) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to.coordinate))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else { return }
            DispatchQueue.main.async {
                self.routes.append(route)
            }
        }
    }
}

struct CircleProgressView: View {
    var progress: Double
    
    var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(new_yellow, style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .rotationEffect(.degrees(-90))
            .frame(width: 130, height: 130)
    }
}

extension CGSize {
    func convert(coordinate: CLLocationCoordinate2D, in region: MKCoordinateRegion) -> CGPoint {
        let latitude = (coordinate.latitude - region.center.latitude) / region.span.latitudeDelta
        let longitude = (coordinate.longitude - region.center.longitude) / region.span.longitudeDelta
        
        return CGPoint(
            x: width * (0.5 + longitude),
            y: height * (0.5 - latitude)
        )
    }
}

struct CommonButton: View {
    let icon: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    panelContent
                }
            } else {
                panelContent
            }
        }
    }
    
    private var panelContent: some View {
//        ZStack{
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.black, lineWidth: 2)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .foregroundStyle(White)
//                )
//                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(.black)
        //}
    }
}
