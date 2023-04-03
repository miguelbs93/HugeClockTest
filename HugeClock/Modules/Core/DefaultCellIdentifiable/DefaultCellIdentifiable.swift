import Foundation

protocol DefaultCellIdentifiable: AnyObject {
    static var defaultCellIdentifier: String { get }
}

extension DefaultCellIdentifiable {
    static var defaultCellIdentifier: String {
        String(describing: Self.self) + "Cell"
    }
}
