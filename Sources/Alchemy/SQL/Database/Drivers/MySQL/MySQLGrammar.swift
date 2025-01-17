import NIO

/// A MySQL specific Grammar for compiling QueryBuilder statements
/// into SQL strings.
final class MySQLGrammar: Grammar {
    override func compileInsertReturn(_ table: String, values: [[String : SQLValueConvertible]]) -> [SQL] {
        return values.flatMap {
            return [
                compileInsert(table, values: [$0]),
                SQL("select * from \(table) where id = LAST_INSERT_ID()")
            ]
        }
    }
    
    override func compileDropIndex(on table: String, indexName: String) -> SQL {
        SQL("DROP INDEX \(indexName) ON \(table)")
    }
    
    override func columnTypeString(for type: ColumnType) -> String {
        switch type {
        case .bool:
            return "boolean"
        case .date:
            return "datetime"
        case .double:
            return "double"
        case .increments:
            return "serial"
        case .int:
            return "int"
        case .bigInt:
            return "bigint"
        case .json:
            return "json"
        case .string(let length):
            switch length {
            case .unlimited:
                return "text"
            case .limit(let characters):
                return "varchar(\(characters))"
            }
        case .uuid:
            // There isn't a MySQL UUID type; store UUIDs as a 36
            // length varchar.
            return "varchar(36)"
        }
    }
    
    override func columnConstraintString(for constraint: ColumnConstraint, on column: String, of type: ColumnType) -> String? {
        switch constraint {
        case .unsigned:
            return "UNSIGNED"
        default:
            return super.columnConstraintString(for: constraint, on: column, of: type)
        }
    }
    
    override func jsonLiteral(for jsonString: String) -> String {
        "('\(jsonString)')"
    }
}
