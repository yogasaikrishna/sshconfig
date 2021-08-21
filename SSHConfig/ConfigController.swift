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
    
    private init() {
        let existingConfigPath = getExistingConfigPath()
        let configPath = getConfigPath()
        let configDirectory = getConfigDirectory()
        
        // Create .sshconfig directory in user home folder if not exists already
        if !fileManager.fileExists(atPath: configDirectory.relativePath) {
            do {
                try fileManager.createDirectory(atPath: configDirectory.relativePath,
                                                withIntermediateDirectories: true, attributes: nil)
            } catch {
                fatalError("Error creating config directory at path \(configDirectory.relativePath)")
            }
        }
        
        // If there an existing config file, copy it into newly created folder
        if !fileManager.fileExists(atPath: configPath.relativePath) &&
            fileManager.fileExists(atPath: existingConfigPath.relativePath) {
            do {
                try fileManager.copyItem(at: existingConfigPath, to: configPath)
            } catch {
                print("Error copying file to \(configPath.relativePath)")
            }
        }

        // Read the file from .sshconfig folder
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
    
    private func parse(_ content: String, with separator: String) {
        let lines = content.split(separator: "\n")
        var config = Config()
        for line in lines {
            if !line.isEmpty {
                let newLine = line.replacingOccurrences(of: separator, with: "#").replacingOccurrences(of: "\"", with: "")
                let lineContent = newLine.split(separator: "#")
                let count = lineContent.count
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
    
    private func getExistingConfigPath() -> URL {
        return fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".ssh/config")
    }
    
    private func getConfigDirectory() -> URL {
        return fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".sshconfig")
    }
    
    func getConfigPath() -> URL {
        return fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".sshconfig/config")
    }
    
    func isConfigComplete(_ config: Config) -> Bool {
        return !config.host.isEmpty &&
            !config.hostName.isEmpty &&
            !config.port.isEmpty &&
            !config.user.isEmpty &&
            !config.identityFilePath.isEmpty
    }
    
    private func save(at path: URL, withExtension: String? = nil) {
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
        
        do {
            try data.write(to: path, atomically: true, encoding: .ascii)
        } catch {
            fatalError("Failed to save configuration \(error.localizedDescription)")
        }
    }
    
    func saveFile(at path: URL? = nil, withExtension: String? = nil) {
        if let path = path {
            save(at: path, withExtension: withExtension)
        } else {
            save(at: getConfigPath())
        }
    }
}
