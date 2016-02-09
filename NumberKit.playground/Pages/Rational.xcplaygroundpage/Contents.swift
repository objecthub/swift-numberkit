//: ## Rational Numbers

func bfact(n: Int) -> BigInt {
  return n < 2 ? BigInt(n)
               : (2...n).reduce(BigInt(1)) { $0 * BigInt($1) }
}

Rational(2,-4)

let r99 = Rational(bfact(99))
let r_100 = Rational(BigInt(1), bfact(100))

r99 * r_100

//: [◀︎ Previous](@previous) &nbsp;&nbsp;&nbsp;&nbsp; [Next ▶︎](@next)
