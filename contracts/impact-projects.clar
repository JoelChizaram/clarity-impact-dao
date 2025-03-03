;; Impact Projects Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-status (err u101))

;; Data Variables
(define-data-var project-counter uint u0)

;; Data structures
(define-map projects
  { project-id: uint }
  {
    name: (string-ascii 50),
    description: (string-utf8 500),
    impact-metrics: (list 10 (string-ascii 50)),
    funding: uint,
    status: (string-ascii 20)
  }
)

;; Project management
(define-public (create-project
  (name (string-ascii 50))
  (description (string-utf8 500))
  (impact-metrics (list 10 (string-ascii 50))))
  (let ((project-id (+ u1 (var-get project-counter))))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set project-counter project-id)
    (map-set projects
      { project-id: project-id }
      {
        name: name,
        description: description,
        impact-metrics: impact-metrics,
        funding: u0,
        status: "PROPOSED"
      }
    )
    (ok project-id)
  )
)

(define-public (update-project-status (project-id uint) (new-status (string-ascii 20)))
  (let ((project (unwrap! (map-get? projects {project-id: project-id}) (err u404))))
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (or (is-eq new-status "PROPOSED")
                 (is-eq new-status "ACTIVE")
                 (is-eq new-status "COMPLETED")
                 (is-eq new-status "CANCELLED")) err-invalid-status)
    (map-set projects
      {project-id: project-id}
      (merge project {status: new-status})
    )
    (ok true)
  )
)
