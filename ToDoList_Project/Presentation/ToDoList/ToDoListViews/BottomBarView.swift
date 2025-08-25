import UIKit

final class BottomBarView: UIView {
    
    var onAddTapped: (() -> Void)?
    
    private lazy var addTaskButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let img = UIImage(systemName: "square.and.pencil") {
            button.setImage(img, for: .normal)
        } else {
            button.setTitle("+", for: .normal)
        }
        button.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
        button.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.text = "0 Задач"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        setup()
    }
    
    private func setup() {
        addSubview(addTaskButton)
        addSubview(countLabel)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 83 + safeAreaInsets.bottom),
            
            addTaskButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            addTaskButton.topAnchor.constraint(equalTo: topAnchor, constant: 13),
            addTaskButton.widthAnchor.constraint(equalToConstant: 28),
            addTaskButton.heightAnchor.constraint(equalToConstant: 28),
            
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: addTaskButton.centerYAnchor)
        ])
    }
    
    func updateCount(_ remaining: Int) {
        countLabel.text = "\(remaining) Задач"
    }
    
    @objc private func addTapped() {
        onAddTapped?()
    }
}



