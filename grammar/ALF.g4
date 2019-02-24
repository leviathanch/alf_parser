grammar ALF;

// Tokens
ALF_REVISION: 'ALF_REVISION';
ASSOCIATE: 'ASSOCIATE';
LIBRARY: 'LIBRARY';
PIN: 'PIN';
ATTRIBUTE: 'ATTRIBUTE';
PROPERTY: 'PROPERTY';
INCLUDE: 'INCLUDE';
ALIAS: 'ALIAS';
CONSTANT: 'CONSTANT';
CLASS: 'CLASS';
KEYWORD: 'KEYWORD';
SEMANTICS: 'SEMANTICS';
GROUP: 'GROUP';
TEMPLATE: 'TEMPLATE';
STATIC: 'STATIC';
DYNAMIC: 'DYNAMIC';
SUBLIBRARY: 'SUBLIBRARY';
CELL: 'CELL';
PINGROUP: 'PINGROUP';
PRIMITIVE: 'PRIMITIVE';
WIRE: 'WIRE';
NODE: 'NODE';
VECTOR: 'VECTOR';
LAYER: 'LAYER';
VIA: 'VIA';
RULE: 'RULE';
ANTENNA: 'ANTENNA';
BLOCKAGE: 'BLOCKAGE';
PORT: 'PORT';
SITE: 'SITE';
ARRAY: 'ARRAY';
PATTERN: 'PATTERN';
REGION: 'REGION';
COORDINATES: 'COORDINATES';
SHIFT: 'SHIFT';
ROTATE: 'ROTATE';
FLIP: 'FLIP';
REPEAT: 'REPEAT';
ARTWORK: 'ARTWORK';
FUNCTION: 'FUNCTION';
TEST: 'TEST';
BEHAVIOR: 'BEHAVIOR';
STRUCTURE: 'STRUCTURE';
STATETABLE: 'STATETABLE';
NON_SCAN_CELL: 'NON_SCAN_CELL';
RANGE: 'RANGE';
HEADER: 'HEADER';
TABLE: 'TABLE';
EQUATION: 'EQUATION';
MIN: 'MIN';
MAX: 'MAX';
TYP: 'TYP';
LIMIT: 'LIMIT';
FROM: 'FROM';
TO: 'TO';
EARLY: 'EARLY';
LATE: 'LATE';
VIOLATION: 'VIOLATION';

SemiColon: ';' ;
Colon: ':' ;
OpenSwirly: '{' ;
CloseSwirly: '}' ;
OpenSquareBracket: '[';
CloseSquareBracket: ']';

fragment AToF: [ABCDEFabcdef];

Plus: '+';
Minus: '-';
AtSign: '@';
Assign: '=';


fragment ZERO: '0';
fragment ONE: '1';
fragment Binary_digit: ZERO|ONE;
fragment Octal_digit: [2-7];
fragment Hexadecimal_digit: [2-9ABCDEFabcdef];
fragment Decimal_digit: [2-9];
fragment Digit: Decimal_digit|ZERO|ONE;

// See Syntax 1, 5.1
alf_statement:
	alf_type alf_name? (Assign alf_value)? alf_statement_termination
	| alf_from_to
	| header
	| table
	| pin
	| equation
	| cell
	;

alf_type: identifier | AtSign | Colon;

alf_name: identifier | control_expression;

alf_value:
	identifier
	| Number
	//| boolean_expression
	| control_expression
	| Quoted_string
	;

alf_statement_termination:
	SemiColon
	| OpenSwirly ( alf_value | Colon | SemiColon )+ CloseSwirly
	| OpenSwirly alf_statement+ CloseSwirly
	;

fragment Character: // See Syntax 2, 6.1
	Letter
	| Digit
	| Special
	| Whitespace
;

fragment Newline: '\n';

Whitespace: ([ \t\u000B\r\f] | Newline)  -> channel (HIDDEN);

Letter: [A-Za-z];

fragment Special: [&|^~/%?!'\\$_#\-+];

In_line_comment: '//' Character* [\n\r] -> channel (HIDDEN);
Block_comment: '/*' Character* '*/' -> channel (HIDDEN);

unary_operator: Plus | Minus;
arithmetic_operator: unary_operator | '*' | '/' | '%' | '**';

LogicAnd: '&&';
LogicOr: '||';
NotAnd: '~&';
NotOr: '~|';
Xor: '^';
NotXor: '~^';
Not: '~';
LogicNot: '!';
And: '&';
Or: '|';

Equal: '==';
NotEqual: '!=';
GreaterOrEqual: '>=';
LesserOrEqual: '<=';
Greater: '>';
Lesser: '<';

Relational_operator:
	Equal
	| NotEqual
	| GreaterOrEqual
	| LesserOrEqual
	| Greater
	| Lesser;

ShiftLeft: '<<';
ShiftRight: '>>';
Shift_operator: ShiftLeft | ShiftRight;

fragment ImmediatelyFollowedBy: '->';
fragment EventuallyFollowedBy: '~>';
fragment ImmediatelyFollowingEachOther: '<->';
fragment EventuallyFollowingEachOther: '<~>';
fragment SimultaneousOrImmediatelyFollowedBy: '&>';
fragment SimultaneousOrImmediatelyFollowingEachOther: '<&>';

Event_operator:
	ImmediatelyFollowedBy
	| EventuallyFollowedBy
	| ImmediatelyFollowingEachOther
	| EventuallyFollowingEachOther
	| SimultaneousOrImmediatelyFollowedBy
	| SimultaneousOrImmediatelyFollowingEachOther
	;

Number:
	Signed_integer
	| Signed_Real
	| Unsigned_integer
	| Unsigned_Real
	; // See Syntax 6, 6.5

unsigned_number: Unsigned_integer | Unsigned_Real;
Integer: Signed_integer | Unsigned_integer;
Signed_integer: Sign Unsigned_integer;

Unsigned_integer:
	Digit* Decimal_digit Digit* ('_'? Digit)*
	| Digit
	;

Signed_Real: Sign Unsigned_Real;
Unsigned_Real: Mantissa Exponent? | Unsigned_integer Exponent;

fragment Sign: [+-];
fragment Mantissa:
	'.' Digit+
	| Digit+ '.' Digit*;
fragment Exponent: [eE] Sign? Digit+;

index: OpenSquareBracket (a = alf_value) ( Colon b = alf_value )? CloseSquareBracket; // See Syntax 8, 6.6

Bit_literal:
	ZERO
	|ONE
	| '?'
	| '*'
//	Alphanumeric_bit_literal
//	| Symbolic_bit_literal
	; // See Syntax 11, 6.8

Alphanumeric_bit_literal:
	Numeric_bit_literal
	|Alphabetic_bit_literal
	;

Numeric_bit_literal: ZERO|ONE;
Symbolic_bit_literal: '?'|'*';
Alphabetic_bit_literal: [XZLHUWxzlhuw];

Based_literal:
	Binary_based_literal
	| Octal_Based_literal
	| Decimal_Based_literal
	| Hexadecimal_Based_literal; // See Syntax 12, 6.9

Binary_based_literal:
	Binary_base Bit_literal ('_'? Bit_literal)*;
Binary_base: '\'' [Bb];
Octal_Based_literal: Octal_base Octal_digit ('_'? Octal_digit)*;
fragment Octal_base: '\'' [Oo];

Decimal_Based_literal: Decimal_base Digit ('_'? Digit)*;

fragment Decimal_base: '\'' [Dd];
Hexadecimal_Based_literal:
	Hexadecimal_base Hexadecimal_digit ('_'? Hexadecimal_digit)*;
fragment Hexadecimal_base: '\'' [Hh];

Boolean_value:
	Alphanumeric_bit_literal
	| Based_literal
	| Integer
	; // See Syntax 13, 6.10

edge_literal: Bit_edge_literal | Symbolic_edge_literal;

Bit_edge_literal: Bit_literal Bit_literal;

based_edge_literal: Based_literal Based_literal;
Symbolic_edge_literal: '?~' | '?!' | '?-';
edge_value: '(' edge_literal ')';

identifier:
	Atomic_identifier index? // See Syntax 20, 6.13.3
	//| hierarchical_identifier
	| Escaped_identifier
	| Letter
	; // See Syntax 17, 6.13

Atomic_identifier:
	Non_escaped_identifier
	| Placeholder_identifier
	;

//hierarchical_identifier:
//	full_hierarchical_identifier
//	| partial_hierarchical_identifier;

Placeholder_identifier: '<' Non_escaped_identifier '>'; // See Syntax 19, 6.13.2
Non_escaped_identifier: Letter (Letter | Digit | '_' | '$' | '#')+;

//optional_indexed_identifier: Atomic_identifier index?;

//full_hierarchical_identifier:
//	alf_list += optional_indexed_identifier (
//		'.' alf_list += optional_indexed_identifier
//	)+
//	; // See Syntax 21, 6.13.4

//partial_hierarchical_identifier:
//	(
//		from_list += optional_indexed_identifier (
//			'.' from_list += optional_indexed_identifier
//		)* '..'
//	)+ (
//		until_list += optional_indexed_identifier (
//			'.' until_list += optional_indexed_identifier
//		)*
//	)?
//	; // See Syntax 22, 6.13.5

Escaped_identifier:
	'\\' (Escapable_character)+ ; // See Syntax 23, 6.13.6

Escapable_character: Letter | Digit | Special;

keyword_identifier:
	Letter ('_'? Letter)*; // See Syntax 24, 6.13.7

Quoted_string: '"' Character* '"'; // See Syntax 25, 6.14

vector_expression_macro:
	'#.' Non_escaped_identifier; // See Syntax 28, 6.17

all_purpose_item: 
	alias_declaration
	| constant_declaration
	| class_declaration
	| keyword_declaration
	| semantics_declaration
	| group_declaration
	| template_declaration
	| include_statement
	| associate_statement
	| annotation
	| annotation_container
	| arithmetic_model
	| arithmetic_model_container
	| template_instantiation
	; // See Syntax 30, 7.2

annotation:
	single_value_annotation
	| multi_value_annotation
	; // See Syntax 31, 7.3

single_value_annotation:
	identifier Assign alf_value SemiColon
	;

multi_value_annotation: identifier OpenSwirly alf_value+ CloseSwirly;

annotation_container:
	  alf_id = identifier OpenSwirly annotations += annotation+ CloseSwirly // See Syntax 32, 7.4
	| alf_id = identifier name = identifier OpenSwirly annotations += annotation+ CloseSwirly;

attribute:
	ATTRIBUTE OpenSwirly attributes += identifier+ CloseSwirly; // See Syntax 33, 7.5
alf_property:
	PROPERTY alf_id = identifier? OpenSwirly annotations += annotation+ CloseSwirly; // See Syntax 34, 7.6

alias_declaration:
	ALIAS (
		alf_id = identifier Assign original = identifier
		| macro = vector_expression_macro Assign '(' expression = vector_expression ')'
	) SemiColon; // See Syntax 35, 7.7

constant_declaration: CONSTANT alf_id = identifier Assign value = constant_value SemiColon; // See Syntax 36, 7.8

constant_value: Number | Based_literal;

keyword_declaration:
	KEYWORD alf_id = keyword_identifier Assign target = identifier (
		SemiColon
		| OpenSwirly annotations += annotation* CloseSwirly
	); // See Syntax 37, 7.9

semantics_declaration:
	SEMANTICS alf_id = identifier (
		Assign syntax_item = identifier SemiColon
		| (Assign syntax_item = identifier)? OpenSwirly semantics += semantics_item* CloseSwirly
	); // See Syntax 38, 7.10
semantics_item:
	annotation
	| valuetype = single_value_annotation
	| values = multi_value_annotation
	| referencetype = annotation
	| default_ = single_value_annotation
	| si_model = single_value_annotation;

class_declaration:
	CLASS alf_id = identifier (SemiColon | OpenSwirly body += class_item* CloseSwirly); // See Syntax 39, 7.12
class_item:
	all_purpose_item
	| geometric_model
	| geometric_transformation;

group_declaration:
	GROUP alf_id = identifier (
		OpenSwirly values += alf_value+ CloseSwirly
		| OpenSwirly left = alf_value Colon right = alf_value CloseSwirly
	); // See Syntax 40, 7.14

template_declaration: TEMPLATE alf_id = identifier OpenSwirly statements += alf_statement* CloseSwirly; // See Syntax 41, 7.15

// ------- See Syntax 42, 7.16
template_instantiation:
	static_template_instantiation
	| dynamic_template_instantiation
	;
static_template_instantiation:
	alf_id = identifier (Assign 'static')? (
		SemiColon
		| OpenSwirly values += alf_value* CloseSwirly
		| OpenSwirly annotations += annotation* CloseSwirly
	)
	;

dynamic_template_instantiation:
	alf_id = identifier Assign 'dynamic' OpenSwirly items += dynamic_template_instantiation_item* CloseSwirly
	;

dynamic_template_instantiation_item:
	annotation
	| arithmetic_model
	| arithmetic_assignment
	;

arithmetic_assignment:
	identifier Assign arithmetic_expression SemiColon
	;
// -------


include_statement:
	INCLUDE target = Quoted_string SemiColon; // See Syntax 43, 7.17

associate_statement:
	ASSOCIATE target = Quoted_string (
		SemiColon
		| OpenSwirly alf_format = single_value_annotation CloseSwirly
	); // See Syntax 44, 7.18

alf_revision: ALF_REVISION alf_value; // See Syntax 45, 7.19

library_specific_object:
	library
	| sublibrary
	| cell
	| primitive
	| wire
	| pin
	| pingroup
	| vector
	| node
	| layer
	| via
	| alf_rule
	| antenna
	| site
	| array
	| blockage
	| port
	| pattern
	| region
	; // See Syntax 46, 8.1

library:
	'LIBRARY' alf_id = identifier (
		SemiColon
		| OpenSwirly body += library_item* CloseSwirly
	)
	| library_template = template_instantiation; // See Syntax 47, 8.2

library_item: sublibrary | sublibrary_item;

sublibrary:
	'SUBLIBRARY' alf_id = identifier (
		body += sublibrary_item*
	)
	;

sublibrary_item:
	all_purpose_item
	| cell
	| primitive
	| wire
	| layer
	| via
	| alf_rule
	| antenna
	| array
	| site
	| region
	;

cell:
	CELL alf_id = identifier (SemiColon | OpenSwirly body += cell_item* CloseSwirly)
	| cell_template = template_instantiation
	; // See Syntax 48, 8.4

cell_item:
	all_purpose_item
	| pin
	| pingroup
	| primitive
	| function
	| non_scan_cell
	| test
	| vector
	| wire
	| blockage
	| artwork
	| pattern
	| region
	;

pin: // See Syntax 49, 8.6
	PIN Assign? identifier SemiColon
	| PIN alf_id = identifier (
		SemiColon
		| OpenSwirly scalar_pin_item* CloseSwirly
	)
	| PIN first = index alf_id = identifier (second = index)? (
		SemiColon
		| OpenSwirly vector_pin_item* CloseSwirly
	)
	| template_instantiation
	; 

scalar_pin_item: all_purpose_item | pattern | port;
vector_pin_item: all_purpose_item | alf_range;

pingroup:
	PINGROUP alf_id = identifier OpenSwirly multi_value_annotation all_purpose_item* CloseSwirly
	| PINGROUP vector_index = index alf_id = identifier OpenSwirly multi_value_annotation vector_pingroup_item* CloseSwirly
	| template_instantiation
	; // See Syntax 50, 8.7

vector_pingroup_item: all_purpose_item | alf_range;

primitive:
	'PRIMITIVE' alf_id = identifier (
		SemiColon
		| OpenSwirly body += primitive_item* CloseSwirly
	)
	| template_instantiation
	; // See Syntax 51, 8.9

primitive_item:
	all_purpose_item
	| pin
	| pingroup
	| function
	| test
	;

wire:
	'WIRE' alf_id = identifier (SemiColon | OpenSwirly body += wire_item* CloseSwirly)
	| template_instantiation
	; // See Syntax 52, 8.10

wire_item: all_purpose_item | node;

node:
	'NODE' alf_id = identifier (SemiColon | OpenSwirly body += node_item* CloseSwirly)
	| template_instantiation
	; // See Syntax 53, 8.12

node_item: all_purpose_item;

vector:
	'VECTOR' expr = control_expression (
		SemiColon
		| OpenSwirly body += vector_item+ CloseSwirly
	)
	| template_instantiation
	; // See Syntax 54, 8.14

vector_item:
	annotation
	| annotation_container
	| arithmetic_model
	| arithmetic_model_container
	| wire_instantiation
	;

layer:
	LAYER alf_id = identifier (SemiColon | OpenSwirly body += layer_item* CloseSwirly)
	| template_instantiation; // See Syntax 55, 8.16
layer_item: all_purpose_item;

via:
	VIA alf_id = identifier (SemiColon | OpenSwirly body += via_item* CloseSwirly)
	| template_instantiation; // See Syntax 56, 8.18
via_item: all_purpose_item | pattern | artwork;

alf_rule:
	RULE alf_id = identifier (SemiColon | OpenSwirly body += rule_item* CloseSwirly)
	| template_instantiation; // See Syntax 57, 8.20
rule_item:
	all_purpose_item
	| pattern
	| region
	| via_instantiation;

antenna:
	ANTENNA alf_id = identifier (
		SemiColon
		| OpenSwirly body += antenna_item* CloseSwirly
	)
	| template_instantiation; // See Syntax 58, 8.21
antenna_item: all_purpose_item | region;

blockage:
	BLOCKAGE alf_id = identifier (
		SemiColon
		| OpenSwirly body += blockage_item* CloseSwirly
	)
	| template_instantiation; // See Syntax 59, 8.22
blockage_item:
	all_purpose_item
	| pattern
	| region
	| alf_rule
	| via_instantiation;

port:
	'PORT' alf_id = identifier (SemiColon | OpenSwirly body += port_item* CloseSwirly)
	| template_instantiation; // See Syntax 60, 8.23
port_item:
	all_purpose_item
	| pattern
	| region
	| alf_rule
	| via_instantiation;

site:
	SITE alf_id = identifier (SemiColon | OpenSwirly body += site_item* CloseSwirly)
	| template_instantiation; // See Syntax 61, 8.25
site_item:
	all_purpose_item
	| width = arithmetic_model
	| height = arithmetic_model;

array:
	ARRAY alf_id = identifier (SemiColon | OpenSwirly body += array_item* CloseSwirly)
	| template_instantiation; // See Syntax 62, 8.27
array_item: all_purpose_item | geometric_transformation;

pattern:
	PATTERN alf_id = identifier (
		SemiColon
		| OpenSwirly body += pattern_item* CloseSwirly
	)
	| template_instantiation; // See Syntax 63, 8.29
pattern_item:
	all_purpose_item
	| geometric_model
	| geometric_transformation;

region:
	REGION alf_id = identifier (SemiColon | OpenSwirly body += region_item* CloseSwirly)
	| template_instantiation; // See Syntax 64, 8.31
region_item:
	all_purpose_item
	| geometric_model
	| geometric_transformation
	| boolean_ = single_value_annotation;
function:
	FUNCTION OpenSwirly body += function_item+ CloseSwirly
	| template_instantiation; // See Syntax 65, 9.1
function_item:
	all_purpose_item
	| behavior
	| structure
	| statetable;

test:
	TEST OpenSwirly body += test_item+ CloseSwirly
	| template_instantiation; // See Syntax 66, 9.2
test_item: all_purpose_item | behavior | statetable;

pin_value:
	pin_variable = identifier
	| Boolean_value
	; // See Syntax 67, 9.3.1

pin_assignment:
	pin_variable = identifier Assign value = pin_value SemiColon; // See Syntax 68, 9.3.2
behavior:
	BEHAVIOR OpenSwirly behavior_item+ CloseSwirly
	| template_instantiation; // See Syntax 69, 9.4
behavior_item:
	boolean_assignment
	| control_statement
	| primitive_instantiation
	| template_instantiation;
boolean_assignment:
	pin_variable = identifier Assign boolean_expression SemiColon;
control_statement:
	primary_control_statement alternative_control_statement*;
primary_control_statement:
	AtSign control_expression OpenSwirly boolean_assignment+ CloseSwirly;
alternative_control_statement:
	Colon control_expression OpenSwirly boolean_assignment+ CloseSwirly;
primitive_instantiation:
	identifier identifier? OpenSwirly pin_value+ CloseSwirly
	| identifier identifier? OpenSwirly boolean_assignment+ CloseSwirly;
structure:
	STRUCTURE OpenSwirly cell_instantiation+ CloseSwirly
	| template_instantiation; // See Syntax 70, 9.5

cell_reference_identifier: identifier;

cell_instantiation:
	cell_reference_identifier identifier SemiColon
	| cell_reference_identifier identifier OpenSwirly pin_value* CloseSwirly
	| cell_reference_identifier identifier OpenSwirly pin_assignment* CloseSwirly
	| template_instantiation
	;

cell_instance_pin_assignment: pin_variable = identifier Assign pin_value SemiColon;

statetable:
	STATETABLE alf_id = identifier? OpenSwirly tableheader = statetable_header rows += statetable_row+ CloseSwirly
	| template_instantiation;
	// See Syntax 71, 9.6

statetable_header: inputs += identifier+ Colon outputs += identifier+ SemiColon;
statetable_row: control_values += statetable_control_value+ Colon data_values += statetable_data_value+ SemiColon;

statetable_control_value:
	Boolean_value
	| '?'
	| '*'
	| edge_value
	;

statetable_data_value:
	Boolean_value
	| '(' ('!')? input_pin = identifier ')'
	| '(' ('~')? input_pin = identifier ')';

non_scan_cell:
	NON_SCAN_CELL Assign references += non_scan_cell_reference SemiColon
	| NON_SCAN_CELL OpenSwirly references += non_scan_cell_reference+ CloseSwirly
	| template_instantiation;
	// See Syntax 72, 9.7

non_scan_cell_reference:
	alf_id = identifier OpenSwirly scan_cell_pins += identifier CloseSwirly
	| alf_id = identifier OpenSwirly (
		non_scan_cell_pins += identifier Assign scan_cell_pins += identifier SemiColon
	)* CloseSwirly;

alf_range:
	RANGE OpenSwirly alf_from_index = alf_value Colon until_index = alf_value CloseSwirly; // See Syntax 73, 9.8

boolean_expression:
	'(' inner = boolean_expression ')'
	| val = Boolean_value
	| ref = identifier
	| unary = boolean_unary_operator right = boolean_expression
	| left = boolean_expression binary = boolean_binary_operator right = boolean_expression
	| condition = boolean_expression '?' then = boolean_expression Colon otherwise = boolean_expression
	; // See Syntax 74, 9.9

boolean_unary_operator:
	LogicNot
	| Not
	| And
	| NotAnd
	| Or
	| NotOr
	| Xor
	| NotXor;

boolean_binary_operator:
	And
	| LogicAnd
	| NotAnd
	| Or
	| LogicOr
	| NotOr
	| Xor
	| NotXor
	| Relational_operator
	| arithmetic_operator
	| Shift_operator
	;

vector_expression:
	'(' inner = vector_expression ')'
	| event = single_event
	| left = vector_expression op = vector_operator right = vector_expression
	| condition = boolean_expression '?' then = vector_expression Colon otherwise = vector_expression
	| boolean_expression Control_and vector_expression
	| vector_expression Control_and boolean_expression
	| vector_expression_macro
	; // See Syntax 75, 9.12

single_event: edge_literal boolean_expression;

vector_operator: Event_operator | Event_and | Event_or;
Event_and: And | LogicAnd;
Event_or: Or | LogicOr;
Control_and: And | LogicAnd;

control_expression:
	'(' vector_expression ')'
	| '(' boolean_expression ')';

wire_instantiation:
	wire_reference = identifier wire_instance = identifier (
		SemiColon
		| OpenSwirly values += pin_value* CloseSwirly
		| OpenSwirly assignments += pin_assignment* CloseSwirly
	)
	| template_instantiation; // See Syntax 76, 9.15
wire_instance_pin_assignment:
	wire_reference_pin = identifier Assign wire_instance = pin_value SemiColon;

geometric_model:
	Non_escaped_identifier alf_id = identifier? OpenSwirly body += geometric_model_item+ CloseSwirly
	| template_instantiation; // See Syntax 77, 9.16
geometric_model_item:
	point_to_point = single_value_annotation
	| coordinates;

coordinates: COORDINATES OpenSwirly points += point+ CloseSwirly;

point: x = Number y = Number;

geometric_transformation:
	shift
	| rotate
	| flip
	| repeat; // See Syntax 78, 9.18
shift: SHIFT OpenSwirly x = Number y = Number CloseSwirly;
rotate: ROTATE Assign Number SemiColon;
flip: FLIP Assign Number SemiColon;
repeat:
	REPEAT (Assign times += Unsigned_integer)* OpenSwirly transforms += geometric_transformation+ CloseSwirly;

artwork:
	ARTWORK (
		Assign alf_id = identifier SemiColon
		| Assign references += artwork_reference
		| OpenSwirly references += artwork_reference+ CloseSwirly
	)
	| template_instantiation; // See Syntax 79, 9.19

artwork_reference:
	alf_id = identifier OpenSwirly transforms += geometric_transformation* (
		cell_pins += identifier*
		| (
			artwork_pin += identifier Assign cell_pins += identifier SemiColon
		)*
	) CloseSwirly;
instance_identifier: identifier;
via_instantiation:
	alf_id = identifier instance = identifier (
		SemiColon
		| OpenSwirly transforms += geometric_transformation* CloseSwirly
	); // See Syntax 80, 9.20

arithmetic_expression:
	'(' inner = arithmetic_expression ')'
	| val = alf_value
	| condition = boolean_expression '?' then = arithmetic_expression Colon otherwise = arithmetic_expression
	| unary = unary_operator right = arithmetic_expression
	| left = arithmetic_expression binary = arithmetic_operator right = arithmetic_expression
	| marco = macro_arithmetic_operator '(' macro_args += arithmetic_expression ( ',' macro_args += arithmetic_expression )* ')'
	; // See Syntax 81, 10.1

Abs: 'abs';
Exp: 'exp';
Log: 'log';
Min: 'alf_min';
Max: 'alf_max';
macro_arithmetic_operator: Abs | Exp | Log | Min | Max;

arithmetic_model:
	trivial_arithmetic_model
	| partial_arithmetic_model
	| full_arithmetic_model
	//| template_instantiation
	; // See Syntax 82, 10.3

trivial_arithmetic_model: arithmetic_ref = identifier ( name = identifier )? Assign ( value = alf_value ) ( OpenSwirly qualifiers += model_qualifier+                                                  CloseSwirly )? ; // See Syntax 83, 10.3
partial_arithmetic_model: arithmetic_ref = identifier ( name = identifier )?                                OpenSwirly body += partial_arithmetic_model_item+                                          CloseSwirly    ; // See Syntax 84, 10.3
full_arithmetic_model:    arithmetic_ref = identifier ( name = identifier )?                                OpenSwirly qualifiers += model_qualifier* body = model_body qualifiers += model_qualifier* CloseSwirly;

partial_arithmetic_model_item:
	model_qualifier
	| table
	| trivial_alf_min_alf_max
	;


// See Syntax 85, 10.3
model_qualifier:
	annotation
	//| annotation_container
	| PIN Assign identifier SemiColon
	//| auxiliary_arithmetic_model
	| violation
	| alf_from_to
	;

auxiliary_arithmetic_model: identifier (Assign alf_value)? ( OpenSwirly auxiliary_qualifier* CloseSwirly |  SemiColon ); // See Syntax 95, 10.6

auxiliary_qualifier:
	annotation
	| annotation_container
	| pin
	| alf_from_to
	;

model_body:
	header_table_equation trivial_alf_min_alf_max?
	| alf_min_typ_alf_max
	| arithmetic_submodel+; // See Syntax 86, 10.3

inheritable_arithmetic_model_qualifier:
	annotation
	| annotation_container
	;

non_inheritable_arithmetic_model_qualifier:
	auxiliary_arithmetic_model
	| violation
	;

header_table_equation:
	header (table | equation); // See Syntax 88, 10.4

//header: HEADER OpenSwirly header_arithmetic_model+ CloseSwirly; // See Syntax 89, 10.4
header: HEADER OpenSwirly partial_arithmetic_model+ CloseSwirly; // See Syntax 89, 10.4

//header_arithmetic_model: ( arithmetic_ref = identifier ) ( name = identifier )? ( OpenSwirly body += header_arithmetic_model_item* CloseSwirly )?;

//header_arithmetic_model_item:
//	inheritable_arithmetic_model_qualifier
//	| table
//	| trivial_alf_min_alf_max
//	| arithmetic_submodel
//	| pin
//	;

equation:
	EQUATION OpenSwirly arithmetic_expression CloseSwirly
	| template_instantiation; // See Syntax 90, 10.4

table: 'TABLE' OpenSwirly ( ret += alf_value* ) CloseSwirly;
alf_min_typ_alf_max: alf_min_alf_max | alf_min? typ alf_max?; // See Syntax 92, 10.5
alf_min_alf_max: alf_min | alf_max | alf_min alf_max;
alf_min: trivial_alf_min | non_trivial_alf_min;
alf_max: trivial_alf_max | non_trivial_alf_max;
typ: trivial_typ | non_trivial_typ;
non_trivial_alf_min:
	MIN Assign val = alf_value OpenSwirly violations = violation CloseSwirly
	| MIN OpenSwirly violations = violation? table_equation = header_table_equation CloseSwirly;
// See Syntax 93, 10.5
non_trivial_alf_max:
	MAX Assign val = alf_value OpenSwirly violations = violation CloseSwirly
	| MAX OpenSwirly violations = violation? table_equation = header_table_equation CloseSwirly;
non_trivial_typ:
	TYP OpenSwirly table_equation = header_table_equation CloseSwirly;
trivial_alf_min_alf_max:
	trivial_alf_min // See Syntax 94, 10.5
	| trivial_alf_max
	| trivial_alf_min trivial_alf_max;
trivial_alf_min: MIN Assign val = alf_value SemiColon;
trivial_alf_max: MAX Assign val = alf_value SemiColon;
trivial_typ: TYP Assign val = alf_value SemiColon;

arithmetic_submodel:
	sumodel = identifier (
		Assign val = alf_value SemiColon
		| OpenSwirly violation? alf_min_alf_max CloseSwirly
		| OpenSwirly header_table_equation ( trivial_alf_min_alf_max)? CloseSwirly
		| OpenSwirly alf_min_typ_alf_max CloseSwirly
	)
	| template_instantiation; // See Syntax 96, 10.7

arithmetic_model_container:
	limit_arithmetic_model_container
	| early_late_arithmetic_model_container
	| container = identifier OpenSwirly arithmetic_model+ CloseSwirly; // See Syntax 97, 10.8.1

limit_arithmetic_model_container:
	LIMIT OpenSwirly limit_arithmetic_model+ CloseSwirly; // See Syntax 98, 10.8.2

limit_arithmetic_model:
	arithmetic_ref = identifier name = identifier? OpenSwirly qualifiers += model_qualifier* body = limit_arithmetic_model_body CloseSwirly;

limit_arithmetic_model_body:
	submodels += limit_arithmetic_submodel+
	| alf_min_alf_max;
limit_arithmetic_submodel:
	submodel = identifier OpenSwirly violation? alf_min_alf_max CloseSwirly;

early_late_arithmetic_model_container:
	early_arithmetic_model_container late_arithmetic_model_container?
	| late_arithmetic_model_container; // See Syntax 99, 10.8.3
early_arithmetic_model_container:
	EARLY OpenSwirly arithmetic_model+ CloseSwirly;
late_arithmetic_model_container:
	LATE OpenSwirly arithmetic_model+ CloseSwirly;

violation:
	VIOLATION OpenSwirly body += violation_item+ CloseSwirly
	| template_instantiation
	; // See Syntax 100, 10.10

violation_item:
	message_type = single_value_annotation
	| message = single_value_annotation
	| behavior;

// See Syntax 101, 10.12

alf_from_to_item:
	pin
	| single_value_annotation
	;

alf_from_to:
	alf_from
	|alf_to
	|alf_from alf_to
	|alf_to alf_from
	;

alf_from: FROM OpenSwirly body += alf_from_to_item+ CloseSwirly;
alf_to: TO OpenSwirly body += alf_from_to_item+ CloseSwirly;

start: alf_revision library EOF;
