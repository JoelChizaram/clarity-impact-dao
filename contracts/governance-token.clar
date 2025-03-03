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

;; Token locking
(define-map locked-tokens
  { owner: principal }
  { amount: uint }
)

;; Public functions
(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (let ((locked-amount (default-to u0 (get amount (map-get? locked-tokens {owner: sender})))))
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (asserts! (>= (- (ft-get-balance dao-token sender) locked-amount) amount) err-insufficient-balance)
    (ft-transfer? dao-token amount sender recipient)
  )
)

(define-public (lock-tokens (amount uint) (owner principal))
  (let (
    (current-locked (default-to u0 (get amount (map-get? locked-tokens {owner: owner}))))
    (new-locked-amount (+ current-locked amount)))
    (asserts! (>= (ft-get-balance dao-token owner) new-locked-amount) err-insufficient-balance)
    (map-set locked-tokens {owner: owner} {amount: new-locked-amount})
    (ok true)
  )
)

(define-public (unlock-tokens (amount uint) (owner principal))
  (let (
    (current-locked (default-to u0 (get amount (map-get? locked-tokens {owner: owner}))))
    (new-locked-amount (- current-locked amount)))
    (asserts! (>= current-locked amount) err-insufficient-balance)
    (map-set locked-tokens {owner: owner} {amount: new-locked-amount})
    (ok true)
  )
)

[... rest of the original contract functions ...]
