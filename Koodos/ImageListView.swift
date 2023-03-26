//
//  ListView.swift
//  SampleFirebase
//
//  Created by Rizki Samudra on 24/03/23.
//

import SwiftUI
import Kingfisher
import FirebaseFirestoreSwift
struct ImageListView: View {
    //viewModel
    @ObservedObject var viewModel: KoodosViewModel
    @State var animate: Bool = false
    @State var isDetail: Bool = false
    @State var isDetailAR: Bool = false
    
    //sample random image
    var images = ["sample_image1","sample_image2","sample_image3"]
    
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                
                List {
                    ForEach(viewModel.imageFirebases, id: \.id) { item in
                        VStack {
                            // load url image
                            KFImage(URL(string: item.imageUrl ?? ""))
                                .setProcessor(RoundCornerImageProcessor(cornerRadius: 8))
                                .resizable().scaledToFit()
                              
                        }
                        
                        .cornerRadius(8)
                        .listRowSeparator(.hidden)
                        .overlay{
                            RoundedRectangle(cornerRadius: 16, style: .circular).stroke(.black, lineWidth: 7)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .background(.clear)
                    
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .animation(.default)
                
                if(viewModel.isFetch){
                    //Loading View
                    ProgressView("Uploading…")
                }else{
                    VStack(alignment: .trailing) {
                        
                        NavigationLink(destination: ARContentView(cards: viewModel.imageForAR),isActive: $isDetailAR, label: {
                            Button(action: {
                                // open AR View
                                
                                isDetailAR = true
                            }){
                                Text("Open in AR")
                                    .font(.system(size: 17,weight: .heavy))
                                    .frame(minWidth: 0, maxWidth: 150,alignment: .center)
                                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 17)
                                            .stroke(Color.black, lineWidth: 7)
                                    )
                            }
                            .background(Color.orange)
                            .cornerRadius(17)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                        })
                        
                        NavigationLink(destination: KudosEditorScreen(viewModel: viewModel),isActive: $isDetail, label: {
                            
                            Button(action: {
                                // save random image to firebase server
//                                if let randomImage = images.randomElement() {
//                                    print(randomImage)
//                                    self.viewModel.upload(image: UIImage(named: randomImage)!)
//                                }
                                isDetail = true
                            }){
                                Text("Create New Koodos")
                                    .font(.system(size: 17,weight: .heavy))
                                    .frame(minWidth: 0, maxWidth: 200,alignment: .center)
                                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 17)
                                            .stroke(Color.black, lineWidth: 7)
                                    )
                            }
                            .background(Color.yellow)
                            .cornerRadius(17)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                        })
                    }
                    
                }
                
            }
            .padding(EdgeInsets())
            .background(.yellow)
            .onAppear{
                // fetchdata server
                self.viewModel.fetchDataImagesFireStore()
                
            }
            
            .navigationTitle("Koodos")
            
        }
        
        
    }
    
}

struct ImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ImageListView(viewModel: KoodosViewModel())
    }
}
