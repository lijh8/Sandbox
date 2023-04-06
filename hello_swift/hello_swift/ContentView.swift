//
//  ContentView.swift
//  hello_swift
//
//  Created by ljh on 4/1/23.
//

import SwiftUI

/*
 iOS: App Sandbox is enabled defautly.

 macOS:
 project navigator / Targets / Signing & Capabilities / App Sandbox:
    User Selected File: Read/Write;
    Downloads Folder: Read/Write;
 */

struct ContentView: View {
    @State private var fileDialogShown: Bool = false
    var body: some View {
        HStack {
            Button("Button1") { fileDialogShown = true }
                .fileImporter(isPresented: $fileDialogShown,
                              allowedContentTypes: [.plainText])
                { result in
                    guard let file = try? result.get() else { return }
                    //Sandbox: User Selected File
                    hello(file: file.path)
                }
            Button("Button2") { hello2() }
        }.frame(minWidth: 300, minHeight: 300)
    }

    func hello2(){
        //Sandbox: Documents, Downloads Folder

        // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide
        let dir = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask).first!

        let file = dir.appendingPathComponent("hello.txt")
        hello(file: file.path)
    }

    func hello(file: String){
        var fp = fopen(file, "a")
        if fp == nil {
            perror("fopen")
            return;
        }
        fputs("hello1\n", fp)
        fputs("hello2\n", fp)
        fclose(fp)

        fp = fopen(file, "r")
        var buffer = [CChar](repeating: 0, count: 128)
        while fgets(&buffer, Int32(buffer.count), fp) != nil {
            print(String(cString: buffer), terminator: "")
        }
        fclose(fp);
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
