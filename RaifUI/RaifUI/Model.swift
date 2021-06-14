//
//  Model.swift
//  RaifUI
//
//  Created by Дмитрий Соколов on 02.06.2021.
//

import Foundation
import PostgresClientKit


class Model {
    
    init(environment: Environment, user: String, password: String)
    {
        
        // Configure a connection pool with, at most, a single connection.  Using a connection pool
        // allows the connection to be lazily created, automatically re-creates the connection if
        // there is an unrecoverable error, and performs database operations on a background thread.
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 1
        
        // Configure how connections are created in that connection pool.
        var connectionConfiguration = ConnectionConfiguration()
        connectionConfiguration.host = environment.host
        connectionConfiguration.port = environment.port
        connectionConfiguration.ssl = environment.ssl
        connectionConfiguration.database = environment.database
        connectionConfiguration.user = user
        connectionConfiguration.credential = .md5Password(password: password)
        
        connectionPool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration,
                                        connectionConfiguration: connectionConfiguration)
    }
    
    /// A pool of (at most) a single connection.
    var connectionPool: ConnectionPool
    
    /// Closes any existing connection to the Postgres server.
    func disconnect()
    {
        
        // Close the current connection pool
        connectionPool.close()
        
        // And create a new one.  Its connection will be lazily created.
        connectionPool = ConnectionPool(
            connectionPoolConfiguration: connectionPool.connectionPoolConfiguration,
            connectionConfiguration: connectionPool.connectionConfiguration)
    }
    
    
    //
    // MARK: Entities and operations
    //
    
    struct Deal {
        var id: Int
        var kind: String
        var status: String
        var remark: String
        var version: String?
        var datalink: String
        var owner: String
        var validation: String
    }
    
    
    func addDealForUser(deal: Deal, completion: @escaping (Result<Deal, Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<Deal, Error> {
                
                let connection = try connectionResult.get()

                let text = "INSERT INTO deals (id, kind, status, remark, version, datalink, owner, validation) VALUES (\(deal.id), '\(deal.kind)', '\(deal.status)', '\(deal.remark)', '\(deal.version!)', '\(deal.datalink)', '\(deal.owner)','false');"
                let statement = try connection.prepareStatement(text: text)
                
                defer { statement.close() }
                _ = try statement.execute()
                
                sleep(2)
                
                let text2 = "SELECT id, validation FROM deals WHERE id = \(deal.id) AND validation = 'confirmed';"
                let statement2 =  try connection.prepareStatement(text: text2)
                defer { statement2.close() }
                let cursor = try statement2.execute()
                defer { cursor.close() }
                
                var valid : String?
                
                for row in cursor{
                    let column = try row.get().columns
                    let validation = try column[1].string()
                    valid = validation
                }
                
                enum MyError: Error {
                    case runtimeError(String)
                }
                
                if(valid != "confirmed") //throw error if added deal wasn't confirmed by blockchain
                {
                    throw MyError.runtimeError("fail")
                }
                
                return deal
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completion(result)                                              // call the completion handler in the main thread
            }
        }
    }
    
    func updateStatus(id: Int , bankParameter: String, completion: @escaping (Result<Int,Error>) -> Void) {
        
        var bankParamToSend = ""
        if (bankParameter == "Accepted") {
            bankParamToSend = "Bank Accepted"
        }
        else if (bankParameter == "Сlient") {
            bankParamToSend = "Client"
        }
        else if (bankParameter == "Bank") {
            bankParamToSend = "Bank"
        }
        else{
            return
        }
        
        connectionPool.withConnection { connectionResult in
        
            let result = Result<Int, Error> {
            
                let connection = try connectionResult.get()
            
                let text = "UPDATE deals SET status = '\(bankParamToSend)' WHERE id=\(id);"
                let statement = try connection.prepareStatement(text: text)
            
                defer { statement.close() }
                _ = try statement.execute()
                return id
                }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                completion(result)
            }
        }
    }
    
    ///
    ///
    /// - Parameters:
    ///   - completion: a completion handler, invoked with either the deal  records or an error.
    func dealsForUser(_ user: String,
                               completion: @escaping (Result<[Deal], Error>) -> Void) {
        
        connectionPool.withConnection { connectionResult in
            
            let result = Result<[Deal], Error> {
                
                let connection = try connectionResult.get()
                
                let text = "SELECT id, kind, status, remark, version, datalink, owner, validation FROM deals WHERE owner = $1 AND validation = 'confirmed';"
                let statement = try connection.prepareStatement(text: text)
                defer { statement.close() }
                
                let cursor = try statement.execute(parameterValues: [ user ])
                defer { cursor.close() }
                
                var dealhistory = [Deal]()
                
                for row in cursor {
                    let columns = try row.get().columns
                    let id = try columns[0].int()
                    let kind = try columns[1].string()
                    let status = try columns[2].string()
                    let remark = try columns[3].string()
                    let version = try columns[4].string()
                    let datalink = try columns[5].string()
                    let onwer = try columns[6].string()
                    let validation = try columns[7].string()
                    
                    let deal = Deal(id: id,
                                          kind: kind,
                                          status: status,
                                          remark: remark,
                                          version: version,datalink: datalink,owner: onwer,validation: validation)
                    
                    dealhistory.append(deal)
                }
                dealhistory.sort() {$0.id < $1.id}
                return dealhistory
            }
            
            DispatchQueue.main.async { // call the completion handler in the main thread
                completion(result)
            }
        }
    }
    
    func updateStatus(parameter: String?)
    {
        
    }
}

