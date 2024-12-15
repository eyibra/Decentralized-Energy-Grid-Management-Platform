;; Smart Meter Integration Contract

(define-map smart-meters
  { meter-id: uint }
  {
    owner: principal,
    last-reading: uint,
    last-updated: uint
  }
)

(define-data-var meter-nonce uint u0)

(define-constant err-unauthorized (err u401))
(define-constant err-not-found (err u404))

(define-public (register-smart-meter (owner principal))
  (let
    (
      (meter-id (var-get meter-nonce))
    )
    (map-set smart-meters
      { meter-id: meter-id }
      {
        owner: owner,
        last-reading: u0,
        last-updated: block-height
      }
    )
    (var-set meter-nonce (+ meter-id u1))
    (ok meter-id)
  )
)

(define-public (update-meter-reading (meter-id uint) (reading uint))
  (let
    (
      (meter (unwrap! (map-get? smart-meters { meter-id: meter-id }) err-not-found))
    )
    (asserts! (is-eq (get owner meter) tx-sender) err-unauthorized)
    (ok (map-set smart-meters
      { meter-id: meter-id }
      (merge meter {
        last-reading: reading,
        last-updated: block-height
      })
    ))
  )
)

(define-public (report-energy-production (meter-id uint) (amount uint))
  (let
    (
      (meter (unwrap! (map-get? smart-meters { meter-id: meter-id }) err-not-found))
    )
    (asserts! (is-eq (get owner meter) tx-sender) err-unauthorized)
    (ok true)
  )
)

(define-public (report-energy-consumption (meter-id uint) (amount uint))
  (let
    (
      (meter (unwrap! (map-get? smart-meters { meter-id: meter-id }) err-not-found))
    )
    (asserts! (is-eq (get owner meter) tx-sender) err-unauthorized)
    (ok true)
  )
)

(define-read-only (get-meter-info (meter-id uint))
  (ok (unwrap! (map-get? smart-meters { meter-id: meter-id }) err-not-found))
)

