;; Energy Trading Contract

(define-map energy-orders
{ order-id: uint }
{
  seller: principal,
  amount: uint,
  price: uint,
  is-active: bool
}
)

(define-data-var order-nonce uint u0)

(define-constant err-invalid-order (err u102))
(define-constant err-order-not-active (err u104))

(define-public (create-sell-order (amount uint) (price uint))
(let
  (
    (order-id (var-get order-nonce))
  )
  (map-set energy-orders
    { order-id: order-id }
    {
      seller: tx-sender,
      amount: amount,
      price: price,
      is-active: true
    }
  )
  (var-set order-nonce (+ order-id u1))
  (ok order-id)
)
)

(define-public (cancel-sell-order (order-id uint))
(let
  (
    (order (unwrap! (map-get? energy-orders { order-id: order-id }) err-invalid-order))
  )
  (asserts! (is-eq (get seller order) tx-sender) (err u403))
  (asserts! (get is-active order) err-order-not-active)
  (ok (map-set energy-orders
    { order-id: order-id }
    (merge order { is-active: false })
  ))
)
)

(define-public (fulfill-order (order-id uint))
(let
  (
    (order (unwrap! (map-get? energy-orders { order-id: order-id }) err-invalid-order))
    (total-cost (* (get amount order) (get price order)))
  )
  (asserts! (get is-active order) err-order-not-active)
  (try! (stx-transfer? total-cost tx-sender (get seller order)))
  (map-set energy-orders
    { order-id: order-id }
    (merge order { is-active: false })
  )
  (ok true)
)
)

(define-read-only (get-order (order-id uint))
(ok (unwrap! (map-get? energy-orders { order-id: order-id }) err-invalid-order))
)
