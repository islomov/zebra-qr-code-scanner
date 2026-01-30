//
//  ContactPickerView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 30/01/26.
//

import SwiftUI
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    var onSelectContact: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, onSelectContact: onSelectContact)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        let dismiss: DismissAction
        let onSelectContact: (CNContact) -> Void

        init(dismiss: DismissAction, onSelectContact: @escaping (CNContact) -> Void) {
            self.dismiss = dismiss
            self.onSelectContact = onSelectContact
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelectContact(contact)
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            dismiss()
        }
    }
}
