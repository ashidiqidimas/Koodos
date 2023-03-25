//
//  ImageFirebase.swift
//  SampleFirebase
//
//  Created by Rizki Samudra on 24/03/23.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ImageFirebase: Codable {
    @DocumentID var id: String? // @DocumentID to fetch the identifier from Firestore
    var imageUrl: String?
    @ServerTimestamp var createdTime: Timestamp?

    
}
