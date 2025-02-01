;; Governance Token Contract
(define-fungible-token dao-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))

;; Token info
(define-data-var token-name (string-ascii 32) "ImpactDAO Token")
(define-data-var token-symbol (string-ascii 10) "IMPACT")

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u102))
    (ft-transfer? dao-token amount sender recipient)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? dao-token amount recipient)
  )
)
