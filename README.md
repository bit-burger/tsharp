# tonyscript

the best scripting language written in dart

## Benutzen


#### Variablen und Konstanten deklarieren
``` javascript
variable a = 34
constant b = a
```
#### Variablen verschiedenen Werten zuweisen
``` javascript
a = 34
a = <a>
a = 0.1
a = true
a = absent
```
#### Variablen und Konstanten modifizieren
``` javascript
a = add(4,a)
a = subtract(a,1)
a = multiply(a,34)
a = divide(a,3)
```
#### Funktionen zuweisen und nutzten
``` javascript
a = (){
  b = 5
}
a()
```
#### Werte zurückgeben und Parameter nutzen
``` javascript
constant plusEins = (uno){
  return add(uno,1))
}
a = plusEins(1)
```
#### Funktionen direkt nutzten
``` javascript
a = (){
  return 5
}()
```
#### Funktionen in Funktionen nutzen
``` javascript
constant zweimal = (func){
  func()
  func()
}
variable d = 0
constant c = {
  d = add(d,1)
}
zweimal(c)
```
#### If, Elif, Else
``` javascript
var a = true
if a {
  output(<a is true>)
} elif not(a) {
  output(<a is false>)
} else {
  output(<this shouldnt happen>)
}
```
#### Basis Funktionen
``` javascript
//Mit zwei Zahlen (Int,Kom)
add(a,b)
subtract(a,b)
multiply(a,b)
divide(a,b)
smaller(a,b)
bigger(a,b)
min(a,b)
max(a,b)

//Bol
and(a,b)
or(a,b)
either(a,b)
not(a)

//Alle Typen
equals(a,b)
type(a,b)
isAbsent(a)
ea(a,b)

//Konversion
Int(a)
Kom(a)
Num(a)
Txt(a)
Bol(a)

//Txt manipulation
hex(str)                  -> Int
lIndex(str)               -> Int
rIndex(str)               -> Int
containing(str,subs)      -> Int
count(str)                -> Int
sub(str,front,back)       -> Txt
ucase(str)                -> Txt
lcase(str)                -> Txt
reverse(str)              -> Txt
give(str,index)           -> Txt
giveLast(str)             -> Txt
insert(str,index)         -> Txt
remove(str,index)         -> Txt
removelast()              -> Txt
replace(str,subs,replace) -> Txt
//I/O
output(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z) //give as many arguments as you want to
input(<ask user something>)
input() //can also be optional
formatted_input(<ask user something else>)
formatted_input( //message is also optional
```

#### ea(a,b)
``` javascript
//Mit ea(a,b) kann man jeden Wert kombinieren
//Mit add(a,b) kann man nur zwei vom gleichen Typen kombinieren
//Bsp.: ea(5,<yallah>) -> <5yallah> 
//Bsp.: ea(5,5.0) -> 10.0
//Dabei gibt es eine Rangfolge zu beachten
//Diese kennzeichnet welcher Typ von beiden übernommen wird
//Rangfolge Txt->Kom->Int->Bol->Absent
//1. Ausnahme: Wenn ein Wert vom Typen func ist, wird der Typ zu einem Txt
//2. Ausnahme: Bol mit Txt = false/true; Bol mit Int = 0/1; Bol mit Kom = 0.0/1.0; 
```

###### ea Tabelle

| ️ | `<Hi>` | `5.1` | `5` | `true` | `absent` |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **`<Hi>`** | `<HiHi>` | `<5.1Hi>` | `<5Hi>` | `<trueHi>` | `<Hi>` |
| **`5.1`** | `<Hi5.1>` | `10.2` | `10.1` | `6.1` | `5.1` |
| **`5`** | `<Hi5>` | `10.1` | `10` | `6` | `5` |
| **`true`** | `<trueHi>` | `6.1` | `6` | `true` | `true` |
| **`absent`** | `<Hi>` | `5.1` | `5` | `true` | `absent` |