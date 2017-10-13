
func solveEquation(a: Double, b: Double, c: Double) -> (s1: Double?, s2: Double?) {
    let epsilon: Double = 0.000000001
    if (abs(a) < epsilon) {
        if (abs(b) < epsilon) {
            return (.none, .none)
        }
        let s = -c / b
        if (0.0 < s && s < 1.0) {
            return (s, .none)
        }
        return (.none, .none)
    }
    
    let b2ac = b * b - 4.0 * c * a
    if (b2ac < 0.0) {
        return (.none, .none)
    }
    let sqrtb2ac = b2ac.squareRoot()
    let s1 = (-b + sqrtb2ac) / (2.0 * a)
    var r1: Double? = .none
    if (s1 - epsilon > 0) && (s1 < 1.0) {
        r1 = s1
    }
    let s2 = (-b - sqrtb2ac) / (2.0 * a)
    var r2: Double? = .none
    if ((epsilon < s2) && (1-s2 > epsilon)) {
        r2 = s2
    }
    return (r1, r2)
}

func boundsWithDerivative(p0: Point, p1: Point, p2: Point, p3: Point) -> Rect? {
    let ax = 3 * p0.x + 9 * p1.x - 9 * p2.x + 3 * p3.x
    let bx = 6 * p0.x - 12 * p1.x + 6 * p2.x
    let cx = 3 * p1.x - 3 * p0.x
    let sx = solveEquation(a: ax, b: bx, c: cx)
    
    let ay = -1.0 * p0.y + 3.0 * p1.y - 3.0 * p2.y + 1.0 * p3.y
    let by = 3.0 * p0.y - 6.0 * p1.y + 3.0 * p2.y
    let cy = 3 * p1.y - 3 * p0.y
    let sy = solveEquation(a: ay, b: by, c: cy)

    let solutions = [sx.s1, sx.s2, sy.s1, sy.s2].flatMap { $0 }
    var minX:Double? = .none
    var minY:Double? = .none
    var maxX:Double? = .none
    var maxY:Double? = .none
    for s in solutions {
        let p = BezierFunc2D(s, p0: p0, p1: p1, p2: p2, p3: p3)
        if let mx = minX {
            if mx > p.x {
                minX = p.x
            }
        } else {
            minX = p.x
        }
        
        if let my = minY {
            if my > p.y {
                minY = p.y
            }
        } else {
            minY = p.y
        }
        
        if let mx = maxX {
            if mx < p.x {
                maxX = p.x
            }
        } else {
            maxY = p.x
        }
        
        if let my = maxY {
            if my < p.y {
                maxY = p.y
            }
        } else {
            maxY = p.y
        }
    }
    
    if let minX = minX, let maxX = maxX, let minY = minY, let maxY = maxY {
        return Rect(x: minX, y: minY, w: maxX - minX, h: maxY - minY)
    }
    
    return .none
}

func boundsForFunc(_ func2d: func2D) -> Rect {
  
  var p = func2d(0.0)
  var minX = p.x
  var minY = p.y
  var maxX = minX
  var maxY = minY
  
  for t in stride(from: 0.0, to: 1.0, by: 0.01) {
    p = func2d(t)
    
    if minX > p.x {
      minX = p.x
    }
    
    if minY > p.y {
      minY = p.y
    }
    
    if maxX < p.x {
      maxX = p.x
    }
    
    if maxY < p.y {
      maxY = p.y
    }
  }
  
  return Rect(x: minX, y: minY, w: maxX - minX, h: maxY - minY)
}
