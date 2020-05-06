//
//  ArisenReferenceAuthenticatorSignatureProvider+Transactions.swift
//  ArisenReferenceAuthenticatorSignatureProvider
//
//  Created by Todd Bowden on 11/12/18.
//  Copyright (c) 2017-2019 block.one and its contributors. All rights reserved.
//

import Foundation
import ArisenSwift

/// Extensions to `ArisenReferenceAuthenticatorSignatureProvider` to add transaction signature functionality.
extension ArisenReferenceAuthenticatorSignatureProvider {

    /// Handle transaction signature requests in the payload.
    ///
    /// - Parameter payload: The transaction signature `ResponsePayload`.
    public static func handleIncomingTransactionSignature(payload: ResponsePayload) {
        guard let completion = transactionSignatureCompletions[payload.id] else { return }
        transactionSignatureCompletions[payload.id] = nil
        guard let transactionSignatureResponse = payload.response.transactionSignature else { return }
        DispatchQueue.main.async {
            return completion(transactionSignatureResponse.toArisenTransactionSignatureResponse)
        }
    }

    /// The structure for `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureRequest.Transaction`.
    public struct Transaction: Codable {
        /// The array of signatures
        public var signatures = [String]()
        /// The compression
        public var compression = 0
        /// The packed context free data
        public var packedContextFreeData = ""
        /// The packed trx
        public var packedTrx = ""

        /// Initializer for `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureRequest.Transaction`
        /// - Parameters:
        ///   - signatures: The array of signatures
        ///   - compression: The compression
        ///   - packedContextFreeData: The packed context free data
        ///   - packedTrx: The packed trx
        init(signatures: [String]? = nil, compression: Int? = 0, packedContextFreeData: String? = nil, packedTrx: String? = nil) {
            self.signatures = signatures ?? [String]()
            self.compression = compression ?? 0
            self.packedContextFreeData = packedContextFreeData ?? ""
            self.packedTrx = packedTrx ?? ""
        }
    }

    /// The transaction signature request.
    /// Conforms to the `transactionSignature` property of the request protocol at: https://github.com/ARISENIO/arisen-authentication-transport-protocol-spec
    public struct TransactionSignatureRequest: Codable {
        /// The transaction info containing any exisitng signatures, compression, packedContextFreeData and packedTrx.
        public var transaction = Transaction()
        /// The chain ID as a `String`.
        public var chainId = ""
        /// An array of public keys identifying the private keys with which the transaction should be signed.
        public var publicKeys = [String]()
        /// An array of `BinaryAbi`s sent along so that signature providers can display transaction information to the user.
        public var abis = [BinaryAbi]()
        /// Should the signature provider be allowed to modify the transaction? E.g., adding an assert action. Defaults to `true`.
        public var isModificationAllowed: Bool?

        /// The structure for `BinaryAbi`s.
        public struct BinaryAbi: Codable { // swiftlint:disable:this nesting
            /// The account name for the contract, as a `String`.
            public var accountName = ""
            /// The binary representation of the ABI as a `String`.
            public var abi = ""
            /// Initializer for the `BinaryAbi`.
            public init() { }

            /// Initializer for the `BinaryAbi`.
            /// - Parameters:
            ///   - accountName: The account name
            ///   - abi: The abi as a hex string
            public init(accountName: String, abi: String) {
                self.accountName = accountName
                self.abi = abi
            }
        }

        /// Initializer for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureRequest`.
        public init() { }

        /// Initializer for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureRequest` with an `ArisenTransactionSignatureRequest`
        /// - Parameter arisenTransactionSignatureRequest: An `ArisenTransactionSignatureRequest`.
        public init(arisenTransactionSignatureRequest: ArisenTransactionSignatureRequest) {
            self.transaction = Transaction(packedTrx: arisenTransactionSignatureRequest.serializedTransaction.hex)
            self.chainId = arisenTransactionSignatureRequest.chainId
            self.publicKeys = arisenTransactionSignatureRequest.publicKeys
            self.isModificationAllowed = arisenTransactionSignatureRequest.isModificationAllowed
            self.abis = arisenTransactionSignatureRequest.abis.map({ (abi) -> TransactionSignatureRequest.BinaryAbi in
                return TransactionSignatureRequest.BinaryAbi(accountName: abi.accountName, abi: abi.abi)
            })
        }
    }

    /// The structure for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse`.
    /// Conforms to the `transactionSignature` property of the response protocol at: https://github.com/ARISENIO/arisen-authentication-transport-protocol-spec
    public struct TransactionSignatureResponse: Codable {
        /// The signed transaction.
        public var signedTransaction: Transaction?
        /// An optional error.
        public var error: ArisenError?

        public var toArisenTransactionSignatureResponse: ArisenTransactionSignatureResponse {
            var response = ArisenTransactionSignatureResponse()
            response.error = self.error
            if let signatures = self.signedTransaction?.signatures, let packedTrx = self.signedTransaction?.packedTrx {
                if let serializedTransaction = try? Data(hex: packedTrx) {
                    var signedTransaction = ArisenTransactionSignatureResponse.SignedTransaction()
                    signedTransaction.serializedTransaction = serializedTransaction
                    signedTransaction.signatures = signatures
                    response.signedTransaction = signedTransaction
                }
            }
            return response
        }

        /// Initializer for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse`.
        public init() { }

        /// Initializer for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse` when it contains an error.
        ///
        /// - Parameter error: The error as an `ArisenError`.
        public init(error: ArisenError) {
            self.error = error
        }

        /// Initializer for the `ArisenReferenceAuthenticatorSignatureProvider.TransactionSignatureResponse` with an `ArisenTransactionSignatureResponse`
        /// - Parameter ArisenTransactionSignatureResponse: An `ArisenTransactionSignatureResponse`
        public init(arisenTransactionSignatureResponse: ArisenTransactionSignatureResponse) {
            let signatures = arisenTransactionSignatureResponse.signedTransaction?.signatures
            let packedTrx = arisenTransactionSignatureResponse.signedTransaction?.serializedTransaction.hex
            self.signedTransaction = Transaction(signatures: signatures, packedTrx: packedTrx)
            self.error = arisenTransactionSignatureResponse.error
        }
    }

    /// Sign transaction implementation method.  Required to conform to `ArisenSignatureProviderProtocol`.
    ///
    /// - Parameter request: The `ArisenTransactionSignatureRequest` being sent to the Arisen Reference iOS Authenticator App.
    /// - Parameter completion: The completion closure to be called with the `ArisenTransactionSignatureResponse`.
    public func signTransaction(request: ArisenTransactionSignatureRequest, completion: @escaping (ArisenTransactionSignatureResponse) -> Void) {

        var payload = RequestPayload()
        payload.request.transactionSignature = TransactionSignatureRequest(ArisenTransactionSignatureRequest: request)
        payload.requireBiometric = requireBiometric

        ArisenReferenceAuthenticatorSignatureProvider.transactionSignatureCompletions[payload.id] = completion

        // check that return url is valid
        guard isValid(url: returnUrl) else {
            return completion(ArisenTransactionSignatureResponse(error: ArisenError(.signatureProviderError, reason: "Return url is not valid")))
        }
        payload.returnUrl = returnUrl
        payload.declaredDomain = declaredDomain
        payload.securityExclusions = securityExclusions

        // if callback url provided, check that callback url is valid
        if let callbackUrl = callbackUrl {
            guard isValid(url: callbackUrl) else {
                return completion(ArisenTransactionSignatureResponse(error: ArisenError(.signatureProviderError, reason: "Callback url is not valid")))
            }
            payload.callbackUrl = callbackUrl
        }

        print("PAYLOAD")
        print(payload)

        // encode the payload
        let encoder = JSONEncoder()
        guard let encodedPayload = try? encoder.encode(payload) else {
            return completion(ArisenTransactionSignatureResponse(error: ArisenError(.signatureProviderError, reason: "Unable to encode payload")))
        }

        // create url
        guard let url = URL(string: "arisen://request?payload=\(encodedPayload.hex)") else {
            return completion(ArisenTransactionSignatureResponse(error: ArisenError(.signatureProviderError, reason: "Unable to create url")))
        }
        print(url)

        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:]) { (success) in
                print(success)
            }
        }

    }

    private func isValid(url: String) -> Bool {
        if URL(string: url) != nil {
            return true
        } else {
            return false
        }
    }

}
