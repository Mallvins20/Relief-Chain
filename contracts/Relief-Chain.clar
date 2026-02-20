;; ============================================================
;; ReliefChain v1.0
;; Disaster Relief Supply Tracker
;; ============================================================

;; ================================
;; ERRORS
;; ================================

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-SUPPLY-NOT-FOUND (err u101))
(define-constant ERR-INSUFFICIENT-SUPPLY (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))

;; ================================
;; CONTRACT OWNER
;; ================================

(define-data-var contract-owner principal tx-sender)

;; ================================
;; ADMIN MANAGEMENT
;; ================================

(define-map admins
  { admin: principal }
  { authorized: bool }
)

;; Add admin (only owner)
(define-public (add-admin (new-admin principal))
  (if (is-eq tx-sender (var-get contract-owner))
      (begin
        (map-set admins { admin: new-admin } { authorized: true })
        (ok true)
      )
      ERR-NOT-AUTHORIZED
  )
)

;; Remove admin (only owner)
(define-public (remove-admin (admin principal))
  (if (is-eq tx-sender (var-get contract-owner))
      (begin
        (map-delete admins { admin: admin })
        (ok true)
      )
      ERR-NOT-AUTHORIZED
  )
)

;; Check if sender is admin or owner
(define-read-only (is-authorized (user principal))
  (if (is-eq user (var-get contract-owner))
      true
      (default-to false (get authorized (map-get? admins { admin: user })))
  )
)

;; ================================
;; SUPPLY STRUCTURE
;; ================================

(define-map supplies
  { supply-id: uint }
  {
    name: (string-ascii 50),
    total-donated: uint,
    total-distributed: uint,
    created-by: principal
  }
)

(define-data-var next-supply-id uint u1)

;; ================================
;; DISTRIBUTION RECORDS
;; ================================

(define-map distributions
  { record-id: uint }
  {
    supply-id: uint,
    quantity: uint,
    location: (string-ascii 100),
    distributor: principal
  }
)

(define-data-var next-record-id uint u1)

;; ================================
;; REGISTER NEW SUPPLY
;; ================================

(define-public (register-supply 
    (name (string-ascii 50)) 
    (initial-amount uint)
)

  (if (not (is-authorized tx-sender))
      ERR-NOT-AUTHORIZED

      (if (<= initial-amount u0)
          ERR-INVALID-AMOUNT

          (let ((id (var-get next-supply-id)))
            (map-set supplies
              { supply-id: id }
              {
                name: name,
                total-donated: initial-amount,
                total-distributed: u0,
                created-by: tx-sender
              }
            )
            (var-set next-supply-id (+ id u1))
            (ok id)
          )
      )
  )
)

;; ================================
;; ADD DONATION TO EXISTING SUPPLY
;; ================================

(define-public (add-donation (supply-id uint) (amount uint))

  (if (not (is-authorized tx-sender))
      ERR-NOT-AUTHORIZED

      (match (map-get? supplies { supply-id: supply-id })
        supply

          (if (<= amount u0)
              ERR-INVALID-AMOUNT

              (begin
                (map-set supplies
                  { supply-id: supply-id }
                  {
                    name: (get name supply),
                    total-donated: (+ (get total-donated supply) amount),
                    total-distributed: (get total-distributed supply),
                    created-by: (get created-by supply)
                  }
                )
                (ok true)
              )
          )

        ERR-SUPPLY-NOT-FOUND
      )
  )
)

;; ================================
;; RECORD DISTRIBUTION
;; ================================

(define-public (record-distribution 
    (supply-id uint) 
    (quantity uint) 
    (location (string-ascii 100))
)

  (if (not (is-authorized tx-sender))
      ERR-NOT-AUTHORIZED

      (match (map-get? supplies { supply-id: supply-id })
        supply

          (let (
                (remaining (- (get total-donated supply)
                              (get total-distributed supply)))
               )

            (if (<= quantity u0)
                ERR-INVALID-AMOUNT

                (if (>= remaining quantity)

                    (begin
                      ;; Update supply totals
                      (map-set supplies
                        { supply-id: supply-id }
                        {
                          name: (get name supply),
                          total-donated: (get total-donated supply),
                          total-distributed: (+ (get total-distributed supply) quantity),
                          created-by: (get created-by supply)
                        }
                      )

                      ;; Store distribution record
                      (let ((record-id (var-get next-record-id)))
                        (map-set distributions
                          { record-id: record-id }
                          {
                            supply-id: supply-id,
                            quantity: quantity,
                            location: location,
                            distributor: tx-sender
                          }
                        )
                        (var-set next-record-id (+ record-id u1))
                        (ok record-id)
                      )
                    )

                    ERR-INSUFFICIENT-SUPPLY
                )
            )
          )

        ERR-SUPPLY-NOT-FOUND
      )
  )
)

;; ================================
;; READ-ONLY FUNCTIONS
;; ================================

(define-read-only (get-supply (supply-id uint))
  (map-get? supplies { supply-id: supply-id })
)

(define-read-only (get-distribution (record-id uint))
  (map-get? distributions { record-id: record-id })
)

(define-read-only (get-remaining (supply-id uint))
  (match (map-get? supplies { supply-id: supply-id })
    supply
      (- (get total-donated supply)
         (get total-distributed supply))
    u0
  )
)

(define-read-only (get-total-supplies)
  (- (var-get next-supply-id) u1)
)
