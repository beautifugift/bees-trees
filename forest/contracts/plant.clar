;; Bees & Trees - Land Registration Smart Contract

;; Define the main data structure for land registry
(define-map land-registry
  {plot-id: uint}
  {
    owner: principal,
    location: (string-utf8 100),
    size: uint,
    tree-count: uint
  }
)

;; Keep track of the total number of registered plots
(define-data-var total-plots uint u0)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u1)
(define-constant ERR-PLOT-EXISTS u2)
(define-constant ERR-PLOT-NOT-FOUND u3)

;; Register a new plot of land
(define-public (register-plot 
    (plot-id uint) 
    (location (string-utf8 100)) 
    (size uint) 
    (tree-count uint))
  (if (is-some (map-get? land-registry {plot-id: plot-id}))
  
    ;; Plot already exists
    (err ERR-PLOT-EXISTS)
    ;; Plot doesn't exist, register it
    (begin
      (map-set land-registry 
        {plot-id: plot-id} 
        {
          owner: tx-sender,
          location: location,
          size: size,
          tree-count: tree-count
        }
      )
      (var-set total-plots (+ (var-get total-plots) u1))
      (ok true)
    )
  )
)

;; Transfer ownership of a plot
(define-public (transfer-plot (plot-id uint) (new-owner principal))
  (match (map-get? land-registry {plot-id: plot-id})
    plot-data
    (if (is-eq (get owner plot-data) tx-sender)
      (begin
        (map-set land-registry 
          {plot-id: plot-id} 
          (merge plot-data {owner: new-owner})
        )
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (err ERR-PLOT-NOT-FOUND)
  )
)

;; Update plot metadata
(define-public (update-plot-data 
    (plot-id uint) 
    (location (string-utf8 100)) 
    (size uint) 
    (tree-count uint))
  (match (map-get? land-registry {plot-id: plot-id})
    plot-data
    (if (is-eq (get owner plot-data) tx-sender)
      (begin
        (map-set land-registry 
          {plot-id: plot-id} 
          {
            owner: (get owner plot-data),
            location: location,
            size: size,
            tree-count: tree-count
          }
        )
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (err ERR-PLOT-NOT-FOUND)
  )
)

;; Update just the tree count (common operation for Bees & Trees)
(define-public (update-tree-count (plot-id uint) (new-tree-count uint))
  (match (map-get? land-registry {plot-id: plot-id})
    plot-data
    (if (is-eq (get owner plot-data) tx-sender)
      (begin
        (map-set land-registry 
          {plot-id: plot-id} 
          (merge plot-data {tree-count: new-tree-count})
        )
        (ok true)
      )
      (err ERR-NOT-AUTHORIZED)
    )
    (err ERR-PLOT-NOT-FOUND)
  )
)

;; Read-only function to get plot information
(define-read-only (get-plot-info (plot-id uint))
  (map-get? land-registry {plot-id: plot-id})
)

;; Read-only function to get total registered plots
(define-read-only (get-total-plots)
  (var-get total-plots)
)