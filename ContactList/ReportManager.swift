import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


final class ReportManager: ObservableObject {
    
    static let shared = ReportManager()
    
    func sendReport(selectedUid: String, reason: String,email : String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let reportCollectionRef = Firestore.firestore().collection("CustmerReport").document(currentUserId).collection("reports")
        
        let reportData: [String: Any] = [
            "target": selectedUid,
            "reason": reason,
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        reportCollectionRef.addDocument(data: reportData) { error in
            if let error = error {
                print("Error adding report: \(String(describing: error))")
            } else {
                print("Report added successfully")
            }
        }
    }
    
    func sendInquery(type: String,content: String,email: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        let inqueryCollectionRef = Firestore.firestore().collection("CustmerReport").document(currentUserId).collection("inquery")
        
        let inqueryData: [String: Any] = [
            "uid": currentUserId,
            "email": email,
            "type": type,
            "content": content,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        inqueryCollectionRef.addDocument(data: inqueryData) { error in
            if let error = error {
                print("Error adding inquery: \(String(describing: error))")
            } else {
                print("Inquery added successfully")
            }
        }
    }
}
