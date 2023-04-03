import Combine
import UIKit

struct Alert {
    let title: String
    let message: String
    let actionTitle: String
    let completion: PassthroughSubject<Void, Never>?
}

protocol AlertManagerProtocol {
    func showAlert(with model: Alert,
                   in viewController: UIViewController
    )
}

class AlertManager: AlertManagerProtocol {
    func showAlert(with model: Alert,
                   in viewController: UIViewController
    ) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        alertController
            .addAction(
                UIAlertAction(
                    title: model.actionTitle,
                    style: .default,
                    handler: { (action) in
                        model.completion?.send()
                    })
            )
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
