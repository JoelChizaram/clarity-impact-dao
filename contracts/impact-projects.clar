;; Impact Projects Contract

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
