import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    // MARK: - Properties
    
    var task: Todo?
    var onCheckboxTapped: ((Todo) -> Void)?
    var onLongPress: ((Todo) -> Void)?
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubviews(checkboxButton, stackView)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 24),
            checkboxButton.heightAnchor.constraint(equalToConstant: 24),
            
            stackView.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        contentView.addGestureRecognizer(longPress)
    }
    
    // MARK: - Configuration
    
    func configure(with task: Todo) {
        self.task = task
            
            // Полностью очищаем все атрибуты и стили
            titleLabel.attributedText = nil
            titleLabel.text = task.todo
            
            // Показываем description если есть, иначе дублируем title
            if !task.description.isEmpty {
                descriptionLabel.text = task.description
            } else {
                descriptionLabel.text = task.todo
            }
            
            dateLabel.text = formatDate(Date())
            
            // Сбрасываем прозрачность
            titleLabel.alpha = 1.0
            descriptionLabel.alpha = 1.0
            dateLabel.alpha = 1.0
            
            // Убираем все subviews из кнопки
            checkboxButton.subviews.forEach { $0.removeFromSuperview() }
            
            // Сбрасываем стили кнопки
            checkboxButton.backgroundColor = .clear
            checkboxButton.layer.borderColor = UIColor.white.cgColor
            checkboxButton.layer.borderWidth = 2
            
            // Теперь обновляем внешний вид в зависимости от статуса
            updateCheckboxAppearance()
    }
    
    private func updateCheckboxAppearance() {
        guard let task = task else { return }
        
        // Убираем все существующие subviews
        checkboxButton.subviews.forEach { $0.removeFromSuperview() }
        
        if task.completed {
            // Настраиваем кнопку для выполненных задач
            checkboxButton.backgroundColor = .clear
            checkboxButton.layer.borderColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).cgColor
            checkboxButton.layer.borderWidth = 2
            
            // Создаем желтую галочку
            let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmarkImageView.tintColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
            checkmarkImageView.contentMode = .scaleAspectFit
            checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
            checkboxButton.addSubview(checkmarkImageView)
            
            NSLayoutConstraint.activate([
                checkmarkImageView.centerXAnchor.constraint(equalTo: checkboxButton.centerXAnchor),
                checkmarkImageView.centerYAnchor.constraint(equalTo: checkboxButton.centerYAnchor),
                checkmarkImageView.widthAnchor.constraint(equalToConstant: 14),
                checkmarkImageView.heightAnchor.constraint(equalToConstant: 14)
            ])
            
            // Применяем зачеркивание к тексту
            let attributedString = NSMutableAttributedString(string: task.todo)
            attributedString.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: attributedString.length)
            )
            attributedString.addAttribute(
                .strikethroughColor,
                value: UIColor.lightGray,
                range: NSRange(location: 0, length: attributedString.length)
            )
            titleLabel.attributedText = attributedString
            
            // Делаем текст блеклым
            titleLabel.alpha = 0.6
            descriptionLabel.alpha = 0.6
            dateLabel.alpha = 0.6
            
        } else {
            // Настраиваем кнопку для невыполненных задач
            checkboxButton.backgroundColor = .clear
            checkboxButton.layer.borderColor = UIColor.white.cgColor
            checkboxButton.layer.borderWidth = 2
            
            // Полностью убираем зачеркивание и возвращаем обычный текст
            titleLabel.attributedText = nil
            titleLabel.text = task.todo
            
            // Возвращаем нормальную прозрачность
            titleLabel.alpha = 1.0
            descriptionLabel.alpha = 1.0
            dateLabel.alpha = 1.0
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    
    @objc private func checkboxTapped() {
            guard var task = task else {
                print("❌ task is nil в checkboxTapped")
                return
            }
            
            print("🔘 Чекбокс нажат, текущий статус: \(task.completed)")
            
            // Меняем статус задачи
            task.completed.toggle()
            
            print("🔘 Новый статус: \(task.completed)")
            
            // Вызываем callback
            onCheckboxTapped?(task)
        }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, let task = task {
            onLongPress?(task)
        }
    }
}
