
import AVKit
import PhotosUI
import SwiftUI
enum NetworkError: Error {
    case operationFailed
}
struct UserList: Identifiable {
    var id: String
    var isFollowing = false
}
struct Movie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")

            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }

            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}
func clear(){
 
}
struct ContentView: View {
    @State var vm = AdministradordeArchivo()
    enum Descarga<T: Codable & Equatable>: Equatable{
        case nada
        case bajando
        case bien(String)
        case error(Error)
        static func == (lhs: Descarga<T>, rhs: Descarga<T>) -> Bool {
            switch (lhs, rhs) {
            case (.nada, .nada), (.bajando, .bajando):
                return true
            case let (.bien(lhsValue), .bien(rhsValue)):
                return lhsValue == rhsValue
            case let (.error(lhsError), .error(rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    enum LoadState {
           case unknown, loading, loaded(Movie), failed
       }
    @State private var selectedItem: PhotosPickerItem?
      @State private var loadState = LoadState.unknown
    @State private var descarga : Descarga<String> = .nada
    @State private var isOn = false
    @State var lists = [
    UserList(id: "wifi", isFollowing: false),
    UserList(id: "History", isFollowing: false),
    UserList(id: "Privacy", isFollowing: false),
    UserList(id: "Data", isFollowing: false),
    UserList(id: "Todo", isFollowing: false)]
    var body: some View {
        VStack{
            
            switch descarga {
            case .nada:
            EmptyView()
            case .bajando:
                ProgressView("Bajando")
            case .bien(let algo):
                HStack{
                
                    if isOn {
                       
                        Text(algo)
                    } else{ Text("OFFLINE")}
                
                }
                Toggle(isOn: $isOn ) {
                    Text("Connectar")}.foregroundColor(.blue)
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                
                Form {
                       Section {
                           Text("Settings")
                       }
                       Section("On or OFF Devices") {
                           ForEach($lists) { $list in
                               Toggle(list.id, isOn: $list.isFollowing)
                                   .foregroundColor(.red)
                                   .toggleStyle(SwitchToggleStyle(tint: .blue))
                           }
                       }
                       Section("Options") {
                           Toggle("Todos ", sources: $lists, isOn: \.isFollowing)
                               .foregroundColor(.red)
                               .toggleStyle(SwitchToggleStyle(tint: .blue))
                       }
                   }.padding()
               
                VStack {
                    
                           PhotosPicker("Select movie", selection: $selectedItem, matching: .videos)

                           switch loadState {
                           case .unknown:
                               EmptyView()
                           case .loading:
                               ProgressView("Descargando⤵")
                           case .loaded(let movie):
                               Text("loaded \(movie)")
                               VideoPlayer(player: AVPlayer(url: movie.url))
                                   .scaledToFit()
                                   .frame(width: 300, height: 300)
                               Button(action:{ 
                                   loadState = .unknown
                               } , label: {Text("Clear")})
                           case .failed:
                               Text("Import failed")
                           }
                       }
                .onChange(of: selectedItem) {
                    Task {
                                    do {
                                        loadState = .loading

                                        if let movie = try await selectedItem?.loadTransferable(type: Movie.self) {
                                            loadState = .loaded(movie)
                                         
                                            
                                        } else {
                                            loadState = .failed
                                        }
                                    } catch {
                                        loadState = .failed
                                    }
                                }
                }
                
            case .error(let error):
                Text(error.localizedDescription)
                    .foregroundStyle(Color(.red))
            }
            Button(action: {
                descarga = .bajando
            
            }, label: {
                Text("timeout")
            }).buttonStyle(.borderedProminent)
            
                .task(id: descarga) {
                    if descarga == .bajando{
                        do{
                            
                            let algo =  try await vm.tiempodeconsumo() 
                            descarga = .bien(algo)
                           
                                
                            
                        }
                       
                        catch{
                              descarga = .error(error)
                            }
                    }
                }
        }
        
    }
}
#Preview {
    ContentView()
}
