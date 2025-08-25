import UIKit
import Combine

final class AddTaskViewController: UIViewController {

    // MARK: Private
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public
    var viewModel: AddTaskVMInterface!

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModelBinding()
        setupUI()
    }

    private func setup() {
        view.backgroundColor = .black
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
           let backButton = UIBarButtonItem()
           backButton.title = "Назад"
           backButton.tintColor = .yellow
           navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
       }

    private func viewModelBinding() {

    }

    private func setupUI() {

    }
}
