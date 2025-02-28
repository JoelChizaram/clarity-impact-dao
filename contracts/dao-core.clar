;; Core DAO Contract

;; Constants
(define-constant min-proposal-threshold u100000) ;; Min tokens needed to create proposal
(define-constant voting-period u144) ;; ~24 hours in blocks
(define-constant err-unauthorized (err u403))
(define-constant err-proposal-not-found (err u404))
(define-constant err-voting-closed (err u405))

;; Data Variables
(define-data-var proposal-counter uint u0)

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

(define-map votes
  { proposal-id: uint, voter: principal }
  { amount: uint }
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
    (var-set proposal-counter proposal-id)
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

(define-public (vote (proposal-id uint) (vote-for bool) (amount uint))
  (let ((proposal (unwrap! (map-get? proposals {proposal-id: proposal-id}) err-proposal-not-found))
        (balance (unwrap! (contract-call? .governance-token get-balance tx-sender) (err u401))))
    (asserts! (<= block-height (get end-block proposal)) err-voting-closed)
    (asserts! (>= balance amount) (err u401))
    (map-set votes 
      {proposal-id: proposal-id, voter: tx-sender}
      {amount: amount}
    )
    (if vote-for
      (map-set proposals {proposal-id: proposal-id}
        (merge proposal {yes-votes: (+ (get yes-votes proposal) amount)}))
      (map-set proposals {proposal-id: proposal-id}
        (merge proposal {no-votes: (+ (get no-votes proposal) amount)}))
    )
    (ok true)
  )
)
