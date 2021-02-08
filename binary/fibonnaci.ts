var one = 0
var two = 1
let wieOft = input(<wie of? (viele,manche,einpaar)>)
var wieOftZahl = 0
if equals(wieOft,<viele>) {
wieOftZahl = 1000
} elif equals(wieOft,<manche>) {
wieOftZahl = 100
} elif equals(wieOft,<einpaar>) {
wieOftZahl = 10
} else {
error <bitte>
}


let fibonacci = (){
    if not(equals(wieOftZahl,0)) {
       let fib = add(one,two)
       one = two
       two = fib
       fibonacci()
    }
}
fibonacci()
