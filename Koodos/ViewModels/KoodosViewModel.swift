//
//  BmiViewModel.swift
//  SampleFirebase
//
//  Created by Rizki Samudra on 24/03/23.
//


import SwiftUI
import Foundation
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift

class KoodosViewModel: ObservableObject  {
    
    let storage = Storage.storage() // Define Storage Firestore
    @Published var imageFirebases = [ImageFirebase]() // Reference to our Model
    @Published var isFetch: Bool = false // check if fetch in progress
    private var databaseReference = Firestore.firestore().collection("ImagesFirebase") // reference to our Firestore's collection

    func upload(image: UIImage) {
        isFetch = true
        
        let fileName = "image\(Date().currentTimeMillis()).jpg"
        let storageRef = storage.reference().child("images/\(fileName)")


        // Convert the image into JPEG and compress the quality to reduce its size
        let data = image.jpegData(compressionQuality: 0.9)

        // Change the content type to jpg. If you don't, it'll be saved as application/octet-stream type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"

        // Upload the image
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }

                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
                
                storageRef.downloadURL(completion: { (url, error) in
                    self.isFetch = false
                    self.databaseReference.addDocument(data: ["imageUrl":url?.absoluteString ?? "","createdTime": Timestamp(date: Date())])
//                    self.fetchDataImagesFireStore()
                })
                                       
            }
         
        }
        
    }
    
        //fetch data
    func fetchDataImagesFireStore() {
        databaseReference.order(by: "createdTime", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.imageFirebases = documents.compactMap { queryDocumentSnapshot -> ImageFirebase? in
                
                return try? queryDocumentSnapshot.data(as: ImageFirebase.self)
            }
        }

    }

        // You can use the listItem() function above to get the StorageReference of the item you want to delete
    func deleteItem(item: StorageReference) {
        item.delete { error in
            if let error = error {
                print("Error deleting item", error)
            }
        }
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
