;; Escrow Smart Contract
(define-data-var admin principal tx-sender)
(define-data-var next-escrow-id uint u0)

(define-map escrows
  uint ;; escrow-id
  {
    buyer: principal,
    seller: principal,
    mediator: (optional principal),
    amount: uint,
    deadline: uint,
    released: bool,
    disputed: bool
  }
)

;; Create Escrow: Buyer deposits STX for a seller
(define-public (create-escrow (seller principal) (mediator (optional principal)) (deadline uint) (amount uint))
  (let ((id (var-get next-escrow-id)))
    (begin
      (asserts! (> amount u0) (err u100))
      (asserts! (> deadline stacks-block-height) (err u101))
      ;; Transfer STX from buyer to contract
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set escrows id {
        buyer: tx-sender,
        seller: seller,
        mediator: mediator,
        amount: amount,
        deadline: deadline,
        released: false,
        disputed: false
      })
      (var-set next-escrow-id (+ id u1))
      (ok id)
    )
  )
)

;; Release Funds: Buyer confirms delivery, funds go to seller
(define-public (release-funds (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) (err u104))))
    (begin
      (asserts! (is-eq (get buyer escrow) tx-sender) (err u102))
      (asserts! (not (get released escrow)) (err u103))
      (asserts! (not (get disputed escrow)) (err u116))
      (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))
      (map-set escrows escrow-id (merge escrow { released: true }))
      (ok true)
    )
  )
)

;; Refund Buyer: If seller doesn't deliver before deadline
(define-public (refund (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) (err u107))))
    (begin
      (asserts! (>= stacks-block-height (get deadline escrow)) (err u105))
      (asserts! (not (get released escrow)) (err u106))
      (asserts! (not (get disputed escrow)) (err u117))
      (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get buyer escrow))))
      (map-set escrows escrow-id (merge escrow { released: true }))
      (ok true)
    )
  )
)

;; Raise Dispute: Buyer or seller can raise a dispute
(define-public (raise-dispute (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) (err u109))))
    (begin
      (asserts! (or (is-eq tx-sender (get buyer escrow)) (is-eq tx-sender (get seller escrow))) (err u108))
      (asserts! (not (get released escrow)) (err u118))
      (map-set escrows escrow-id (merge escrow { disputed: true }))
      (ok true)
    )
  )
)

;; Mediator resolves dispute: funds go to buyer or seller
(define-public (resolve-dispute (escrow-id uint) (release-to-seller bool))
  (let ((escrow (unwrap! (map-get? escrows escrow-id) (err u115))))
    (begin
      (asserts! (is-some (get mediator escrow)) (err u110))
      (asserts! (is-eq tx-sender (unwrap! (get mediator escrow) (err u111))) (err u112))
      (asserts! (get disputed escrow) (err u113))
      (asserts! (not (get released escrow)) (err u114))
      (if release-to-seller
        (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get seller escrow))))
        (try! (as-contract (stx-transfer? (get amount escrow) tx-sender (get buyer escrow))))
      )
      (map-set escrows escrow-id (merge escrow { released: true }))
      (ok true)
    )
  )
)

;; READ-ONLY: Get escrow details
(define-read-only (get-escrow (escrow-id uint))
  (ok (map-get? escrows escrow-id))
)

;; READ-ONLY: Get next escrow ID
(define-read-only (get-next-escrow-id)
  (ok (var-get next-escrow-id))
)