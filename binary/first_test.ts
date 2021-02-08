let text = <press 1 to hack into local library
press 2 to hack into local policeStation>
let secondText = <
in library(press q to go out)>
let thirdText = <
in policestatin(press q to go out)>
var where = 0

let inputChecker = (){
if equals(where,1) {
output(secondText)
} elif equals(where,2) {
output(thirdText)
} elif equals(where,0) {
output(text)
}
let _input = input(<please select one of them>)
if equals(where,0) {
if equals(_input,<1>) {
 where = 1
} elif equals(_input,<2>) {
 where 2
} elif equals(_input,<stop>) {
 return absent
 }
} else {
if equals(_input,<q>) {
 where = 0
} elif equals(_input,<stop>) {
return absent
}
}
inputChecker()
}
inputChecker()