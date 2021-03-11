# Types

@abs
@arr
@bol
@fnc
@int
@kom
@rng
@str
@typ

@any = (any) @abs + @arr + @bol + @fnc + @int + @kom + @rng + @str + @typ
@acc (accessible) = @fnc + @arr + @str
@pri (primitive) = @bol + @int + @kom + @str
@ite (iterable) = @arr + @rng + @str + @typ
@num (numbers) = @kom + @int
@nnu (non nullable) = @any - @abs

# Functions

equal(@any,@any) -> @bol ==
unequal(@any,@any) -> @bol !=
missing(@any) -> @bol ? (pre)

and(@bol,@bol) -> @bol &&
or(@bol,@bol) -> @bol ||
either(@bol,@bol) -> @bol |
not(@bol) -> @bol ! (pre)

is_type(@any,@typ) -> @bol ===
is_not_type(@any,@typ) -> @bol !==
is_types(@arr,@arr) -> @bol ====
is_not_types(@arr,@arr) -> @bol !===
is_same_type(@typ,@typ) -> @bol 

switch(@bol,@arr) -> @any ?
alternative(@any,@any) -> @any ??
option(@any,@arr,@arr) 

to_type(@any,@typ) -> @any =>
arr(@rng)/(@†yp)/(@any...) -> @arr ; (pre/operator)
bol(@str) -> @bol
int(@str)/(@kom) -> @int
kom(@str)/(@int)/(@int,@int) -> @kom .
num(@str) -> @num
rng(@int,@int) -> @rng ...
str(@pri) -> @str
typ(@typ...) -> @typ

### dispatch
dispatch(@int,@fnc) -> @bol
wait(@int) -> @abs

timer_start(@int,@fnc) -> @str
timer_stop(@str) -> @bol

repeat_start(@int,@fnc) -> @str
repeat_start(@str) -> @bol
repeat_change(@str,@fnc) -> @bol

event_spawn(@str,@fnc,@str?) -> @bol (letzter string ist identifier)
event_kill(@str) -> @bol (killt process mit dem identifier)
event_list(@str) -> @arr (alle funktionen Identifier von einem process)

### @typ
arr(@typ) -> @arr
typ(@arr) -> @typ

add(@typ,@typ) -> @typ +
subtract(@typ,@typ) -> @typ -

nullable(@typ) -> @typ ? (post)
non_nullable(@typ) -> @typ ! (post)

includes(@typ,@typ) -> @bol

### @rng
first(@rng) -> @int
last(@rng) -> @int
arr(@rng) -> @arr

### @fnc

single_access(@fnc,@any?) -> @any : (post/operator)
multiple_access(@fnc,@arr) -> @any ::
safe_access(@fnc,@arr) -> @any :?
sandboxed_call(@fnc,@arr) -> @any :??
no_arg_call(@fnc,@arr)/(@arr,@fnc) -> @any .

### @arr/@str -> @s; @any/@str -> @item

single_access(@s,@int) -> @item :
multiple_access(@s,@arr) -> @arr ::
safe_access(@s,@int) -> @item :?

first(@s) -> @item
last(@s) -> @item

length(@s) -> @int
count(@s) -> @int

indexed(@s) -> @arr
enumerated(@s) -> @arr

map(@s,@fnc) -> @s
forEach(@s,@fnc) -> @abs
filter(@s,@fnc) -> @s
sort(@s,@fnc) -> @s

shift(@s,@int?) -> @s
unshift(@s,@item...) -> @s
pop(@s,@int?) -> @s
push(@s,@item...) -> @s

remove(@s,@int) -> @s
insert(@s,@int,@item...) -> @s
replace(@s,@rng,@s) -> @s
sub(@s,@int,@int)/(@s,@rng) -> @s
cut(@s,@int,@int)/(@s,@rng) -> @s

reverse(@s) -> @s

#### @str

trimLeft(@str) -> @str
trimRight(@str) -> @str
trim(@str) -> @str
sub(@str,@int,@int?) -> @str
subByLength(@str,@int,@int) -> @str

split(@str,@str)/(@str,@fnc?) -> @arr

lowercase(@str) -> @str
uppercase(@str) -> @str

starts_with(@str,@str) -> @bol
ends_with(@str,@str) -> @bol
contains(@str,@str) -> @bol
search(@str,@str) -> @arr (mit verschiedenen indexen)

removeFromFront(@str,@int) -> @str
removeFromBack(@str,@int) -> @str

#### @arr

fill(@arr,@int?,@int?) -> @arr
defill(@arr) -> @arr

### @num

add(@num,@num) -> @num +
subtract(@num,@num) -> @num -
multiply(@num,@num) -> @num *
divide(@num,@num) -> @num /

smaller(@num,@num) -> @num <
bigger(@num,@num) -> @num >

min(@num,@num) -> @bol
max(@num,@num) -> @bol

### in- and output

print(@any...)
debug_print(@any...)

output(@str) -> @abs >>
input(@str?) -> @abs

### math

pi

rest(@int,@int) -> @int %
pow(@num,@num?) -> @num ^
sqrt(@num,@num?) -> @num

cos(@num) -> @num
sin(@num) -> @num
tan(@num) -> @num

round_low()
round()

### random

random_int(@int?,@int?)/(@rng) -> @int
random_kom(@kom?,@kom?) -> @kom
random_bol() -> @bol
random_rng(@int,@int)/(@rng) -> @rng

random_element(@arr)/(@str) -> @any/@str
shuffle(@arr)/(@str) -> @arr/@str

uuid() -> @str

### parse

parseable(@str,@typ?) -> @bol
parse(@str,@typ?) -> @bol

debug_string(@str) -> @str
string(@str) -> @str

### analyze

validate_email(@str) -> @bol
validate_path(@str) -> @bol
validate_url(@str) -> @bol

get_email(@str,@str) -> @any
get_path(@str,@str) -> @any
get_url(@str,@str) -> @any

//funktionen die sich wiederholen, später mit farben markieren