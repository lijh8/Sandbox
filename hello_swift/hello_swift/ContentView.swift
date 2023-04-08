import SwiftUI
import UniformTypeIdentifiers

/*
 iOS: App Sandbox is enabled defautly.

 macOS:
 project navigator / Targets / Signing & Capabilities / App Sandbox:
    User Selected File: Read/Write;
    Downloads Folder: Read/Write;
 */

struct ContentView: View {
    @State private var isPresented: Bool = false
    @State var content = ""
    
    var body: some View {
        VStack {
            Button("importer") {
                isPresented = true
            }
            .fileImporter(isPresented: $isPresented,
                          allowedContentTypes: [.plainText])
            { result in
                let file = try? result.get()
                if file == nil {
                    return
                }
                importer(file: file!.path)
            }
            
            Button("exporter") {
                isPresented = true
            }
            .fileExporter(isPresented: $isPresented,
                          document: MyFileDocument(),
                          contentType: .plainText,
                          defaultFilename: "hello.txt")
            { result in
                let file = try? result.get()
                if file == nil {
                    return
                }
            }
            
            Button("user document"){
                read_write_user_document()
            }
        }
        .frame(minWidth: 300, minHeight: 400)
        .border(.red)
        .padding(5)
        .lineSpacing(5)
    }
    
    //user selected for import, not working for iOS 15.7 on iPad mini 4?
    //try to restore content from the Sandbox user document
    //fileImporter is fileExporter on macOS 12.6.4 too ?
    func importer(file: String){
        let fp = fopen(file, "r")
        var buffer = [CChar](repeating: 0, count: 128)
        
        if fp == nil {
            perror("fopen") //fopen: Operation not permitted
            return;
        }
        
        while fgets(&buffer, Int32(buffer.count), fp) != nil {
            content += String(cString: buffer)
            print(content, terminator: "")
        }
        fclose(fp);
    }
}

//user selected for export, ok
struct MyFileDocument: FileDocument {
    static var readableContentTypes = [UTType.plainText]
    static var writableContentTypes = [UTType.plainText]
    
    var text = ""
    
    init(){
        //populate all the content including the old
        text += "hello 111 world 222 "
    }
    
    init(configuration: ReadConfiguration) throws {
        //it can export
        //but didn't read the old content for export
        //try to restore content from the Sandbox user document
        if let data = configuration.file.regularFileContents {
            //text += String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws
            -> FileWrapper {
        print(text)
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}

func read_write_user_document(){
    // https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide
    let dir = FileManager.default.urls(for: .documentDirectory,
                                       in: .userDomainMask).first!
    
    let file = dir.appendingPathComponent("hello.txt")
    
    //write
    var fp = fopen(file.path, "a")
    if fp == nil {
        perror("fopen")
        return;
    }
    fputs("hello1\n", fp)
    fputs("hello2\n", fp)
    fclose(fp)
    
    //read
    fp = fopen(file.path, "r")
    if fp == nil {
        perror("fopen")
        return;
    }
    var buffer = [CChar](repeating: 0, count: 128)
    while fgets(&buffer, Int32(buffer.count), fp) != nil {
        print(String(cString: buffer), terminator: "")
    }
    fclose(fp);
}
