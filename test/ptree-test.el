(require 'ptree)

;; Property tree tests

(ert-deftest ptree-test-empty ()
  (should (equal (ptree-empty) '(nil))))

(ert-deftest ptree-test-category-p ()
  (should (eq (ptree-category-p '(nil)) t))
  (should (eq (ptree-category-p '(nil "tsst" (nil))) t))
  (should (eq (ptree-category-p '(nil "test" (void . nil))) t))
  (should (eq (ptree-category-p '(nil "test" (number . 42))) t))
  (should (eq (ptree-category-p '(nil 0 (number . 42))) t))
  (should (eq (ptree-category-p '(nil test (number . 42))) t))
  (should (eq (ptree-category-p '(nil "test" (nil "test2" (number . 42)))) t))
  (should (eq (ptree-category-p '(generic . 42)) nil))
  (should (eq (ptree-category-p '(string . "a")) nil)))

(ert-deftest ptree-test-property-p ()
  (should (eq (ptree-property-p '(nil)) nil))
  (should (eq (ptree-property-p '(nil "tsst" (nil))) nil))
  (should (eq (ptree-property-p '(nil "test" (void . nil))) nil))
  (should (eq (ptree-property-p '(nil "test" (number . 42))) nil))
  (should (eq (ptree-property-p '(nil 0 (number . 42))) nil))
  (should (eq (ptree-property-p '(nil test (number . 42))) nil))
  (should (eq (ptree-property-p '(nil "test" (nil "test2" (number . 42)))) nil))
  (should (eq (ptree-property-p '(generic . 42)) t))
  (should (eq (ptree-property-p '(string . "a")) t)))

(ert-deftest ptree-test-property-type ()
  (should-error (ptree-property-type '(nil)) :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil "test" (nil)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil "test" (void . nil)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil "test" (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil 0 (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil test (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-type '(nil "test" (nil "test2" (number . 42))))
                :type 'ptree-not-a-property)
  (should (eq (ptree-property-type '(generic . 42)) 'generic))
  (should (eq (ptree-property-type '(string . "a")) 'string)))

(ert-deftest ptree-test-property-value ()
  (should-error (ptree-property-value '(nil)) :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil "test" (nil)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil "test" (void . nil)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil "test" (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil 0 (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil test (number . 42)))
                :type 'ptree-not-a-property)
  (should-error (ptree-property-value '(nil "test" (nil "test2" (number . 42))))
                :type 'ptree-not-a-property)
  (should (eq (ptree-property-value '(generic . 42)) 42))
  (should (equal (ptree-property-value '(string . "a")) "a")))

(ert-deftest ptree-test-set-property ()
  (should-error (ptree-set-property '(nil) 9) :type 'ptree-not-a-property)
  (should-error (ptree-set-property '(nil "test" (nil)) 9 'number)
                :type 'ptree-not-a-property)
  (let ((node (list 'generic 42)))
    (ptree-set-property node 9)
    (should (equal node '(generic . 9)))
    (ptree-set-property node "aaa" 'string)
    (should (equal node '(string . "aaa")))))

(ert-deftest ptree-test-child-nodes-num ()
  (should (eq (ptree-child-nodes-num '(generic 42)) 0))
  (should (eq (ptree-child-nodes-num '(nil)) 0))
  (should (eq (ptree-child-nodes-num '(nil "test" (nil))) 1))
  (should (eq (ptree-child-nodes-num '(nil "test" (void . nil))) 1))
  (should (eq (ptree-child-nodes-num '(nil "test" (number . 42))) 1))
  (should (eq (ptree-child-nodes-num '(nil "test" (nil "test2" (void . nil))))
              1))
  (should (eq (ptree-child-nodes-num '(nil 0 (void . nil) 1 (number . 42)
                                     2 (string . "a"))) 3))
  (should (eq (ptree-child-nodes-num '(nil 0 (void . nil) 'a (number . 42)
                                     "a" (number . 9))) 3))
  (should (eq (ptree-child-nodes-num '(nil 0 (void . nil) 1 (void . nil)
                                     2 (void . nil)
                                     3 (nil 31 (void . nil))
                                     4 (nil 41 (void . nil))
                                     5 (nil 51 (void . nil)))) 6)))

(ert-deftest ptree-test-child-node-at-index ()
  (should (eq (ptree-child-node-at-index '(general 42) 0) nil))
  (should (eq (ptree-child-node-at-index '(nil) 0) nil))
  (should (eq (ptree-child-node-at-index '(nil) 1) nil))
  (let* ((child-1 '(nil "test" (void . nil)))
         (child-2 '(number . 42))
         (child-3 '(string . "a"))
         (child-4 '(nil))
         (root (list nil 0 child-1 1 child-2 2 child-3 3 child-4)))
    (should (eq (ptree-child-node-at-index root 0) child-1))
    (should (eq (ptree-child-node-at-index root 1) child-2))
    (should (eq (ptree-child-node-at-index root 2) child-3))
    (should (eq (ptree-child-node-at-index root 3) child-4))
    (should (eq (ptree-child-node-at-index root 4) nil))))

(ert-deftest ptree-test-child-node-with-tag ()
  (should (eq (ptree-child-node-with-tag '(nil) 'a) nil))
  (should (eq (ptree-child-node-with-tag '(generic . 42) 'a) nil))
  (let* ((child-1 '(nil "test" (void . nil)))
         (child-2 '(number . 42))
         (child-3 '(string . "a"))
         (child-4 '(nil))
         (root (list nil 0 child-1 1 child-2 'test child-3 "test" child-4)))
    (should (eq (ptree-child-node-with-tag root 0) child-1))
    (should (eq (ptree-child-node-with-tag root 1) child-2))
    (should (eq (ptree-child-node-with-tag root 'test) child-3))
    (should (eq (ptree-child-node-with-tag root "test") child-4))
    (should (eq (ptree-child-node-with-tag root -1) nil))
    (should (eq (ptree-child-node-with-tag root "tooth") nil))))

(ert-deftest ptree-test-add-category ()
  (should-error (ptree-add-category '(generic . 42) "test")
                :type 'ptree-not-a-category)
  (should-error (ptree-add-category '(nil "test" (nil)) "test")
                :type 'ptree-node-already-existing)
  (let ((root (list nil)))
    (should (equal (ptree-add-category root "test") '(nil)))
    (should (equal root '(nil "test" (nil)))))
  (let ((root (list nil 'test '(generic . 42))))
    (should (equal (ptree-add-category root 0) '(nil)))
    (should (equal root '(nil 0 (nil) test (generic . 42)))))
  (let ((root (list nil 'test '(generic . 42))))
    (should (equal (ptree-add-category root "test") '(nil)))
    (should (equal root '(nil test (generic . 42) "test" (nil)))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil "test2" (nil)))))
    (should (equal (ptree-add-category root 'test) '(nil)))
    (should (equal root '(nil 0 (generic . 42) test (nil) "test"
                              (nil "test2" (nil)))))))

(ert-deftest ptree-test-add-property ()
  (should-error (ptree-add-property '(generic . 42) "test" 9)
                :type 'ptree-not-a-category)
  (should-error (ptree-add-property '(nil "test" (nil)) "test" 9)
                :type 'ptree-node-already-existing)
  (let ((root (list nil)))
    (should (equal (ptree-add-property root "test" 9) '(generic . 9)))
    (should (equal root '(nil "test" (generic . 9)))))
  (let ((root (list nil 'test '(generic . 42))))
    (should (equal (ptree-add-property root 0 9 'number) '(number . 9)))
    (should (equal root '(nil 0 (number . 9) test (generic . 42)))))
  (let ((root (list nil 'test '(generic . 42))))
    (should (equal (ptree-add-property root "test" "a" 'string) '(string ."a")))
    (should (equal root '(nil test (generic . 42) "test" (string . "a")))))

  (let ((root (list nil 0 '(generic . 42) "test" '(nil "test2" (nil)))))
    (should (equal (ptree-add-property root 'test 'abc) '(generic . abc)))
    (should (equal root '(nil 0 (generic . 42) test (generic . abc) "test"
                              (nil "test2" (nil)))))))

(ert-deftest ptree-test-delete-child-node ()
  (should-error (ptree-delete-child-node '(generic . 42) "test")
                :type 'ptree-not-a-category)
  (let* ((child-1 '(generic . 42))
         (child-2 '(nil))
         (child-3 '(nil "test2" (nil)))
         (root (list nil 0 child-1 'test child-2 "test" child-3)))
    (should-error (ptree-delete-child-node root -1)
                  :type 'ptree-node-not-existing)
    (should-error (ptree-delete-child-node root 'taste)
                  :type 'ptree-node-not-existing)
    (should-error (ptree-delete-child-node root "taste")
                  :type 'ptree-node-not-existing)
    (should-error (ptree-delete-child-node root "toast")
                  :type 'ptree-node-not-existing))
  (let* ((child-1 '(generic . 42))
         (child-2 '(nil))
         (child-3 '(nil "test2" (nil)))
         (root (list nil 0 child-1 'test child-2 "test" child-3)))
    (ptree-delete-child-node root 0)
    (should (equal root (list nil 'test child-2 "test" child-3))))
  (let* ((child-1 '(generic . 42))
         (child-2 '(nil))
         (child-3 '(nil "test2" (nil)))
         (root (list nil 0 child-1 'test child-2 "test" child-3)))
    (ptree-delete-child-node root 'test)
    (should (equal root (list nil 0 child-1 "test" child-3))))
  (let* ((child-1 '(generic . 42))
         (child-2 '(nil))
         (child-3 '(nil "test2" (nil)))
         (root (list nil 0 child-1 'test child-2 "test" child-3)))
    (ptree-delete-child-node root "test")
    (should (equal root (list nil 0 child-1 'test  child-2)))))

(ert-deftest ptree-test-node-at-path ()
  (let* ((child-1 '(nil))
         (child-2-1-1 '(string . "a"))
         (child-2-1-2 '(string . "b"))
         (child-2-1-3 '(string . "c"))
         (child-2-1 (list nil 'a child-2-1-1 'b child-2-1-2
                          'c child-2-1-3))
         (child-2-2-1 '(string . "aaa"))
         (child-2-2-2 '(string . "bbb"))
         (child-2-2 (list nil "a" child-2-2-1 "b" child-2-2-2))
         (child-2 (list nil "letters" child-2-1 "strings" child-2-2))
         (child-3-1-1-1 '(symbol . z))
         (child-3-1-1 (list nil 'y child-3-1-1-1))
         (child-3-1 (list nil 'x child-3-1-1))
         (child-3 (list nil 'symbols child-3-1))
         (root (list nil 0 child-1 1 child-2 2 child-3)))
    (should (eq (ptree-node-at-path root 0) child-1))
    (should (eq (ptree-node-at-path root '(0)) child-1))
    (should (eq (ptree-node-at-path root '(1)) child-2))
    (should (eq (ptree-node-at-path root '(1 "letters")) child-2-1))
    (should (eq (ptree-node-at-path root '(1 "letters" a)) child-2-1-1))
    (should (eq (ptree-node-at-path root '(1 "letters" b)) child-2-1-2))
    (should (eq (ptree-node-at-path root '(1 "letters" c)) child-2-1-3))
    (should (eq (ptree-node-at-path root '(1 "strings")) child-2-2))
    (should (eq (ptree-node-at-path root '(1 "strings" "a")) child-2-2-1))
    (should (eq (ptree-node-at-path root '(1 "strings" "b")) child-2-2-2))
    (should (eq (ptree-node-at-path root 2) child-3))
    (should (eq (ptree-node-at-path root '(2)) child-3))
    (should (eq (ptree-node-at-path root '(2 symbols)) child-3-1))
    (should (eq (ptree-node-at-path root '(2 symbols x)) child-3-1-1))
    (should (eq (ptree-node-at-path root '(2 symbols x y)) child-3-1-1-1))
    (should (eq (ptree-node-at-path root '(2 symbols x y z)) nil))
    (should (eq (ptree-node-at-path root '(2 symbols x z)) nil))
    (should (eq (ptree-node-at-path root 3) nil))))

(ert-deftest ptree-test-write-categories-at-path ()
  (let ((root (list nil)))
    (should (equal (ptree-write-categories-at-path root '(0 "test" test)) nil))
    (should (equal root '(nil 0 (nil "test" (nil test (nil)))))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil))))
    (should (equal (ptree-write-categories-at-path root 'test 'a 'b 'c)
                   '(nil)))
    (should (equal root '(nil 0 (generic . 42) test (nil a (nil) b (nil)
                                                         c (nil))
                              "test" (nil)))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil))))
    (should (equal (ptree-write-categories-at-path root '(0 1 2) 'a 'b 'c)
                   '(nil)))
    (should (equal root '(nil 0 (nil 1 (nil 2 (nil a (nil) b (nil) c (nil))))
                              "test" (nil)))))
  (let ((root (list nil "test" '(nil 0 (generic . 42) 2 (nil)))))
    (should (equal (ptree-write-categories-at-path root "test" '1)
                   '(nil)))
    (should (equal root '(nil "test" (nil 0 (generic . 42) 1 (nil)
                                          2 (nil))))))
  (let* ((child-1 (list nil "a" (list nil)))
         (root (list nil "test" (list nil 0 child-1))))
    (should (eq (ptree-write-categories-at-path root "test" '0) child-1))))

(ert-deftest ptree-test-write-properties-at-path ()
  (let ((root (list nil)))
    (should (equal (ptree-write-properties-at-path root '(0 "test" test)) nil))
    (should (equal root '(nil 0 (nil "test" (nil test (nil)))))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil))))
    (should (equal (ptree-write-properties-at-path root 'test '("a" . 9))
                   '(generic . 9)))
    (should (equal root '(nil 0 (generic . 42) test (nil "a" (generic . 9))
                              "test" (nil)))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil))))
    (should (equal (ptree-write-properties-at-path root '("tooth" 0 int)
                                                   '("a" 9 . number))
                   '(number . 9)))
    (should (equal root '(nil 0 (generic . 42) "test" (nil)
                              "tooth" (nil 0 (nil int (nil "a"
                                                           (number . 9))))))))
  (let ((root (list nil 0 '(generic . 42) "test" '(nil))))
    (should (equal (ptree-write-properties-at-path root '(0 1 2) '("a" . 9)
                                                   '(b 10 . integer)
                                                   '(c 20 . currency))
                   '(currency . 20)))
    (should (equal root '(nil 0 (nil 1 (nil 2 (nil b (integer . 10)
                                                   c (currency . 20)
                                                   "a" (generic . 9))))
                              "test" (nil)))))
  (let ((root (list nil "test" '(nil 0 (generic . 42) 2 (nil)))))
    (should (equal (ptree-write-properties-at-path root "test" '(1 . 9))
                   '(generic . 9)))
    (should (equal root '(nil "test" (nil 0 (generic . 42) 1 (generic . 9)
                                          2 (nil))))))
  (let ((root (list nil "test" '(nil 0 (nil)))))
    (should (equal (ptree-write-properties-at-path root "test" '(0 . 9))
                   '(generic . 9)))
    (should (equal root '(nil "test" (nil 0 (generic . 9)))))))



;; (ert-deftest ptree-test-set-value-at-path ()
;;   (let ((pt (list nil nil nil)))
;;     (should (eq (ptree-set-value-at-path pt nil 42) nil))
;;     (should (equal pt '(nil nil nil))))
;;   (let ((pt (list "test" nil (list 'one 9) (list 'zero 3))))
;;     (should (eq (ptree-set-value-at-path pt nil 42) t))
;;     (should (equal pt '("test" 42))))
;;   (let ((pt (list "test" 42)))
;;     (should (eq (ptree-set-value-at-path pt nil 9) t))
;;     (should (equal pt '("test" 9)))
;;     (should (eq (ptree-set-value-at-path pt 0 "a") t))
;;     (should (equal pt '("test" nil (0 "a")))))
;;   (let ((pt (list "test" nil
;;                   (list 'one nil (list 'zero nil nil))
;;                   (list 'zero 3))))
;;     (should (eq (ptree-set-value-at-path pt 'zero 42) t))
;;     (should (equal pt '("test" nil (one nil (zero nil nil)) (zero 42))))
;;     (should (eq (ptree-set-value-at-path pt '(one zero) 9) t))
;;     (should (equal pt '("test" nil (one nil (zero 9)) (zero 42))))
;;     (should (eq (ptree-set-value-at-path pt 'one 3) t))
;;     (should (equal pt '("test" nil (one 3) (zero 42)))))
;;   (let ((pt (list nil nil nil)))
;;     (should (eq (ptree-set-value-at-path pt '(0 1 2) 42) t))
;;     (should (equal pt '(nil nil (0 nil (1 nil (2 42))))))))

;; (ert-deftest ptree-test-set-branches-at-path ()
;;   (let ((pt (list nil nil nil)))
;;     (should (eq (ptree-set-branches-at-path pt nil) nil))
;;     (should (equal pt '(nil nil nil)))
;;     (should (equal (ptree-set-branches-at-path pt nil "zero" 0 'zero)
;;                    '(zero nil nil)))
;;     (should (equal pt '(nil nil (0 nil nil) (zero nil nil) ("zero" nil nil))))
;;     (should (equal (ptree-set-branches-at-path pt nil "zero" 0 'zero)
;;                    '(zero nil nil)))
;;     (should (equal pt '(nil nil (0 nil nil) (zero nil nil) ("zero" nil nil)))))
;;   (let ((pt (list nil nil nil)))
;;     (should (equal (ptree-set-branches-at-path pt nil 0 0 0 0 0 0 0 0)
;;                    '(0 nil nil)))
;;     (should (equal pt '(nil nil (0 nil nil))))
;;     (should (equal (ptree-set-branches-at-path pt 0 1 2 3)
;;                    '(3 nil nil)))
;;     (should (equal pt '(nil nil (0 nil (1 nil nil) (2 nil nil) (3 nil nil)))))
;;     (should (equal (ptree-set-branches-at-path pt '(0 2) "a" "b")
;;                    '("b" nil nil)))
;;     (should (equal pt '(nil nil (0 nil (1 nil nil) (2 nil
;;                                                       ("a" nil nil)
;;                                                       ("b" nil nil))
;;                                    (3 nil nil)))))
;;     (should (equal (ptree-set-branches-at-path pt 0 2)
;;                    '(2 nil ("a" nil nil) ("b" nil nil))))
;;     (should (equal pt '(nil nil (0 nil (1 nil nil) (2 nil
;;                                                       ("a" nil nil)
;;                                                       ("b" nil nil))
;;                                    (3 nil nil))))))
;;   (let ((pt (list nil nil (list 'one nil (list 0 42)))))
;;     (should (equal (ptree-set-branches-at-path pt '(one 0 "t") 'zero 'two)
;;                    '(two nil nil)))
;;     (should (equal pt '(nil nil (one nil (0 nil ("t" nil (two nil nil)
;;                                                  (zero nil nil)))))))))

;; (ert-deftest ptree-test-set-leaves-at-path ()
;;   (let ((pt (list nil nil (list 0 nil nil) (list "test" 42))))
;;     (should (eq (ptree-set-leaves-at-path pt nil) nil))
;;     (should (equal pt '(nil nil (0 nil nil) ("test" 42))))
;;     (should (equal (ptree-set-leaves-at-path pt nil '(0 0) '(1 1) '(2 2)
;;                                              '("test" "xyz") '(one two))
;;                    '(one two)))
;;     (should (equal pt '(nil nil (0 0) (1 1) (2 2) (one two) ("test" "xyz")))))
;;   (let ((pt (list nil nil (list 0 nil nil) (list 1 42)
;;                   (list 2 nil (list 'one 9)))))
;;     (should (equal (ptree-set-leaves-at-path pt 0 '(5 "test"))
;;                    '(5 "test")))
;;     (should (equal pt '(nil nil (0 nil (5 "test")) (1 42) (2 nil (one 9)))))
;;     (should (equal (ptree-set-leaves-at-path pt 1 '(6 one))
;;                    '(6 one)))
;;     (should (equal pt '(nil nil (0 nil (5 "test")) (1 nil (6 one))
;;                             (2 nil (one 9)))))
;;     (should (equal (ptree-set-leaves-at-path pt '(1 2) '(3 "a"))
;;                    '(3 "a")))
;;     (should (equal pt '(nil nil (0 nil (5 "test"))
;;                             (1 nil (2 nil (3 "a")) (6 one))
;;                             (2 nil (one 9)))))
;;     (should (equal (ptree-set-leaves-at-path pt '(2 one 3) '(4 "b") '(5 "c")
;;                                              '(6 "d"))
;;                    '(6 "d")))
;;     (should (equal pt '(nil nil (0 nil (5 "test"))
;;                             (1 nil (2 nil (3 "a")) (6 one))
;;                             (2 nil (one nil (3 nil (4 "b")
;;                                                (5 "c")
;;                                                (6 "d"))))))))
;;   (let ((pt (list nil nil (list 'a0 nil (list 'b0 0) (list 'b1 1)))))
;;     (should (equal (ptree-set-leaves-at-path pt '(a0 0 c0) '(d0 0) '(d1 1))
;;                    '(d1 1)))
;;     (should (equal pt '(nil nil (a0 nil (0 nil (c0 nil (d0 0) (d1 1)))
;;                                     (b0 0) (b1 1)))))
;;     ))


;; (ert-deftest ptree-test-delete-nodes-at-path ()
;;   (let ((pt (list nil nil (list 0 42)
;;                   (list 'zero nil (list "zero" 9))
;;                   (list "one" nil)
;;                   (list "zero" nil (list 0 nil (list 'zero 3))))))
;;     (should (equal (ptree-delete-nodes-at-path pt nil 'one) '(one)))
;;     (should (equal (ptree-delete-nodes-at-path pt nil 1) '(1)))
;;     (should (equal (ptree-delete-nodes-at-path pt nil "two") '("two")))
;;     (should (eq (ptree-delete-nodes-at-path pt nil) nil))
;;     (should (equal pt '(nil nil (0 42) (zero nil ("zero" 9))
;;                             ("one" nil)
;;                             ("zero" nil (0 nil (zero 3))))))
;;     (should (eq (ptree-delete-nodes-at-path pt nil "zero") nil))
;;     (should (equal pt '(nil nil (0 42) (zero nil ("zero" 9))
;;                             ("one" nil))))
;;     (should (eq (ptree-delete-nodes-at-path pt nil "one") nil))
;;     (should (equal pt '(nil nil (0 42) (zero nil ("zero" 9)))))
;;     (should (eq (ptree-delete-nodes-at-path pt nil 0 'zero) nil))
;;     (should (equal pt '(nil nil nil))))
;;   (let ((pt (list nil nil (list 0 42)
;;                   (list 'zero nil (list "zero" 9))
;;                   (list "one" nil)
;;                   (list "zero" nil (list 0 nil (list 'zero 3))))))
;;     (should (equal (ptree-delete-nodes-at-path pt '("zero" 0) 'zero 'one)
;;                 '(one)))
;;     (should (equal pt '(nil nil (0 42) (zero nil ("zero" 9)) ("one" nil)
;;                             ("zero" nil (0 nil nil)))))
;;     (should (eq (ptree-delete-nodes-at-path pt 'zero "zero") nil))
;;     (should (equal pt '(nil nil (0 42) (zero nil nil) ("one" nil)
;;                             ("zero" nil (0 nil nil)))))
;;     (should (eq (ptree-delete-nodes-at-path pt nil 0 'zero "one" "zero") nil))
;;     (should (equal pt '(nil nil nil)))))

;; ;; Property tree iterator tests

;; (ert-deftest ptree-test-iter ()
;;   (let* ((pt '("test" nil (zero 42) (one 9) (two 3)))
;;          (iter (ptree-iter pt)))
;;     (should (eq (car iter) pt))
;;     (should (equal (cdr iter) '(nil)))))

;; (ert-deftest ptree-test-iter-node ()
;;   (let* ((pt '("test" nil (zero 42)))
;;          (iter (ptree-iter pt)))
;;     (should (eq (ptree-iter-node iter) pt))))

;; (ert-deftest ptree-test-iter-move-to-tag ()
;;   (let* ((child-3 '(zero 42))
;;          (child-2 (list "test" nil '("one" nil nil) child-3))
;;          (child-1 (list 0 nil child-2 '("ZZZ" 9)))
;;          (root (list nil nil '(-1 nil nil) child-1 '(1 "a")))
;;          (iter (ptree-iter root))
;;          (old-iter (copy-seq iter)))
;;     (should (eq (ptree-iter-move-to-tag iter 10) nil))
;;     (should (eq (car iter) root))
;;     (should (equal (cdr iter) '(nil)))
;;     (should (eq (ptree-iter-move-to-tag iter 0) t))
;;     (should (eq (car iter) child-1))
;;     (should (equal (cdr iter) (list old-iter '(1 "a"))))
;;     (should (eq (ptree-iter-move-to-tag iter "abc") nil))
;;     (should (eq (car iter) child-1))
;;     (should (equal (cdr iter) (list old-iter '(1 "a"))))
;;     (setq old-iter (copy-seq iter))
;;     (should (eq (ptree-iter-move-to-tag iter "test") t))
;;     (should (eq (car iter) child-2))
;;     (should (equal (cdr iter) (list old-iter '("ZZZ" 9))))
;;     (should (eq (ptree-iter-move-to-tag iter 'two) nil))
;;     (should (eq (car iter) child-2))
;;     (should (equal (cdr iter) (list old-iter '("ZZZ" 9))))
;;     (setq old-iter (copy-seq iter))
;;     (should (eq (ptree-iter-move-to-tag iter 'zero) t))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list old-iter)))
;;     (should (eq (ptree-iter-move-to-tag iter 0) nil))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list old-iter)))))

;; (ert-deftest ptree-test-iter-move-down ()
;;   (let* ((child-3 '(zero 42))
;;          (child-2 (list "test" nil child-3 '("one" nil nil)))
;;          (child-1 (list 0 nil child-2 '("ZZZ" 9)))
;;          (root (list nil nil child-1))
;;          (iter (ptree-iter root))
;;          (old-iter (copy-seq iter)))
;;     (should (eq (ptree-iter-move-down iter) t))
;;     (should (eq (car iter) child-1))
;;     (should (equal (cdr iter) (list old-iter)))
;;     (setq old-iter (copy-seq iter))
;;     (should (eq (ptree-iter-move-down iter) t))
;;     (should (eq (car iter) child-2))
;;     (should (equal (cdr iter) (list old-iter '("ZZZ" 9))))
;;     (setq old-iter (copy-seq iter))
;;     (should (eq (ptree-iter-move-down iter) t))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list old-iter '("one" nil nil))))
;;     (should (eq (ptree-iter-move-down iter) nil))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list old-iter '("one" nil nil))))))

;; (ert-deftest ptree-test-iter-move-up ()
;;   (let* ((child-31 '(zero 42))
;;          (child-32 '("one" nil nil))
;;          (child-21 (list "test" nil child-31 child-32))
;;          (child-22 '("ZZZ" 9))
;;          (child-1 (list 0 nil child-21 child-22))
;;          (root (list nil nil child-1))
;;          (iter (ptree-iter root)))
;;     (let ((iter-0 (copy-seq iter)))
;;       (ptree-iter-move-down iter)
;;       (let ((iter-1 (copy-seq iter)))
;;         (ptree-iter-move-down iter)
;;         (let ((iter-2 (copy-seq iter)))
;;           (ptree-iter-move-down iter)
;;           (should (eq (ptree-iter-move-up iter) t))
;;           (should (equal iter iter-2)))
;;         (should (eq (ptree-iter-move-up iter) t))
;;         (should (equal iter iter-1)))
;;       (should (eq (ptree-iter-move-up iter) t))
;;       (should (equal iter iter-0))
;;       (should (eq (ptree-iter-move-up iter) nil)))))

;; (ert-deftest ptree-test-iter-move-next ()
;;   (let* ((child-1 '(zero 42))
;;          (child-2 '(0 nil nil))
;;          (child-3 '("test" nil (one 9)))
;;          (parent (list "a" nil child-1 child-2 child-3))
;;          (iter (ptree-iter parent)))
;;     (ptree-iter-move-down iter)
;;     (should (eq (ptree-iter-move-next iter) t))
;;     (should (eq (car iter) child-2))
;;     (should (equal (cdr iter) (list (list parent nil) child-3)))
;;     (should (eq (ptree-iter-move-next iter) t))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list (list parent nil))))
;;     (should (eq (ptree-iter-move-next iter) nil))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter) (list (list parent nil))))))

;; (ert-deftest ptree-test-iter-move-previous ()
;;   (let* ((child-1 '(0 nil nil))
;;          (child-2 '(zero 42))
;;          (child-3 '("test" nil (one 9)))
;;          (parent (list "a" nil child-1 child-2 child-3))
;;          (iter (ptree-iter parent)))
;;     (ptree-iter-move-down iter)
;;     (let ((iter-0 (copy-seq iter)))
;;       (ptree-iter-move-next iter)
;;       (let ((iter-1 (copy-seq iter)))
;;         (ptree-iter-move-next iter)
;;         (should (eq (ptree-iter-move-previous iter) t))
;;         (should (equal iter iter-1)))
;;       (should (eq (ptree-iter-move-previous iter) t))
;;       (should (equal iter iter-0)))
;;     (should (eq (ptree-iter-move-previous iter) nil))))

;; (ert-deftest ptree-test-iter-add-branch-and-move ()
;;   (let* ((child-1 (list "test" nil (list 'zero 42)))
;;          (root (list nil nil child-1))
;;          (iter (ptree-iter root)))
;;     (ptree-iter-add-branch-and-move iter 'zero)
;;     (should (equal (car iter) '(zero nil nil)))
;;     (should (equal (cdr iter) '(((nil nil (zero nil nil)
;;                                       ("test" nil (zero 42))) nil)
;;                                 ("test" nil (zero 42)))))
;;     (setq iter (ptree-iter root))
;;     (ptree-iter-add-branch-and-move iter "test")
;;     (should (equal (car iter) '("test" nil (zero 42))))
;;     (should (equal (cdr iter) '(((nil nil (zero nil nil)
;;                                       ("test" nil (zero 42))) nil))))
;;     (setq iter (ptree-iter root))
;;     (ptree-iter-add-branch-and-move iter "zero")
;;     (should (equal (car iter) '("zero" nil nil)))
;;     (should (equal (cdr iter) '(((nil nil (zero nil nil)
;;                                       ("test" nil (zero 42))
;;                                       ("zero" nil nil)) nil))))))

;; (ert-deftest ptree-test-iter-delete-node ()
;;   (let* ((child-1 '(zero 42))
;;          (child-2 '(0 nil nil))
;;          (child-3 '("test" nil (one 9)))
;;          (parent (list "a" nil child-1 child-2 child-3))
;;          (iter (ptree-iter parent)))
;;     (ptree-iter-move-down iter)
;;     (should (eq (ptree-iter-delete-node iter) child-1))
;;     (should (eq (car iter) child-2))
;;     (should (equal (cdr iter)
;;                    '((("a" nil (0 nil nil) ("test" nil (one 9))) nil)
;;                      ("test" nil (one 9)))))
;;     (should (eq (ptree-iter-delete-node iter) child-2))
;;     (should (eq (car iter) child-3))
;;     (should (equal (cdr iter)
;;                    '((("a" nil ("test" nil (one 9))) nil))))
;;     (should (eq (ptree-iter-delete-node iter) child-3))
;;     (should (eq (car iter) parent))
;;     (should (equal (cdr iter) '(nil)))
;;     (should (eq (ptree-iter-delete-node iter) nil))))

;; (ert-deftest ptree-test-to-string ()
;;   (let ((pt '(nil nil
;;                   (current-users 12)
;;                   (desktop nil (background-color "black"))
;;                   (windows nil
;;                            ("xterm" nil
;;                             (pos-x 50)
;;                             (pos-y 100)
;;                             (width 500)
;;                             (height 200))
;;                            ("emacs" nil
;;                             (pos-x 600)
;;                             (pos-y 0)
;;                             (width 1000)
;;                             (height 800)))
;;                   (processes nil
;;                              (by-id nil
;;                                     (0 "startx")
;;                                     (1 "dbus-launch")
;;                                     (2 "X"))))))
;;     (should (string= (ptree-to-string pt) "current-users: 12
;; desktop
;;     background-color: black
;; windows
;;     \"xterm\"
;;         pos-x: 50
;;         pos-y: 100
;;         width: 500
;;         height: 200
;;     \"emacs\"
;;         pos-x: 600
;;         pos-y: 0
;;         width: 1000
;;         height: 800
;; processes
;;     by-id
;;         0: startx
;;         1: dbus-launch
;;         2: X\n"))
;;   ))

;; Test launcher

(defun ptree-run-tests ()
  (interactive)
  (ert-run-tests-interactively "ptree-test-"))
