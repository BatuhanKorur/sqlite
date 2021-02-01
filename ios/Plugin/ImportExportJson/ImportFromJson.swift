//
//  ImportFromJson.swift
//  Plugin
//
//  Created by  Quéau Jean Pierre on 18/12/2020.
//  Copyright © 2020 Max Lynch. All rights reserved.
//

import Foundation
import SQLCipher

// swiftlint:disable type_body_length
// swiftlint:disable file_length
enum ImportFromJsonError: Error {
    case createDatabaseSchema(message: String)
    case createDatabaseData(message: String)
    case createSchema(message: String)
    case createSchemaStatement(message: String)
    case createTableData(message: String)
    case createRowStatement(message: String)
}
class ImportFromJson {

    // MARK: - ImportFromJson - CreateDatabaseSchema

    class func createDatabaseSchema(mDB: Database,
                                    jsonSQLite: JsonSQLite)
                                                    throws -> Int {
        let msg = "importFromJson: "
        var changes: Int = -1
        let version: Int = jsonSQLite.version

        do {
            // Set PRAGMAS
            try UtilsSQLCipher.setVersion(mDB: mDB,
                                              version: version)
            try UtilsSQLCipher
                    .setForeignKeyConstraintsEnabled(mDB: mDB,
                                                     toggle: true)
            if jsonSQLite.mode == "full" {
               // Drop All Tables, Indexes and Triggers
                try _ = UtilsDrop.dropAll(mDB: mDB)
            }
            // create database schema
            changes = try ImportFromJson
                        .createSchema(mDB: mDB,
                                      jsonSQLite: jsonSQLite)
            return changes

        } catch UtilsSQLCipherError.setVersion(let message) {
            throw ImportFromJsonError.createDatabaseSchema(
                                message: "\(msg) \(message)")
        } catch UtilsSQLCipherError
                    .setForeignKeyConstraintsEnabled(let message) {
            throw ImportFromJsonError.createDatabaseSchema(
                                message: "\(msg) \(message)")
        } catch UtilsDropError.dropAllFailed(let message) {
            throw ImportFromJsonError.createDatabaseSchema(
                                message: "\(msg) \(message)")
        }
    }

    // MARK: - ImportFromJson - createSchema

    class func createSchema(mDB: Database,
                            jsonSQLite: JsonSQLite) throws -> Int {
        var changes: Int = 0
        var initChanges: Int = 0
        do {
            // Start a transaction
            try UtilsSQLCipher.beginTransaction(mDB: mDB)
        } catch UtilsSQLCipherError.beginTransaction(let message) {
            throw ImportFromJsonError.createSchema(message: message)
        }
        // Create a Schema Statements
        let statements = ImportFromJson
                        .createSchemaStatement(jsonSQLite: jsonSQLite )
        if statements.count > 0 {
            let joined = statements.joined(separator: "\n")
            do {
                initChanges = UtilsSQLCipher.dbChanges(mDB: mDB.mDb)
                // Execute Schema Statements
                try UtilsSQLCipher.execute(mDB: mDB, sql: joined)
                changes = UtilsSQLCipher.dbChanges(mDB: mDB.mDb) -
                                                        initChanges
                if changes < 0 {
                    do {
                        // Rollback the transaction
                        try UtilsSQLCipher
                                    .rollbackTransaction(mDB: mDB)
                    } catch UtilsSQLCipherError
                                .rollbackTransaction(let message) {
                        throw ImportFromJsonError
                                        .createSchema(message: message)
                   }
                }
                // Commit the transaction
                try UtilsSQLCipher.commitTransaction(mDB: mDB)

            } catch UtilsSQLCipherError.execute(let message) {
                var msg = message
                do {
                    // Rollback the transaction
                    try UtilsSQLCipher
                                .rollbackTransaction(mDB: mDB)
                    throw ImportFromJsonError
                                    .createSchema(message: message)
                } catch UtilsSQLCipherError
                            .rollbackTransaction(let message) {
                    msg.append(" rollback: \(message)")
                    throw ImportFromJsonError
                                    .createSchema(message: msg)
                }
            } catch UtilsSQLCipherError.commitTransaction(let message) {
                throw ImportFromJsonError
                                .createSchema(message: message)
            }
        }
        return changes
    }

    // MARK: - ImportFromJson - createSchemaStatement

    class func createSchemaStatement(jsonSQLite: JsonSQLite)
                                                    -> [String] {
        // Create the Database Schema
        var statements: [String] = []
        // Loop through Tables
        for ipos in 0..<jsonSQLite.tables.count {
            let mode: String = jsonSQLite.mode
            let tableName: String = jsonSQLite.tables[ipos].name
            if let mSchema: [JsonColumn] =
                                jsonSQLite.tables[ipos].schema {
                if mSchema.count > 0 {
                    let stmt: [String] =
                        ImportFromJson.createTableSchema(
                            mSchema: mSchema,
                            tableName: tableName, mode: mode)
                    statements.append(contentsOf: stmt)
                }
            }
            if let mIndexes: [JsonIndex] =
                                    jsonSQLite.tables[ipos].indexes {
                if mIndexes.count > 0 {
                    let stmt: [String] =
                        ImportFromJson.createTableIndexes(
                            mIndexes: mIndexes, tableName: tableName)
                    statements.append(contentsOf: stmt)
                }
            }
            if let mTriggers: [JsonTrigger] =
                                    jsonSQLite.tables[ipos].triggers {
                if mTriggers.count > 0 {
                    let stmt: [String] =
                        ImportFromJson.createTableTriggers(
                            mTriggers: mTriggers, tableName: tableName)
                    statements.append(contentsOf: stmt)
                }
            }
        }
        return statements
    }

    // MARK: - ImportFromJson - CreateTableSchema

    class func createTableSchema(mSchema: [JsonColumn],
                                 tableName: String, mode: String)
                                                        -> [String] {
        var statements: [String] = []
        var stmt: String
        stmt = "CREATE TABLE IF NOT EXISTS "
        stmt.append(tableName)
        stmt.append(" (")
        for jpos in 0..<mSchema.count {
            if let jSchColumn = mSchema[jpos].column {
                if jSchColumn.count > 0 {
                    stmt.append(jSchColumn)
                }
            }
            if let jSchForeignkey = mSchema[jpos].foreignkey {
                if jSchForeignkey.count > 0 {
                    stmt.append("FOREIGN KEY (\( jSchForeignkey))")
                }
            }
            if let jSchConstraint = mSchema[jpos].constraint {
                if jSchConstraint.count > 0 {
                    stmt.append("CONSTRAINT \( jSchConstraint)")
                }
            }
            stmt.append(" ")
            stmt.append(mSchema[jpos].value)
            if jpos != mSchema.count - 1 {
                stmt.append(",")
            }
        }
        stmt.append(");")
        statements.append(stmt)
        // create trigger last_modified associated with the table
        let triggerName: String = tableName + "_trigger_last_modified"
        stmt = "CREATE TRIGGER IF NOT EXISTS "
        stmt.append(triggerName)
        stmt.append(" AFTER UPDATE ON ")
        stmt.append(tableName)
        stmt.append(" FOR EACH ROW ")
        stmt.append("WHEN NEW.last_modified <= OLD.last_modified ")
        stmt.append("BEGIN UPDATE ")
        stmt.append(tableName)
        stmt.append(" SET last_modified = (strftime('%s','now')) ")
        stmt.append("WHERE id=OLD.id; ")
        stmt.append("END;")
        statements.append(stmt)
        return statements
    }

    // MARK: - ImportFromJson - CreateTableIndexes

    class func createTableIndexes(mIndexes: [JsonIndex],
                                  tableName: String) -> [String] {
        var statements: [String] = []
        for jpos in 0..<mIndexes.count {
            var mUnique: String = ""
            if let mMode = mIndexes[jpos].mode {
                if mMode == "UNIQUE" {
                    mUnique = mMode + " "
                }
            }
            var stmt: String
            stmt = "CREATE "
            stmt.append(mUnique)
            stmt.append("INDEX IF NOT EXISTS ")
            stmt.append(mIndexes[jpos].name)
            stmt.append(" ON ")
            stmt.append(tableName)
            stmt.append(" (")
            stmt.append(mIndexes[jpos].value)
            stmt.append(");")
            statements.append(stmt)
        }
        return statements
    }

    // MARK: - ImportFromJson - CreateTableTriggers

    class func createTableTriggers(mTriggers: [JsonTrigger],
                                   tableName: String) -> [String] {
        var statements: [String] = []
        for jpos in 0..<mTriggers.count {
            var stmt: String
            stmt = "CREATE TRIGGER IF NOT EXISTS "
            stmt.append(mTriggers[jpos].name)
            stmt.append(" ")
            stmt.append(mTriggers[jpos].timeevent)
            stmt.append(" ON ")
            stmt.append("\(tableName) ")
            if let condition = mTriggers[jpos].condition {
                stmt.append("\(condition) ")
            }
            stmt.append("\(mTriggers[jpos].logic);")
            statements.append(stmt)
        }
        return statements
    }

    // MARK: - ImportFromJson - createDatabaseData

    // swiftlint:disable function_body_length
    class func createDatabaseData(mDB: Database,
                                  jsonSQLite: JsonSQLite)
                                                    throws -> Int {
        var changes: Int = -1
        var initChanges: Int = -1
        var isValue: Bool = false

        do {
            initChanges = UtilsSQLCipher.dbChanges(mDB: mDB.mDb)
            // Start a transaction
            try UtilsSQLCipher.beginTransaction(mDB: mDB)
        } catch UtilsSQLCipherError.beginTransaction(let message) {
            throw ImportFromJsonError.createDatabaseData(message: message)
        }
        // Loop on tables to create Data
        for ipos in 0..<jsonSQLite.tables.count {
            if let mValues = jsonSQLite.tables[ipos].values {
                if mValues.count > 0 {
                    isValue = true
                    do {
                        try ImportFromJson.createTableData(
                                mDB: mDB,
                                mode: jsonSQLite.mode,
                                mValues: mValues,
                                tableName: jsonSQLite.tables[ipos].name)
                    } catch ImportFromJsonError
                                .createTableData(let message) {
                        // Rollback Transaction
                        var msg = message
                        do {
                            // Rollback the transaction
                            try UtilsSQLCipher
                                        .rollbackTransaction(mDB: mDB)
                            throw ImportFromJsonError
                                .createDatabaseData(message: message)
                        } catch UtilsSQLCipherError
                                    .rollbackTransaction(let message) {
                            msg.append(" rollback: \(message)")
                            throw ImportFromJsonError
                                    .createDatabaseData(message: msg)
                        }
                    }
                }
            }
        }
        if !isValue {
            changes = 0
        } else {
            do {
                // Commit the transaction
                try UtilsSQLCipher.commitTransaction(mDB: mDB)
                changes = UtilsSQLCipher.dbChanges(mDB: mDB.mDb) -
                                                    initChanges
            } catch UtilsSQLCipherError.commitTransaction(
                                                        let message) {
                throw ImportFromJsonError.createDatabaseData(
                                                    message: message)
            }
        }
        return changes
    }
    // swiftlint:enable function_body_length

    // MARK: - ImportFromJson - createTableData

    // swiftlint:disable function_body_length
    class func createTableData(
                        mDB: Database, mode: String,
                        mValues: [[UncertainValue<String, Int, Double>]],
                        tableName: String) throws {
        // Check if table exists
        do {
            let isTab: Bool = try UtilsJson
                        .isTableExists(mDB: mDB, tableName: tableName)
            if !isTab {
                let message: String = "createTableData: Table " +
                tableName + " does not exist"
                throw ImportFromJsonError.createTableData(
                    message: message)
            }
        } catch UtilsJsonError.tableNotExists(let message) {
            throw ImportFromJsonError.createTableData(message: message)
        }
        // Get the Column's Name and Type
        var jsonNamesTypes: JsonNamesTypes =
                            JsonNamesTypes(names: [], types: [])
        do {
            jsonNamesTypes = try UtilsJson
                .getTableColumnNamesTypes(mDB: mDB,
                                          tableName: tableName)
        } catch UtilsJsonError.getTableColumnNamesTypes(let message) {
           throw ImportFromJsonError.createTableData(message: message)
        }
        for jpos in 0..<mValues.count {
            // Check row validity
            let row: [UncertainValue<String, Int, Double>] =
                                                        mValues[jpos]
            do {
                try UtilsJson.checkRowValidity(
                    mDB: mDB, jsonNamesTypes: jsonNamesTypes,
                    row: row, pos: jpos, tableName: tableName)
            } catch UtilsJsonError.checkRowValidity(let message) {
                throw ImportFromJsonError.createTableData(
                                                message: message)
            }
            // Create INSERT or UPDATE Statements
            do {
                let data: [String: Any] = ["pos": jpos, "mode": mode,
                                           "tableName": tableName]
                let stmt: String = try ImportFromJson
                    .createRowStatement(mDB: mDB, data: data,
                                        row: row,
                                        jsonNamesTypes: jsonNamesTypes)
                let rowValues = UtilsJson.getValuesFromRow(
                                                    rowValues: row)
                let lastId: Int64 = try UtilsSQLCipher.prepareSQL(
                    mDB: mDB, sql: stmt, values: rowValues)
                if lastId < 0 {
                    throw ImportFromJsonError.createTableData(
                    message: "lastId < 0")
                }
            } catch ImportFromJsonError.createRowStatement(
                        let message) {
                throw ImportFromJsonError.createTableData(
                    message: message)
                } catch UtilsSQLCipherError.prepareSQL(let message) {
                    throw ImportFromJsonError.createTableData(
                        message: message)
                }
        }
        return
    }
    // swiftlint:enable function_body_length

    // MARK: - ImportFromJson - createRowStatement

    // swiftlint:disable function_body_length
    class func createRowStatement(
                    mDB: Database,
                    data: [String: Any],
                    row: [UncertainValue<String, Int, Double>],
                    jsonNamesTypes: JsonNamesTypes) throws -> String {
        var stmt: String = ""
        var retisIdExists: Bool = false
        let message = "createRowStatement: data is missing"
        guard let pos = data["pos"] as? Int else {
            throw ImportFromJsonError.createRowStatement(
                message: message + " pos")
        }
        guard let mode = data["mode"] as? String else {
            throw ImportFromJsonError.createRowStatement(
                message: message + " mode")
        }
        guard let tableName = data["tableName"] as? String else {
            throw ImportFromJsonError.createRowStatement(
                message: message + " tableName")
        }
        do {
            if let rwValue: Any = row[0].value {
                retisIdExists = try UtilsJson.isIdExist(
                    mDB: mDB, tableName: tableName,
                    firstColumnName: jsonNamesTypes.names[0],
                    key: rwValue)
            } else {
                var message: String = "createRowStatement: Table "
                message.append("\(tableName) values row[0] does not ")
                message.append("exist")
                throw ImportFromJsonError.createRowStatement(
                                            message: message)
            }

        } catch UtilsJsonError.isIdExists(let message) {
           throw ImportFromJsonError.createRowStatement(
                                            message: message)
        }
        if mode == "full" || (mode == "partial" && !retisIdExists) {
            // Insert
            let nameString: String = jsonNamesTypes
                                        .names.joined(separator: ",")
            let questionMarkString: String =
                UtilsJson.createQuestionMarkString(
                                    length: jsonNamesTypes.names.count)
            stmt = "INSERT INTO \(tableName) (\(nameString)) VALUES "
            stmt.append("(\(questionMarkString));")
        } else {
            // Update
            let setString: String = UtilsJson.setNameForUpdate(
                                        names: jsonNamesTypes.names)
            if setString.count == 0 {
                var message: String = "importFromJson: Table "
                message.append("\(tableName) values row ")
                message.append("\(pos) not set to String")
                throw ImportFromJsonError.createRowStatement(
                                                    message: message)
            }
            if let rwValue: Any = row[0].value {
                stmt = "UPDATE \(tableName)  SET \(setString) WHERE " +
                    "\(jsonNamesTypes.names[0]) = \(rwValue);"
            } else {
                var msg: String = "importFromJson: Table "
                msg.append("\(tableName) values row[0]does not exist")
                throw ImportFromJsonError.createRowStatement(
                                                message: message)
            }
        }
        return stmt
    }
}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
