// Created on 10/11/2020 

import UIKit
import UserNotifications

class ViewController: UIViewController {
    enum Notification {
        enum Request {
            static let labLocalNotification = "labLocalNotification"
        }

        enum Action {
            static let readLater = "readLater"
            static let showDetails = "showDetails"
            static let unsubscribe = "unsubscribe"
        }

        enum Category {
            static let lab = "lab"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUserNotificationsCenter()
    }

    @IBAction func didTapButton(sender: UIButton) {
        UNUserNotificationCenter.current().getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { success in
                    guard success else {
                        return
                    }
                    self.scheduleLocalNotification()
                })
            case .authorized:
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            case .provisional:
                print("Provisional")
            case .ephemeral:
                print("Ephemeral")
            @unknown default:
                print("Unknown")
            }
        }
    }

    // MARK: - Helpers

    func configureUserNotificationsCenter() {
        UNUserNotificationCenter.current().delegate = self

        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.unsubscribe, title: "Unsubscribe", options: [.destructive, .authenticationRequired])
        let labCategory = UNNotificationCategory(identifier: Notification.Category.lab, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([labCategory])
    }

    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription)")
            }

            completionHandler(success)
        }
    }

    private func scheduleLocalNotification() {
        let notificationContent = UNMutableNotificationContent()

        notificationContent.title = "Notifiacation Lab"
        notificationContent.subtitle = "Local Notifications"
        notificationContent.body = "In this project, we test how to schedule local notifications with the User Notifications framework."

        notificationContent.categoryIdentifier = Notification.Category.lab

        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        let notficationRequest = UNNotificationRequest(identifier: Notification.Request.labLocalNotification, content: notificationContent, trigger: notificationTrigger)

        UNUserNotificationCenter.current().add(notficationRequest) { error in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription)")
            }
        }
    }
}


extension ViewController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.banner)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case Notification.Action.readLater:
            print("Save For Later")
        case Notification.Action.unsubscribe:
            print("Unsubscribe Reader")
        default:
            print("Other Action")
        }

        completionHandler()
    }

}
