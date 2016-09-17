precedencegroup ResultKMonadicPrecedenceRight {
    associativity: right
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup ResultKMonadicPrecedenceLeft {
    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
    higherThan: AssignmentPrecedence
}

precedencegroup ResultKApplicativePrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator >>- : ResultKMonadicPrecedenceLeft
infix operator -<< : ResultKMonadicPrecedenceRight

infix operator <^> : ResultKApplicativePrecedence
infix operator <*> : ResultKApplicativePrecedence
