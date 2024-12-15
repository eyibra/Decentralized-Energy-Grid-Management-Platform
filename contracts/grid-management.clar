;; Grid Management Contract

(define-map grid-status
  { grid-id: uint }
  {
    total-supply: uint,
    total-demand: uint,
    last-updated: uint
  }
)

(define-map participant-status
  { participant: principal }
  {
    production: uint,
    consumption: uint,
    last-updated: uint
  }
)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))

(define-public (update-grid-status (grid-id uint) (supply uint) (demand uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set grid-status
      { grid-id: grid-id }
      {
        total-supply: supply,
        total-demand: demand,
        last-updated: block-height
      }
    ))
  )
)

(define-public (update-participant-status (participant principal) (production uint) (consumption uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set participant-status
      { participant: participant }
      {
        production: production,
        consumption: consumption,
        last-updated: block-height
      }
    ))
  )
)

(define-read-only (get-grid-status (grid-id uint))
  (map-get? grid-status { grid-id: grid-id })
)

(define-read-only (get-participant-status (participant principal))
  (map-get? participant-status { participant: participant })
)

(define-public (trigger-demand-response (grid-id uint) (reduction-target uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; In a real implementation, this would trigger demand response mechanisms
    ;; For now, we'll just update the grid status
    (let
      (
        (current-status (unwrap! (get-grid-status grid-id) (err u404)))
      )
      (ok (map-set grid-status
        { grid-id: grid-id }
        (merge current-status {
          total-demand: (- (get total-demand current-status) reduction-target),
          last-updated: block-height
        })
      ))
    )
  )
)

