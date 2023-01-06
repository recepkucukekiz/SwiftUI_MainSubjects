//
//  ContentView.swift
//  ApiTest
//
//  Created by Recep Küçükekiz on 6.01.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var network : Network
    @State var addItem = false
    
    var body: some View {
        NavigationView{
            VStack {
                List{
                    ForEach(Array(network.todos.enumerated()), id: \.1){ i,item in
                        NavigationLink{
                            DetailPage(todoItem: item, todoIndex: i)
                        } label: {
                            Text(item.title)
                        }
                    }
                    .onDelete { (set) in
                        network.todos.remove(atOffsets: set)
                    }
                }
                Button("Verileri çek"){
                    network.getTodos()
                }
            }
            .navigationTitle("Deneme")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.addItem.toggle()
            }, label: {Image(systemName: "plus")}))
            .sheet(isPresented: $addItem){
                AddPage(addItem:$addItem)
            }
        }
        .onAppear{
            network.getTodos()
        }
    }
}

struct AddPage : View {
    @EnvironmentObject var network : Network
    @State var txt = ""
    @Binding var addItem : Bool
    var body: some View {
        VStack {
            TextField("Enter Todo", text: $txt)
                .padding(.all)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            Button("Kaydet") {
                let newTodo = Todo(id: 0, userId: 0, title: txt, completed: true)
                network.todos.insert(newTodo, at: 0)
                addItem.toggle()
            }
        }
        .padding(.all)
    }
}

struct DetailPage: View {
    @EnvironmentObject var network : Network
    var todoItem: Todo
    var todoIndex: Int
    @State var txt = ""
    
    var body: some View {
        VStack {
            Text("ID:" + String(todoItem.id))
            Text("User ID:" + String(todoItem.userId))
            if (todoItem.completed){
                Image(systemName: "plus")
                    .padding(.all)
            } else {
                Image(systemName: "minus")
                    .padding(.all)
            }
            TextField(todoItem.title, text:$txt)
                .padding(.all)
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            
            Button("Save") {
                network.todos[todoIndex] = Todo(id: todoItem.id, userId: todoItem.userId, title: txt, completed: todoItem.completed)
            }
        }
        .padding(.all)
    }
}

class Network: ObservableObject {
    @Published var todos : [Todo] = []
    
    func getTodos() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos") else {
            fatalError("Missing URL")
        }
        
        let urlRequest = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) {
            (data, response, error) in
            if let error = error {
                print("Request Error", error)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {return}
            
            if response.statusCode == 200 {
                guard let data = data else {return}
                
                DispatchQueue.main.async {
                    do {
                        let decoded = try JSONDecoder().decode([Todo].self, from: data)
                        self.todos = decoded
                    } catch let error {
                        print("Error", error)
                        
                    }
                }
            }
            
        }
        dataTask.resume()
    }
}

struct Todo: Identifiable, Decodable, Hashable{
    var id: Int
    var userId: Int
    var title: String
    var completed: Bool
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Network())
    }
}
