//
//  ConfigController.swift
//  SSHEdit
//
//  Created by Sai Koneru on 19/08/2021.
//

import Foundation

class ConfigController {
    static let shared = ConfigController()
    var configs: [Config] = []
    
    init() {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDirectory.appendingPathComponent(".ssh/config")
        
        guard let content = try? String(contentsOf: configPath) else {
            fatalError("Failed to load config file")
        }
        
        parseFile(content)
    }
    
    func parseFile(_ content: String) {
        let lines = content.split(separator: "\n")
        var host = ""
        var hostName = ""
        var port = ""
        var user = ""
        var identityFile = ""
        for line in lines {
            let newLine = line.replacingOccurrences(of: "\t", with: " ")
            let words = newLine.split(separator: " ")
            switch words[0].lowercased() {
            case "host":
                host = String(words[1])
            case "hostname":
                hostName = String(words[1])
            case "port":
                port = String(words[1])
            case "user":
                user = String(words[1])
            case "identityfile":
                identityFile = String(words[1])
            default:
                break
            }
            
            if !host.isEmpty && !hostName.isEmpty && !port.isEmpty && !user.isEmpty && !identityFile.isEmpty {
                let config = Config(host: host, hostName: hostName, port: port, user: user, identityFilePath: identityFile)
                configs.append(config)
                host = ""
                hostName = ""
                port = ""
                user = ""
                identityFile = ""
            }
        }
    }
    
    func saveFile() {
        var data = ""
        for config in configs {
            data += "Host\t\(config.host)\nHostName\t\(config.hostName)\nPort\t\(config.port)\nUser\t\(config.user)\nIdentityFile\t\(config.identityFilePath)\n\n"
        }
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let configPath = homeDirectory.appendingPathComponent(".ssh/config")
        do {
            try data.write(to: configPath, atomically: true, encoding: .ascii)
        } catch {
            fatalError("Failed to save configuration \(error.localizedDescription)")
        }
    }
}
