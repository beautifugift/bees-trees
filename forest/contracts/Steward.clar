;; Beekeeper / Tree Steward Registration Contract
;; This contract allows users to register as stewards for managing trees and beekeeping
;; with optional staking to ensure commitment

;; Error codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-REGISTERED (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-STAKE-REQUIRED (err u104))


;; Data maps - FIXED: using curly braces instead of parentheses
(define-map stewards
  {steward: principal}
  {is-active: bool, trees-planted: uint, hives-installed: uint, staked-amount: uint, registration-time: uint}
)

;; Read-only functions
(define-read-only (get-steward (steward principal))
  (default-to 
    {is-active: false, trees-planted: u0, hives-installed: u0, staked-amount: u0, registration-time: u0}
    (map-get? stewards {steward: steward})
  )
)

(define-read-only (is-registered (steward principal))
  (is-some (map-get? stewards {steward: steward}))
)

(define-read-only (is-active-steward (steward principal))
  (let ((steward-data (get-steward steward)))
    (get is-active steward-data)
  )
)

;; Public functions
(define-public (register-steward (stake-amount uint))
  (let ((caller tx-sender))
    (if (is-registered caller)
      ERR-ALREADY-REGISTERED
      (begin
        (map-set stewards 
          {steward: caller} 
          {
            is-active: true, 
            trees-planted: u0, 
            hives-installed: u0, 
            staked-amount: stake-amount,
            registration-time: stacks-block-height
          }
        )
        (if (> stake-amount u0)
          (stx-transfer? stake-amount caller (as-contract tx-sender))
          (ok true)
        )
      )
    )
  )
)

(define-public (register-with-stake (stake-amount uint))
  (let ((caller tx-sender)
        (min-stake-amount u1000000)) ;; 1 STX minimum stake (adjust as needed)
    (if (< stake-amount min-stake-amount)
      ERR-STAKE-REQUIRED
      (register-steward stake-amount)
    )
  )
)

(define-public (deactivate-steward)
  (let ((caller tx-sender)
        (steward-data (get-steward caller)))
    (if (not (is-registered caller))
      ERR-NOT-REGISTERED
      (begin
        (map-set stewards 
          {steward: caller} 
          (merge steward-data {is-active: false})
        )
        (ok true)
      )
    )
  )
)

(define-public (reactivate-steward)
  (let ((caller tx-sender)
        (steward-data (get-steward caller)))
    (if (not (is-registered caller))
      ERR-NOT-REGISTERED
      (begin
        (map-set stewards 
          {steward: caller} 
          (merge steward-data {is-active: true})
        )
        (ok true)
      )
    )
  )
)

(define-public (withdraw-stake)
  (let ((caller tx-sender)
        (steward-data (get-steward caller))
        (staked-amount (get staked-amount steward-data)))
    (if (not (is-registered caller))
      ERR-NOT-REGISTERED
      (if (is-eq staked-amount u0)
        (err u105) ;; No stake to withdraw
        (begin
          ;; Update steward record
          (map-set stewards 
            {steward: caller} 
            (merge steward-data {staked-amount: u0})
          )
          ;; Transfer stake back to steward
          (as-contract (stx-transfer? staked-amount tx-sender caller))
        )
      )
    )
  )
)

(define-public (record-trees-planted (count uint))
  (let ((caller tx-sender)
        (steward-data (get-steward caller)))
    (if (not (is-active-steward caller))
      ERR-NOT-AUTHORIZED
      (begin
        (map-set stewards 
          {steward: caller} 
          (merge steward-data {trees-planted: (+ (get trees-planted steward-data) count)})
        )
        (ok true)
      )
    )
  )
)

(define-public (record-hives-installed (count uint))
  (let ((caller tx-sender)
        (steward-data (get-steward caller)))
    (if (not (is-active-steward caller))
      ERR-NOT-AUTHORIZED
      (begin
        (map-set stewards 
          {steward: caller} 
          (merge steward-data {hives-installed: (+ (get hives-installed steward-data) count)})
        )
        (ok true)
      )
    )
  )
)

;; Admin functions (could be protected by a trait or specific principal)
(define-public (admin-deactivate-steward (steward principal))
  (let ((caller tx-sender)
        (steward-data (get-steward steward)))
    (if (not (is-eq caller (var-get contract-owner)))
      ERR-NOT-AUTHORIZED
      (begin
        (map-set stewards 
          {steward: steward} 
          (merge steward-data {is-active: false})
        )
        (ok true)
      )
    )
  )
)

;; Contract owner (for admin functions)
(define-data-var contract-owner principal tx-sender)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set contract-owner new-owner))
  )
)
