import UIKit
import Combine

final class ToDoListViewController: UIViewController {

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public
    var viewModel: ToDoListVMInterface!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModelBinding()
        setupUI()
    }

    private func setup() {
        view.backgroundColor = .red
    }
    
    private func setupUI() {

    }

    private func viewModelBinding() {

    }
}
