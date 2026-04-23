@IsTest
@SuppressWarnings('AER.referenceVerified')
public class TextBlockLiteral_Test {
	// The opening ''' must be followed by a line terminator; that terminator
	// is NOT part of the string value. Content that follows, including
	// intermediate newlines, is preserved. A closing ''' placed on its own
	// line means the newline that precedes it IS part of the value.
	@IsTest
	static void strips_newline_after_opening_delimiter() {
		String actual = '''
hello''';
		System.Assert.areEqual('hello', actual, 'Opening newline must be stripped');
		System.Assert.areEqual(5, actual.length(), 'Value must be exactly 5 chars');
	}

	@IsTest
	static void preserves_newline_before_closing_delimiter_on_own_line() {
		String actual = '''
hello
''';
		System.Assert.areEqual('hello\n', actual, 'Trailing newline must be present');
		System.Assert.areEqual(6, actual.length(), 'Value must be exactly 6 chars');
	}

	@IsTest
	static void preserves_multiple_blank_lines() {
		String actual = '''
a

b''';
		// Expected: 'a' LF LF 'b'  => 4 chars
		System.Assert.areEqual('a\n\nb', actual, 'Blank lines between content must be preserved');
		System.Assert.areEqual(4, actual.length(), 'Value must be exactly 4 chars');
	}

	@IsTest
	static void preserves_embedded_double_quotes_verbatim() {
		String actual = '''
{"Name":"John Doe"}''';
		System.Assert.areEqual('{"Name":"John Doe"}', actual, 'Double quotes must be preserved verbatim');
		System.Assert.areEqual(19, actual.length(), 'Value must be exactly 19 chars');
	}

	@IsTest
	static void allows_bare_single_quote_without_escape() {
		String actual = '''
it's fine''';
		System.Assert.areEqual('it\'s fine', actual, 'Bare apostrophe must be preserved');
		System.Assert.areEqual(9, actual.length(), 'Value must be exactly 9 chars');
	}

	@IsTest
	static void allows_two_consecutive_single_quotes() {
		String actual = '''
a''b''';
		System.Assert.areEqual('a\'\'b', actual, 'Two consecutive apostrophes must be preserved');
		System.Assert.areEqual(4, actual.length(), 'Value must be exactly 4 chars');
	}

	@IsTest
	static void decodes_newline_escape() {
		String actual = '''
a\nb''';
		// Expected: 'a' LF 'b'  => 3 chars, with a real newline at index 1
		System.Assert.areEqual('a\nb', actual, 'The \\n escape must decode to a newline');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_tab_escape() {
		String actual = '''
a\tb''';
		System.Assert.areEqual('a\tb', actual, 'The \\t escape must decode to a tab');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_carriage_return_escape() {
		String actual = '''
a\rb''';
		System.Assert.areEqual('a\rb', actual, 'The \\r escape must decode to a CR');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_backslash_escape() {
		String actual = '''
a\\b''';
		// Expected: 'a' '\\' 'b' => 3 chars, with one backslash at index 1
		System.Assert.areEqual('a\\b', actual, 'The \\\\ escape must decode to one backslash');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_single_quote_escape() {
		String actual = '''
a\'b''';
		System.Assert.areEqual('a\'b', actual, 'The \\\' escape must decode to an apostrophe');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_double_quote_escape() {
		String actual = '''
a\"b''';
		System.Assert.areEqual('a"b', actual, 'The \\" escape must decode to a double quote');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void decodes_unicode_escape() {
		// A is 'A'
		String actual = '''
A''';
		System.Assert.areEqual('A', actual, 'Unicode escape \\u0041 must decode to A');
		System.Assert.areEqual(1, actual.length(), 'Value must be exactly 1 char');
	}

	@IsTest
	static void preserves_literal_tab_character() {
		// Embed an actual tab byte (0x09) between the 'a' and 'b'.
		String actual = '''
a	b''';
		System.Assert.areEqual('a\tb', actual, 'Literal tab byte must be preserved');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 chars');
	}

	@IsTest
	static void preserves_trailing_spaces_inside_content() {
		// Internal spaces (not trailing on a line) must be preserved.
		String actual = '''
a   b''';
		System.Assert.areEqual('a   b', actual, 'Internal whitespace must be preserved');
		System.Assert.areEqual(5, actual.length(), 'Value must be exactly 5 chars');
	}

	@IsTest
	static void preserves_multibyte_accented_character() {
		// café: c (1) + a (1) + f (1) + é (2 bytes in UTF-8, 1 Apex char)
		String actual = '''
café''';
		System.Assert.areEqual('café', actual, 'Accented character must be preserved');
		System.Assert.areEqual(4, actual.length(), 'Length must be 4 characters (not bytes)');
	}

	@IsTest
	static void preserves_multibyte_cjk_characters() {
		// 日本語 = 3 CJK chars (3 bytes each in UTF-8, 1 Apex char each)
		String actual = '''
日本語''';
		System.Assert.areEqual('日本語', actual, 'CJK characters must be preserved');
		System.Assert.areEqual(3, actual.length(), 'Length must be 3 characters (not 9 bytes)');
	}

	@IsTest
	static void preserves_emoji_supplementary_codepoint() {
		// 🚀 U+1F680 is a supplementary codepoint; in UTF-16 it is a surrogate pair
		// so Apex String.length() reports 2, consistent with Java.
		String actual = '''
🚀''';
		System.Assert.areEqual('🚀', actual, 'Emoji must be preserved');
		System.Assert.areEqual(2, actual.length(), 'Supplementary codepoint contributes 2 to length');
	}

	@IsTest
	static void preserves_json_payload_with_mixed_whitespace() {
		String actual = '''
{
	"Name": "John Doe",
	"Type": "New Customer"
}''';
		String expected = '{\n' + '\t"Name": "John Doe",\n' + '\t"Type": "New Customer"\n' +
			'}';
		System.Assert.areEqual(expected, actual, 'Multi-line JSON must preserve tabs and newlines exactly');
	}

	@IsTest
	static void length_matches_exact_byte_count_for_ascii_payload() {
		// Pin down the exact value so any drift in newline handling is caught.
		String actual = '''
ab
cd''';
		// Expected: a b LF c d => 5 chars
		System.Assert.areEqual(5, actual.length(), 'Expected 5 chars: a, b, LF, c, d');
		System.Assert.areEqual('a', actual.substring(0, 1), 'char 0 is a');
		System.Assert.areEqual('b', actual.substring(1, 2), 'char 1 is b');
		System.Assert.areEqual('\n', actual.substring(2, 3), 'char 2 is LF');
		System.Assert.areEqual('c', actual.substring(3, 4), 'char 3 is c');
		System.Assert.areEqual('d', actual.substring(4, 5), 'char 4 is d');
	}

	@IsTest
	static void empty_text_block_is_empty_string() {
		String actual = '''
''';
		System.Assert.areEqual('', actual, 'Text block containing only the opening-line terminator is empty');
		System.Assert.areEqual(0, actual.length(), 'Empty text block length must be 0');
	}

	// Only the single line terminator that immediately follows the opening
	// delimiter is stripped. Any additional blank lines that follow become
	// part of the string value as literal newline characters.
	@IsTest
	static void preserves_extra_blank_lines_after_opening_delimiter() {
		String actual = '''


hello''';
		// After stripping the first LF, the value is: LF LF 'hello' => 7 chars
		System.Assert.areEqual('\n\nhello', actual, 'Extra blank lines after opening must survive');
		System.Assert.areEqual(7, actual.length(), 'Value must be exactly 7 chars');
	}

	// Whitespace-only blank lines inserted between content lines are also
	// preserved verbatim; the blank-line LF sits between the two content
	// chars with no indentation added anywhere.
	@IsTest
	static void preserves_blank_lines_between_content_lines() {
		String actual = '''
a



b''';
		// a LF LF LF LF b => 6 chars
		System.Assert.areEqual('a\n\n\n\nb', actual, 'Three blank lines between content must be preserved');
		System.Assert.areEqual(6, actual.length(), 'Value must be exactly 6 chars');
	}

	// Leading whitespace common to every content line is "incidental"
	// and is stripped from the value, matching Java / Salesforce text
	// block semantics. With a single content line, its entire leading
	// whitespace run IS the common indent.
	@IsTest
	static void strips_incidental_leading_tab_on_sole_content_line() {
		String actual = '''
	indented''';
		System.Assert.areEqual('indented', actual, 'Incidental tab indent must be stripped');
		System.Assert.areEqual(8, actual.length(), 'Value must be exactly 8 chars');
	}

	// Leading spaces common to every content line are likewise stripped.
	@IsTest
	static void strips_incidental_leading_spaces_on_sole_content_line() {
		String actual = '''
    four-spaces''';
		System.Assert.areEqual('four-spaces', actual, 'Incidental leading spaces must be stripped');
		System.Assert.areEqual(11, actual.length(), 'Value must be exactly 11 chars');
	}

	// Trailing whitespace on a content line (i.e. before the LF that ends
	// the line) is stripped per Java text block rules.
	@IsTest
	static void strips_trailing_whitespace_before_line_terminator() {
		String actual = '''
hello   
world''';
		System.Assert.areEqual('hello\nworld', actual, 'Trailing spaces before LF must be stripped');
		System.Assert.areEqual(11, actual.length(), 'Value must be exactly 11 chars');
	}

	// A whitespace-only line immediately before the closing ''' becomes
	// empty after trailing-whitespace stripping; no indent contribution
	// survives into the value.
	@IsTest
	static void strips_whitespace_line_before_closing_delimiter() {
		String actual = '''
hello
   ''';
		System.Assert.areEqual('hello\n', actual, 'Whitespace-only line before closing delimiter must be stripped');
		System.Assert.areEqual(6, actual.length(), 'Value must be exactly 6 chars');
	}

	// Trailing whitespace on the same line as the closing ''' (i.e. not
	// followed by a LF) is stripped as well.
	@IsTest
	static void strips_trailing_whitespace_before_closing_delimiter_same_line() {
		String actual = '''
hello   ''';
		System.Assert.areEqual('hello', actual, 'Trailing whitespace before closing delimiter must be stripped');
		System.Assert.areEqual(5, actual.length(), 'Value must be exactly 5 chars');
	}

	// A block whose value is exactly a single LF: opening ''' LF, then
	// closing ''' on the next line. The single LF before the closing
	// delimiter is content, not the stripped opening terminator.
	@IsTest
	static void single_newline_value() {
		String actual = '''

''';
		System.Assert.areEqual('\n', actual, 'Value must be a single LF');
		System.Assert.areEqual(1, actual.length(), 'Length must be 1');
	}

	// Text blocks are accepted anywhere a regular string literal is valid
	// in Apex — including as the case value of a switch statement.
	@IsTest
	static void switch_on_string_matches_text_block_case() {
		String input = 'hello';
		String branch = '';
		switch on input {
			when '''
hello''' {
				branch = 'matched';
			}
			when else {
				branch = 'other';
			}
		}
		System.Assert.areEqual('matched', branch, 'Text block as switch case must match when the string value equals the block value');
	}

	// Multiple text blocks in a comma-separated case list are accepted.
	@IsTest
	static void switch_on_string_matches_one_of_multiple_text_block_cases() {
		String input = 'two';
		String branch = '';
		switch on input {
			when '''
one''', '''
two''', '''
three''' {
				branch = 'hit';
			}
			when else {
				branch = 'miss';
			}
		}
		System.Assert.areEqual('hit', branch, 'Comma-separated text block cases must all match');
	}

	// A multi-line text block case value should match the matching
	// multi-line input string — including the LF in the middle.
	@IsTest
	static void switch_on_string_matches_multi_line_text_block_case() {
		String input = 'a\nb';
		String branch = '';
		switch on input {
			when '''
a
b''' {
				branch = 'matched';
			}
			when else {
				branch = 'other';
			}
		}
		System.Assert.areEqual('matched', branch, 'Multi-line text block case must match the equivalent string');
	}

	// -------------------------------------------------------------------
	// Significant trailing line policy (Java text block re-indentation)
	//
	// The closing ''' on its own line is a "determining line" for the
	// common whitespace prefix: its column position controls how much
	// incidental indent is stripped from the content.
	// -------------------------------------------------------------------

	// Closing delimiter flush against the left margin contributes a
	// zero-width common prefix, opting OUT of whitespace stripping so
	// the full leading indent of every content line is preserved.
	@IsTest
	static void closing_delimiter_flush_left_opts_out_of_stripping() {
		String actual = '''
              <html>
                  <body>
              </html>
''';
		String expected = '              <html>\n' + '                  <body>\n' +
			'              </html>\n';
		System.Assert.areEqual(expected, actual, 'Flush-left closing delimiter must disable incidental whitespace stripping');
		System.Assert.areEqual(68, actual.length(), 'Flush-left variant must preserve all 68 source characters');
	}

	// Closing delimiter aligned with the content's leading column produces
	// a common prefix equal to that column, stripping exactly the
	// incidental indent and leaving the content flush-left.
	@IsTest
	static void closing_delimiter_aligned_with_content_strips_full_indent() {
		String actual = '''
              <html>
                  <body>
              </html>
              ''';
		String expected = '<html>\n' + '    <body>\n' + '</html>\n';
		System.Assert.areEqual(expected, actual, 'Closing delimiter aligned with content must strip the full common indent');
		System.Assert.areEqual(26, actual.length(), 'Aligned variant must be exactly 26 characters');
	}

	// Closing delimiter at a column shallower than the content's leading
	// column defines the common prefix, preserving the extra indent the
	// content has relative to the closing delimiter.
	@IsTest
	static void closing_delimiter_shallower_than_content_reduces_stripping() {
		String actual = '''
              <html>
                  <body>
              </html>
        ''';
		String expected = '      <html>\n' + '          <body>\n' + '      </html>\n';
		System.Assert.areEqual(expected, actual, 'Closing delimiter shallower than content must leave the delta-indent in the value');
		System.Assert.areEqual(44, actual.length(), 'Shallow-closing variant must be exactly 44 characters');
	}

	// Closing delimiter positioned to the right of the content has no
	// effect; the non-blank content lines still determine the prefix and
	// moving the closing marker rightward never INCREASES stripping.
	@IsTest
	static void closing_delimiter_deeper_than_content_has_no_effect() {
		String actual = '''
              <html>
                  <body>
              </html>
                  ''';
		String expected = '<html>\n' + '    <body>\n' + '</html>\n';
		System.Assert.areEqual(expected, actual, 'Closing delimiter right of content must not further reduce stripping');
		System.Assert.areEqual(26, actual.length(), 'Deep-closing variant must match the aligned variant: 26 characters');
	}

	// -------------------------------------------------------------------
	// Indent prefix calculation: blank and mixed lines
	// -------------------------------------------------------------------

	// A blank line (whitespace-only) MUST NOT contribute to the common
	// prefix calculation, even if it is shallower than every non-blank
	// content line. Otherwise a stray short blank line would defeat
	// incidental-whitespace stripping for the whole block.
	@IsTest
	static void blank_line_whitespace_does_not_affect_indent_prefix() {
		String actual = '''
    alpha

    beta
    ''';
		System.Assert.areEqual('alpha\n\nbeta\n', actual, 'Blank whitespace-only line must not reduce the common prefix');
		System.Assert.areEqual(12, actual.length(), 'Value must be exactly 12 characters');
	}

	// When content lines have different amounts of leading whitespace,
	// the MINIMUM leading whitespace defines the common prefix; the
	// extra indent on deeper lines survives into the value.
	@IsTest
	static void mixed_content_indent_strips_only_common_prefix() {
		String actual = '''
    outer
        inner
    outer
    ''';
		String expected = 'outer\n' + '    inner\n' + 'outer\n';
		System.Assert.areEqual(expected, actual, 'Only the min leading whitespace must be stripped; relative indent survives');
		System.Assert.areEqual(22, actual.length(), 'Value must be exactly 22 characters');
	}

	// When a content line has zero leading whitespace, the common prefix
	// is zero and no stripping occurs on any line.
	@IsTest
	static void zero_indent_line_disables_stripping() {
		String actual = '''
flush
    indented
''';
		String expected = 'flush\n' + '    indented\n';
		System.Assert.areEqual(expected, actual, 'A flush-left content line forces the common prefix to zero');
		System.Assert.areEqual(19, actual.length(), 'Value must be exactly 19 characters');
	}

	// -------------------------------------------------------------------
	// Compile-time processing order:
	// 1) line terminator normalization  2) incidental whitespace stripping
	// 3) escape sequence interpretation
	//
	// These tests pin down that order-of-operations: an escape sequence
	// embedded in the content must not influence earlier steps.
	// -------------------------------------------------------------------

	// A literal "\n" sequence in the source is just two characters at the
	// point of incidental whitespace stripping. It must NOT be treated as
	// a line terminator for the purposes of computing the indent prefix;
	// the source-level LF(s) are the ONLY line splits the algorithm sees.
	@IsTest
	static void n_escape_is_not_a_line_terminator_for_indent_calculation() {
		// Both source lines have a 4-space leading indent, so the common
		// prefix is 4. After stripping, the content becomes "a\nb\nc\n"
		// (with the first LF coming from the \n escape, the second from
		// the source LF between lines).
		String actual = '''
    a\nb
    c
    ''';
		System.Assert.areEqual('a\nb\nc\n', actual, '\\n escape must not split lines for indent computation');
		System.Assert.areEqual(6, actual.length(), 'Value must be exactly 6 characters');
	}

	// \r escape is interpreted only in step 3; before that, a literal CR
	// source character would have been normalized to LF. Verifying the
	// result contains CR confirms step 3 runs last.
	@IsTest
	static void carriage_return_escape_survives_line_terminator_normalization() {
		String actual = '''
a\rb''';
		System.Assert.areEqual('a\rb', actual, '\\r escape must produce a CR character in the final value');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 characters');
		System.Assert.areEqual('\r', actual.substring(1, 2), 'Character at index 1 must be CR');
	}

	// \t escape must not participate in incidental whitespace stripping.
	// Here every content line has a 4-space leading indent that is
	// stripped; the \t that follows survives as a literal TAB in the
	// value regardless of the leading-whitespace processing.
	@IsTest
	static void tab_escape_preserved_after_whitespace_stripping() {
		String actual = '''
    \tleading-tab
    plain
    ''';
		String expected = '\tleading-tab\n' + 'plain\n';
		System.Assert.areEqual(expected, actual, '\\t escape must decode to a TAB after incidental whitespace is stripped');
		System.Assert.areEqual(19, actual.length(), 'Value must be exactly 19 characters');
	}

	// -------------------------------------------------------------------
	// Concatenation: text blocks produce plain java.lang.String instances
	// and so compose with + exactly like string literals.
	// -------------------------------------------------------------------
	@IsTest
	static void concatenates_with_string_literal_prefix() {
		String actual = 'prefix-' + '''
content''';
		System.Assert.areEqual('prefix-content', actual, 'String literal + text block must concatenate');
		System.Assert.areEqual(14, actual.length(), 'Concatenated length must be 14');
	}

	@IsTest
	static void concatenates_with_string_literal_suffix() {
		String actual = '''
content''' + '-suffix';
		System.Assert.areEqual('content-suffix', actual, 'Text block + string literal must concatenate');
		System.Assert.areEqual(14, actual.length(), 'Concatenated length must be 14');
	}

	@IsTest
	static void concatenates_two_text_blocks() {
		String actual = '''
first
''' + '''
second''';
		System.Assert.areEqual('first\nsecond', actual, 'Two text blocks must concatenate verbatim');
		System.Assert.areEqual(12, actual.length(), 'Concatenated length must be 12');
	}

	// -------------------------------------------------------------------
	// Usage contexts: text blocks may appear anywhere a string literal
	// may appear.
	// -------------------------------------------------------------------
	@IsTest
	static void usable_as_method_argument() {
		String actual = identity('''
argument''');
		System.Assert.areEqual('argument', actual, 'Text block must be usable as a method argument');
	}

	@IsTest
	static void usable_as_ternary_expression_operand() {
		Boolean flag = true;
		String actual = flag ? '''
yes''' : '''
no''';
		System.Assert.areEqual('yes', actual, 'Text block must be usable as a ternary operand');
	}

	@IsTest
	static void usable_inside_list_literal() {
		List<String> values = new List<String>{ '''
one''', '''
two''' };
		System.Assert.areEqual(2, values.size(), 'List must contain two text block elements');
		System.Assert.areEqual('one', values[0], 'First element must equal "one"');
		System.Assert.areEqual('two', values[1], 'Second element must equal "two"');
	}

	@IsTest
	static void usable_inside_map_literal() {
		Map<String, String> values = new Map<String, String>{
			'''
k1''' => '''
v1''',
			'''
k2''' => '''
v2'''
		};
		System.Assert.areEqual(2, values.size(), 'Map must contain two text block entries');
		System.Assert.areEqual('v1', values.get('k1'), 'Entry k1 must resolve to v1');
		System.Assert.areEqual('v2', values.get('k2'), 'Entry k2 must resolve to v2');
	}

	@IsTest
	static void usable_as_field_initializer() {
		Holder h = new Holder();
		System.Assert.areEqual('field-init', h.text, 'Text block must be usable as a field initializer');
	}

	private class Holder {
		public String text = '''
field-init''';
	}

	// -------------------------------------------------------------------
	// Value equality / interchangeability with string literals.
	// -------------------------------------------------------------------
	@IsTest
	static void equals_string_literal_with_same_processed_content() {
		String viaBlock = '''
line 1
line 2
line 3
''';
		String viaLiteral = 'line 1\nline 2\nline 3\n';
		System.Assert.areEqual(viaLiteral, viaBlock, 'Text block and equivalent string literal must be equal by value');
		System.Assert.areEqual(viaLiteral.length(), viaBlock.length(), 'Lengths must match exactly');
	}

	@IsTest
	static void two_identical_text_blocks_are_equal_by_value() {
		String a = '''
shared
content''';
		String b = '''
shared
content''';
		System.Assert.areEqual(a, b, 'Two identical text blocks must produce equal string values');
		System.Assert.areEqual(a.hashCode(), b.hashCode(), 'Equal text blocks must have equal hash codes');
	}

	// -------------------------------------------------------------------
	// \s (space) escape sequence — JEP 378
	//
	// \s decodes to a single space (U+0020). Because escape decoding
	// happens AFTER incidental whitespace stripping, \s placed at the end
	// of a content line survives stripping and effectively "pins" trailing
	// spaces into the final value.
	// -------------------------------------------------------------------
	@IsTest
	static void decodes_slash_s_escape_to_space_in_regular_string() {
		String actual = 'a\sb';
		System.Assert.areEqual('a b', actual, '\\s in a single-quoted literal must decode to a single space');
		System.Assert.areEqual(3, actual.length(), 'Value must be exactly 3 characters');
	}

	@IsTest
	static void slash_s_acts_as_trailing_whitespace_fence_in_text_block() {
		// Three lines, each padded with \s so that after the incidental
		// whitespace strip every line is exactly six characters (five
		// visible characters plus the fenced space).
		String actual = '''
red  \s
green\s
blue \s
''';
		String expected = 'red   \ngreen \nblue  \n';
		System.Assert.areEqual(expected, actual, '\\s at end of line must survive trailing whitespace stripping');
		System.Assert.areEqual(21, actual.length(), 'Every line must be exactly 6 characters + LF = 21 total');
	}

	@IsTest
	static void slash_s_does_not_count_as_incidental_leading_whitespace() {
		// The only content line begins with \s which after escape
		// processing is a space character — but during whitespace
		// stripping, \s is two characters (\ and s). The leading column
		// on this line is thus a backslash, not whitespace, so nothing is
		// stripped and the escaped space survives into the value.
		String actual = '''
\sindented''';
		System.Assert.areEqual(' indented', actual, '\\s must be treated as two characters during whitespace stripping');
		System.Assert.areEqual(9, actual.length(), 'Value must be exactly 9 characters');
	}

	// -------------------------------------------------------------------
	// \<line-terminator> (line continuation) — JEP 378
	//
	// A backslash placed at the very end of a line inside a text block
	// suppresses the line's newline during escape processing. This lets
	// a long logical line be split across source lines without inserting
	// a real LF into the resulting string.
	// -------------------------------------------------------------------
	@IsTest
	static void line_continuation_joins_two_content_lines() {
		String actual = '''
Lorem ipsum dolor sit amet, consectetur adipiscing \
elit, sed do eiusmod tempor incididunt ut labore \
et dolore magna aliqua.''';
		String expected = 'Lorem ipsum dolor sit amet, consectetur adipiscing ' +
			'elit, sed do eiusmod tempor incididunt ut labore ' +
			'et dolore magna aliqua.';
		System.Assert.areEqual(expected, actual, 'Backslash at end of line must suppress the newline');
		System.Assert.isTrue(!actual.contains('\n'), 'Continued value must contain no newline characters');
	}

	@IsTest
	static void line_continuation_suppresses_trailing_newline_before_closing() {
		// The final content line ends with a backslash, so the newline
		// that would otherwise precede the closing delimiter is
		// suppressed — leaving the value without a trailing LF.
		String actual = '''
one\
two\
''';
		System.Assert.areEqual('onetwo', actual, 'All source LFs preceded by backslash must be suppressed');
		System.Assert.areEqual(6, actual.length(), 'Value must be exactly 6 characters');
	}

	@IsTest
	static void line_continuation_does_not_affect_indent_calculation() {
		// Both content lines have a 4-space indent which must still be
		// treated as incidental whitespace. The backslash sits where
		// trailing spaces would normally live and in no way influences
		// the line-split during whitespace stripping.
		String actual = '''
    left\
    right''';
		System.Assert.areEqual('leftright', actual, 'Incidental indent must be stripped; line continuation then joins the lines');
		System.Assert.areEqual(9, actual.length(), 'Value must be exactly 9 characters');
	}

	// -------------------------------------------------------------------
	// Escaped triple-quote sequences — JEP 378
	//
	// Three or more consecutive single quotes inside a text block would
	// mimic the closing delimiter. Escaping at least one quote with a
	// backslash lets the sequence appear in content without terminating
	// the block.
	// -------------------------------------------------------------------
	@IsTest
	static void escaped_triple_quote_does_not_close_text_block() {
		String actual = '''
before \''' after''';
		System.Assert.areEqual('before \'\'\' after', actual, '\\\'\'\' must decode to three literal single quotes in content');
		System.Assert.areEqual(16, actual.length(), 'Value must be exactly 16 characters');
	}

	@IsTest
	static void escaped_single_quote_before_closing_delimiter() {
		// A single quote immediately before the closing ''' would make a
		// sequence of four quotes that the lexer otherwise sees as a
		// malformed closing. Escaping the quote resolves the ambiguity
		// and the value ends with a literal apostrophe.
		String actual = '''
ends with a quote: \'''';
		System.Assert.areEqual('ends with a quote: \'', actual, 'Escaped quote before closing delimiter must appear in value');
		System.Assert.areEqual(20, actual.length(), 'Value must be exactly 20 characters');
	}

	@IsTest
	static void escaped_quote_inside_content_otherwise_ambiguous() {
		// Two literal quotes followed by an escaped quote, then two more
		// literal quotes: the lexer must not split the triple off.
		String actual = '''
a''\'''b''';
		System.Assert.areEqual('a\'\'\'\'\'b', actual, 'Escaped quote must let a five-quote run appear in content');
		System.Assert.areEqual(7, actual.length(), 'Value must be exactly 7 characters');
	}

	// Helper that simply returns its argument — used to verify text
	// blocks can be passed as method arguments without transformation.
	private static String identity(String value) {
		return value;
	}
}
