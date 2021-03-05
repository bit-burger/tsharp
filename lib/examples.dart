import 'dart:io';

import 'package:tsharp/tsharp.dart';
import 'dart:typed_data';
import 'package:meta/meta.dart';

final example1 = '''
var a
a = 3
var b = 54
b = 232323
var c = 5
var f = <alödj>
a = (df){
  c = 5
  var d = (x){
    c = 10
    var c = 11
    f = x
  } 
  d(df)
}
a(25)

''';
final example2 = '''
var a = 2
var b = (d,d   ,e, d){
a = 3
}
b(5,5,5,5)
''';
final example3 = '''
var b
var a = (c){
  b = c
}
a(3)

''';
final example4 = '''
var b
var c
var a = (d,e){
  b = d
  c = e
}
a(5,10)

''';
final example5 = '''
var a
constant b = (d){
  var c = (e){
    a = e
  }
  c(d)
}
b(15)
''';

final example6 = '''
var a 
(){
a = b
}()
''';

final example7 = '''
var a 
(){
  (){
    a = 34
  }()
}(34)
''';

final example8 = '''
var a = <haha>
var b = (c){
  c()
}
b((){
  a = 5
})

''';
final example9 = '''
var a = 2
var b = (c,d){
c(d)
}
b((a){
a()
},(){
a = 4
})
''';
final example11 = '''
var a
var b = (e,f){
e(f)()
}
b((g){
    return (){
      a = g
    }
  },
  10
)
''';
//besitzt wohl einen falschen parent und kann deshalb auf e zugreifen aber nicht auf g
final example12 = '''
var b = (){
return (){
return 4
}
}
var a = b()()

''';
//error exapmles
const example13 = '''
var a = <4>
(){
a = 45
}()

''';

const example17 = '''
var a = (b){
  return b()
}
(b){
  a = b(b((){
    return (){
      return <yallah habibi>
    }
  }))
}(a)
''';

const example18 = '''
var a   =       either(  and(true  ,  false)  , or(  true  ,true  ))
var b = (){
return 2345
}()
var d = 2345
var c = equals(b,d)
var f
var k = type(d,5.0)
''';

const example19 = '''
let a = 45
var b = 56


(){
b = 0

a = 34
}
''';
const example20 = '''
let a = equals(2,input(<hihi>))
''';

const example21 = '''
var hi
let a = formatted_input()
a()
''';
