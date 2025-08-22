import UIKit

extension UITableView {
    
    func registerClassForCell<T: UITableViewCell>(_ cellClass: T.Type) {
        self.register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for index: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.identifier, for: index) as! T
    }
}
