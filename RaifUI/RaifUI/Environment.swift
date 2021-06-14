//
//  Environment.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 02.06.2021.
//

import Foundation
import PostgresClientKit

// Describes a Postgres server endpoint.
struct Environment: Codable {
    
    let host: String
    let port: Int
    let ssl: Bool
    let database: String
    
    /// The Postgres server endpoint specified in Environment.json.
    static var current: Environment = {
        
        guard let url = Bundle.main.url(forResource: "Environment", withExtension: "json") else {
            fatalError("Environment.json not found")
        }
        
        let environment: Environment
        
        do {
            let data = try Data(contentsOf: url)
            environment = try JSONDecoder().decode(Environment.self, from: data)
        } catch {
            fatalError("Error reading Environment.json: \(error)")
        }
        
        Postgres.logger.info("Environment: \(environment)")
        
        return environment
    }()
}


