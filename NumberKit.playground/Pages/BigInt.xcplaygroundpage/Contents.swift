//: ## BigInt Numbers

func fact(n: Int) -> BigInt {
  guard n > 1 else {
    return 1
  }
  var res: BigInt = 1
  for i in 2...n {
    res = res * BigInt(i)
  }
  return res
}

BigInt(2) ** 256

fact(35)

//: [◀︎ Previous](@previous) &nbsp;&nbsp;&nbsp;&nbsp; [Next ▶︎](@next)
