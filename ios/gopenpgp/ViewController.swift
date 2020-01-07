//
//  ViewController.swift
//  gopenpgp
//
//  Created by Vinoth Ramiah on 01/06/2019.
//  Copyright © 2019 Vinoth Ramiah. All rights reserved.
//

import UIKit
import Crypto

class ViewController: UIViewController {

    @IBOutlet var keyField: UITextView!
    @IBOutlet var passwordField: UITextView!
    @IBOutlet var messageField: UITextView!
    @IBOutlet var signedSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func encrypt(_ sender: UIButton) {
        guard let key = keyField.text, key != "", let message = messageField.text, message != "" else { return }

        let pgp = CryptoGopenPGP()
        var error: NSError?
        let keyring = try! pgp.buildKeyRingArmored(key)

        if signedSwitch.isOn {
            guard let password = passwordField.text, password != "" else { print("ERROR - signed message requires password\n"); return }
            try! keyring.unlock(password.data(using: .utf8))
        }

        let cipher = keyring.encryptMessage(message, sign: signedSwitch.isOn ? keyring : nil, error: &error)
        print("\(cipher)\n")
    }

    @IBAction func decrypt(_ sender: Any) {
        guard let key = keyField.text, key != "", let password = passwordField.text, password != "", let cipher = messageField.text, cipher != "" else { return }

        let pgp = CryptoGopenPGP()
        let keyring = try! pgp.buildKeyRingArmored(key)
        let pgpDecrypted = try! pgp.decryptMessageVerify(cipher, verifierKey: keyring, privateKeyRing: keyring, passphrase: password, verifyTime: pgp.getTimeUnix())

        if signedSwitch.isOn {
            print(pgpDecrypted.verify == 0 ? "following message is signed by provided key..." : "error with signature for the following message...")
        }

        let message = pgpDecrypted.plaintext
        print("\(message)\n")
    }

//    func encryptData() {
//        let encrypted = try! pgp.encryptAttachment(data, fileName: "logo.jpg", publicKey: mediaKeyring)
//        let encryptedData = PGPData.with {
//            $0.algo = encrypted.algo
//            $0.keyPacket = encrypted.keyPacket!
//            $0.dataPacket = encrypted.dataPacket!
//        }
//
//        let binaryData: Data = try! encryptedData.serializedData()
//        let encryptedURL = URL(fileURLWithPath: "/Users/vin/Downloads/logo.pb")
//        try! binaryData.write(to: encryptedURL)
//    }

//    func decryptData() {
//        let pgp = CryptoGopenPGP()
//        let mediaKeyring = try! pgp.buildKeyRingArmored(key)
//        let data = try! pgp.decryptAttachment(encryptedData.keyPacket, dataPacket: encryptedData.dataPacket, kr: mediaKeyring, passphrase: nil)
//
//        let outputURL = URL(fileURLWithPath: "/Users/vin/Downloads/logo copy.jpg")
//        try! data.write(to: outputURL)
//    }
}

class EncryptedData: Codable {
    let algo: String
    let keyPacket: Data
    let dataPacket: Data

    init?(_ model: ModelsEncryptedSplit) {
        guard let keyPacket = model.keyPacket, let dataPacket = model.dataPacket else { return nil }
        self.algo = model.algo
        self.keyPacket = keyPacket
        self.dataPacket = dataPacket
    }
}
