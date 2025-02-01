;; Core DAO Contract

;; Constants
(define-constant min-proposal-threshold u100000) ;; Min tokens needed to create proposal
(define-constant voting-period u144) ;; ~24 hours in blocks

;; Data structures
(define-map proposals
  { proposal-id: uint }
  {
    creator: principal,
    title: (string-ascii 50),
    description: (string-utf8 500),
    amount: uint,
    recipient: principal,
    start-block: uint,
    end-block: uint,
    yes-votes: uint,
    no-votes: uint,
    executed: bool
  }
)

;; Proposal management
(define-public (create-proposal 
  (title (string-ascii 50))
  (description (string-utf8 500))
  (amount uint)
  (recipient principal))
  (let
    ((proposal-id (+ u1 (var-get proposal-counter)))
     (token-balance (unwrap! (contract-call? .governance-token get-balance tx-sender) (err u401))))
    (asserts! (>= token-balance min-proposal-threshold) (err u402))
    (map-set proposals
      { proposal-id: proposal-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        amount: amount,
        recipient: recipient,
        start-block: block-height,
        end-block: (+ block-height voting-period),
        yes-votes: u0,
        no-votes: u0,
        executed: false
      }
    )
    (ok proposal-id)
  )
)
