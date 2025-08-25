import UIKit

final class ActionPopupPresenter {
    
    private weak var hostView: UIView?
    private var blurView: UIVisualEffectView?
    private var previewView: TaskPreviewView?
    private var actionsView: ActionsPopupView?
    
    init(hostView: UIView) {
        self.hostView = hostView
    }
    
    func present(todo: Todo, onEdit: @escaping () -> Void, onShare: @escaping () -> Void, onDelete: @escaping () -> Void) {
        guard let view = hostView else { return }
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.alpha = 0.9
        view.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blur.topAnchor.constraint(equalTo: view.topAnchor),
            blur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.blurView = blur
        
        let preview = TaskPreviewView()
        preview.configure(with: todo)
        view.addSubview(preview)
        self.previewView = preview
        
        let actions = ActionsPopupView(onEdit: { [weak self] in self?.dismiss(); onEdit() },
                                       onShare: { [weak self] in self?.dismiss(); onShare() },
                                       onDelete: { [weak self] in self?.dismiss(); onDelete() })
        view.addSubview(actions)
        self.actionsView = actions
        
        NSLayoutConstraint.activate([
            preview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            preview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            preview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            actions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            actions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            actions.topAnchor.constraint(equalTo: preview.bottomAnchor, constant: 16)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapBlur))
        blur.addGestureRecognizer(tap)
        UIView.animate(withDuration: 0.2) { blur.alpha = 1.0 }
    }
    
    @objc private func didTapBlur() { dismiss() }
    
    func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurView?.alpha = 0.0
        }, completion: { _ in
            self.blurView?.removeFromSuperview()
            self.previewView?.removeFromSuperview()
            self.actionsView?.removeFromSuperview()
            self.blurView = nil
            self.previewView = nil
            self.actionsView = nil
        })
    }
}



