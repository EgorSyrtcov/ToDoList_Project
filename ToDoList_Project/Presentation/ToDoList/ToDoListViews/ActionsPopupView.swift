import UIKit

final class ActionsPopupView: UIView {
    
    init(onEdit: @escaping () -> Void,
         onShare: @escaping () -> Void,
         onDelete: @escaping () -> Void) {
        self.onEdit = onEdit
        self.onShare = onShare
        self.onDelete = onDelete
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let onEdit: () -> Void
    private let onShare: () -> Void
    private let onDelete: () -> Void
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 0.92, alpha: 1.0)
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)
        
        let edit = makeRow(title: "Редактировать", systemImage: "square.and.pencil", action: onEdit)
        let share = makeRow(title: "Поделиться", systemImage: "square.and.arrow.up", action: onShare)
        let delete = makeRow(title: "Удалить", systemImage: "trash", titleColor: UIColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1.0), iconTint: UIColor(red: 0.90, green: 0.10, blue: 0.10, alpha: 1.0), action: onDelete)
        
        let separator1 = makeSeparator()
        let separator2 = makeSeparator()
        
        addSubview(edit)
        addSubview(separator1)
        addSubview(share)
        addSubview(separator2)
        addSubview(delete)
        
        NSLayoutConstraint.activate([
            edit.topAnchor.constraint(equalTo: topAnchor),
            edit.leadingAnchor.constraint(equalTo: leadingAnchor),
            edit.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separator1.topAnchor.constraint(equalTo: edit.bottomAnchor),
            separator1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator1.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            share.topAnchor.constraint(equalTo: separator1.bottomAnchor),
            share.leadingAnchor.constraint(equalTo: leadingAnchor),
            share.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            separator2.topAnchor.constraint(equalTo: share.bottomAnchor),
            separator2.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separator2.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            delete.topAnchor.constraint(equalTo: separator2.bottomAnchor),
            delete.leadingAnchor.constraint(equalTo: leadingAnchor),
            delete.trailingAnchor.constraint(equalTo: trailingAnchor),
            delete.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func makeRow(title: String, systemImage: String, titleColor: UIColor = .black, iconTint: UIColor = .darkGray, action: @escaping () -> Void) -> UIControl {
        let row = UIControl()
        row.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImageView(image: UIImage(systemName: systemImage))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = iconTint
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = titleColor
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.text = title
        
        row.addSubview(label)
        row.addSubview(icon)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 44),
            
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 18),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            
            icon.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])
        row.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return row
    }
    
    private func makeSeparator() -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        NSLayoutConstraint.activate([ v.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale) ])
        return v
    }
}
