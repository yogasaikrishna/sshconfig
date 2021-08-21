//
//  ConfigController.swift
//  SSHConfig
//
//  Created by Sai Koneru on 19/08/2021.
//

import Foundation

class ConfigController {
    static let shared = ConfigController()
    var configs: [Config] = []
    let fileManager = FileManager.default
    
    init() {
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let existingConfigPath = homeDirectory.appendingPathComponent(".ssh/config")
        let configDirectory = homeDirectory.appendingPathComponent(".sshconfig")
        let configPath = configDirectory.appendingPathComponent("config")
        
        if !fileManager.fileExists(atPath: configPath.relativePath) &&
            fileManager.fileExists(atPath: existingConfigPath.relativePath) {
            do {
                try fileManager.createDirectory(atPath: configDirectory.relativePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Error creating config directory at path \(configDirectory.relativePath)")
            }
            
            do {
                try fileManager.copyItem(at: existingConfigPath, to: configPath)
            } catch {
                fatalError("Error copying file to \(configPath.relativePath)")
            }
        }

        if fileManager.fileExists(atPath: configPath.relativePath) {
            guard let content = try? String(contentsOf: configPath) else {
                fatalError("Failed to load config file")
            }
            
            if content.contains("\t") {
                parse(content, with: "\t")
            } else {
                parse(content, with: "=")
            }
        }
    }
    
    func parse(_ content: String, with separator: String) {
        let lines = content.split(separator: "\n")
        var config = Config()
        for line in lines {
            if !line.isEmpty {
                let newLine = line.replacingOccurrences(of: separator, with: "#").replacingOccurrences(of: "\"", with: "")
                let lineContent = newLine.split(separator: "#")
                let count = lineContent.count
                print(lineContent)
                switch lineContent[0].lowercased() {
                case "host":
                    config.host = count > 1 ? String(lineContent[1]) : ""
                case "hostname":
                    config.hostName = count > 1 ? String(lineContent[1]) : ""
                case "port":
                    config.port = count > 1 ? String(lineContent[1]) : ""
                case "user":
                    config.user = count > 1 ? String(lineContent[1]) : ""
                case "identityfile":
                    config.identityFilePath = count > 1 ? String(lineContent[1]) : ""
                default:
                    break
                }
            }

            if isConfigComplete(config) {
                configs.append(config)
                config = Config()
            }
        }
    }
    
    func isConfigComplete(_ config: Config) -> Bool {
        return !config.host.isEmpty &&
            !config.hostName.isEmpty &&
            !config.port.isEmpty &&
            !config.user.isEmpty &&
            !config.identityFilePath.isEmpty
    }
    
    func saveFile() {
        var data = ""
        for config in configs {
            data += """
            Host="\(config.host)"
            HostName="\(config.hostName)"
            Port="\(config.port)"
            User="\(config.user)"
            IdentityFile="\(config.identityFilePath)"
            \n
            """
        }
        let homeDirectory = fileManager.homeDirectoryForCurrentUser
        let configPath = homeDirectory.appendingPathComponent(".sshconfig/config")
        do {
            try data.write(to: configPath, atomically: true, encoding: .ascii)
        } catch {
            fatalError("Failed to save configuration \(error.localizedDescription)")
        }
    }
}
