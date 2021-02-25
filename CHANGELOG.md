## [1.0.0] - Release

* Offizieler erster release

## [1.1.0] - formatted_input lets you input functions, which can be executed

* formattedInput can detect type and convert the Txt to it, including real executable functions

* Idee: return a {return} (function die nach return gemacht wird, wenn dort die function kind der function ist in der sie gerufen wird)

* Line: #line (swift) #os #os_version #functions #date #date_int #use/import

* Idee: errorFormattedInput das ein error gibt wenn es kein typ ist

* Idee: Type @Num (@Int und @Kom)

* Idee: Type @All für alle types

* Idee: formattedInput und errorFormattedInput müssen beide einen typ bekommen dürfen oder mehrere (und gucken ob es diese typen sind)

* Character und Line fangen bei 0 an

* Error Codes: 0:Before Compile; 1:String/Parse; 2:Doesnt make sense; 3:Runtime Warning; 4: Runtime Error;

* Idee: (0,0,0) ist ein array aber gleichzeitig ein caller
: ist ein operator der entweder versucht die klammern in ein array zu konvertieren, oder ein function mit einer variable ruft die ein array enthält
var a = :(0,0,0) //doppel punkt ist nicht nötig, er soll nur feststellen ob
let b = {$[a,b,c] = absent (heist das der default value absent ist, ohne das würde es crashen wenn es einen parameter zu wenig gäbe) (dollar zeichen ist noch nicht sicher)
var i = 0
while (#parameters)
return $0 + $1 + $2
}
b:a
b:(0,0,0)
b(0,0,0)

(0,absent,0)==(0,,0)

$ all parameters
$0 first parameter
var a = :(a, a, )
b = a$1 first element of a

* Idee: mit $ kann man die einzelnen variablen callen also $0, $12, $intvar (auch mit variablen)

* alte function: (a, b, c){ 
*
*                }
* neue function: {[a, b, c]
*                 
*
*                }
* $[a, b, c] ist wie [a = $0, b = $1, c = $2]

*[var a, let b, c = 24, let b = <b>] ist auch möglich
* neue hashtags #parameter_count 


hashtags:#parameter_count; #line; #os, #os_version, #all_functions, #ts_functions, #types, #date, #formatted_data (nicht #use/#import)
neue typen: @num, @all, @arr (Typen kleingeschrieben)

*range: @rng, 1...2, range(1,2)

*parser soll checken ob die variable/konstanten namen keine ts oder libary function-namen sind

*assert, operator, prefix and postfix (prefix ist operator der vor etwas ist wie !a, und postfix ist dahinter (sie können beide nur ein parameter haben))

*input: input(?message), formatted_input(?message,?default,?types...),error_formatted_input(?message,?types), looped_formatted_input(?message,?types), error_custom_input(message,function), looped_custom_input(message,function)

*@int + @kom = @num 

*@any - @fnc = @nfn (non functional)
*@any - @arr = @nls (non list)

*all_types(@nfn) -> (@int,@kom,@bol,@txt,@arr)

funktionen: default(a,b) : a ? b (wie ?? in dart)
funktionen: default_list(a,b) : a ?? b (mit einer liste und den gegenteil)j

prefix, suffix and operator gültigkeit:
prefix !0
suffix 0!
operator 0!1
operator 0 ! 1
prefix   0 !1
suffix   0! 1

