;; Governance Token Contract
(define-fungible-token dao-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-not-authorized (err u102))

;; Data Variables
(define-data-var token-name (string-ascii 32) "ImpactDAO Token")
(define-data-var token-symbol (string-ascii 10) "IMPACT")
(define-data-var token-uri (optional (string-utf8 256)) none)
(define-data-var total-supply uint u0)

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (ft-transfer? dao-token amount sender recipient)
  )
)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set total-supply (+ (var-get total-supply) amount))
    (ft-mint? dao-token amount recipient)
  )
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance dao-token who))
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok u6)
)

(define-read-only (get-token-uri)
  (ok (var-get token-uri))
)
