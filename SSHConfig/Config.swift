//
//  Config.swift
//  SSHEdit
//
//  Created by Sai Koneru on 19/08/2021.
//

import Foundation

struct Config {
    let id = UUID()
    var host: String
    var hostName: String
    var port: String
    var user: String
    var identityFilePath: String
}
