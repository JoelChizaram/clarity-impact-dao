;; Core DAO Contract

;; Constants
(define-constant min-proposal-threshold u100000) ;; Min tokens needed to create proposal
(define-constant voting-period u144) ;; ~24 hours in blocks
(define-constant quorum-threshold u100000) ;; Minimum total votes needed
(define-constant err-unauthorized (err u403))
(define-constant err-proposal-not-found (err u404))
(define-constant err-voting-closed (err u405))
(define-constant err-already-voted (err u406))
(define-constant err-quorum-not-reached (err u407))

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
  { amount: uint, vote-type: bool }
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
  (let (
    (proposal (unwrap! (map-get? proposals {proposal-id: proposal-id}) err-proposal-not-found))
    (previous-vote (map-get? votes {proposal-id: proposal-id, voter: tx-sender}))
    (balance (unwrap! (contract-call? .governance-token get-balance tx-sender) (err u401))))
    
    (asserts! (<= block-height (get end-block proposal)) err-voting-closed)
    (asserts! (is-none previous-vote) err-already-voted)
    (asserts! (>= balance amount) (err u401))
    
    ;; Lock tokens
    (try! (contract-call? .governance-token lock-tokens amount tx-sender))
    
    (map-set votes 
      {proposal-id: proposal-id, voter: tx-sender}
      {amount: amount, vote-type: vote-for}
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

(define-public (execute-proposal (proposal-id uint))
  (let (
    (proposal (unwrap! (map-get? proposals {proposal-id: proposal-id}) err-proposal-not-found))
    (total-votes (+ (get yes-votes proposal) (get no-votes proposal))))
    
    (asserts! (> block-height (get end-block proposal)) err-voting-closed)
    (asserts! (not (get executed proposal)) (err u408))
    (asserts! (>= total-votes quorum-threshold) err-quorum-not-reached)
    
    (if (> (get yes-votes proposal) (get no-votes proposal))
      (begin
        (map-set proposals {proposal-id: proposal-id}
          (merge proposal {executed: true}))
        (ok true))
      (err u409))
  )
)
