@IsTest
@SuppressWarnings('AER.referenceVerified')
private class StringTemplateTest {
	@IsTest
	static void interpolates_single_variable_in_regular_string() {
		String actual = 'Hello, ${name}!'.template(new Map<String, Object>{ 'name' => 'World' });
		System.Assert.areEqual('Hello, World!', actual, 'Single variable must be interpolated inline');
	}

	@IsTest
	static void interpolates_multiple_variables_in_regular_string() {
		String template = '${greeting}, ${name}!';
		String actual = template.template(new Map<String, Object>{
			'greeting' => 'Hi',
			'name' => 'Ada'
		});
		System.Assert.areEqual('Hi, Ada!', actual, 'All referenced variables must be interpolated');
	}

	@IsTest
	static void interpolates_same_variable_multiple_times() {
		String actual = '${x}-${x}-${x}'.template(new Map<String, Object>{ 'x' => 'a' });
		System.Assert.areEqual('a-a-a', actual, 'Repeated variables must each be substituted');
	}

	@IsTest
	static void interpolates_integer_value_as_string() {
		String actual = 'count=${n}'.template(new Map<String, Object>{ 'n' => 42 });
		System.Assert.areEqual('count=42', actual, 'Integer value must be rendered as its string form');
	}

	@IsTest
	static void interpolates_null_value_as_literal_null() {
		String actual = 'value=${v}'.template(new Map<String, Object>{ 'v' => null });
		System.Assert.areEqual('value=null', actual, 'Null binding must render as the string "null"');
	}

	@IsTest
	static void returns_original_when_no_placeholders_present() {
		String actual = 'no placeholders here'.template(new Map<String, Object>{ 'x' => 'y' });
		System.Assert.areEqual('no placeholders here', actual, 'Strings without ${} must pass through unchanged');
	}

	@IsTest
	static void interpolates_across_multi_line_text_block() {
		String template = '''
{
	"Account": "${accountName}",
	"Count": "${count}"
}''';
		String actual = template.template(new Map<String, Object>{
			'accountName' => 'My Account',
			'count' => 3
		});
		String expected = '{\n' + '\t"Account": "My Account",\n' + '\t"Count": "3"\n' + '}';
		System.Assert.areEqual(expected, actual, 'Multi-line text block must interpolate placeholders and preserve other content');
	}

	@IsTest
	static void throws_string_exception_on_case_mismatch_placeholder() {
		// Key in map is 'accountName'; placeholder uses 'AccountName' (different case).
		// Placeholder lookup is case-sensitive, and sfapex throws
		// System.StringException when the key is not present in the map.
		Exception ex;
		try {
			'name=${AccountName}'.template(new Map<String, Object>{ 'accountName' => 'Acme' });
		} catch (Exception e) {
			ex = e;
		}
		System.Assert.isInstanceOfType(ex, StringException.class, 'Case-mismatch placeholder must raise StringException');
		System.Assert.areEqual('No value found for key AccountName', ex.getMessage(), 'Exception message must include the missing key');
	}

	@IsTest
	static void uses_placeholder_name_verbatim_as_map_key() {
		// The content between ${ and } is used as the map key byte-for-byte:
		// no trimming, no case folding, no whitespace normalization. A map key
		// that matches the surrounding-space name exactly is found.
		String actual = 'name=${ accountName }'.template(new Map<String, Object>{ ' accountName ' => 'Acme' });
		System.Assert.areEqual('name=Acme', actual, 'Placeholder name is used verbatim (including any whitespace) as the map key');
	}

	@IsTest
	static void throws_string_exception_on_missing_key() {
		// A placeholder whose name is not a key in the bindings map must raise
		// System.StringException: "No value found for key <name>".
		Exception ex;
		try {
			'hello ${missing}!'.template(new Map<String, Object>{ 'other' => 'value' });
		} catch (Exception e) {
			ex = e;
		}
		System.Assert.isInstanceOfType(ex, StringException.class, 'Missing placeholder must raise StringException');
		System.Assert.areEqual('No value found for key missing', ex.getMessage(), 'Exception message must name the missing key');
	}

	@IsTest
	static void ignores_extra_entries_in_bindings_map() {
		// The bindings map contains entries that the template does not reference.
		String actual = 'hi ${name}'.template(new Map<String, Object>{
			'name' => 'Ada',
			'unused_1' => 'one',
			'unused_2' => 42
		});
		System.Assert.areEqual('hi Ada', actual, 'Extra bindings must not affect the result');
	}

	@IsTest
	static void preserves_dollar_sign_without_brace() {
		// A bare '$' not followed by '{' is preserved.
		String actual = 'price: $5 for ${qty}'.template(new Map<String, Object>{ 'qty' => 3 });
		System.Assert.areEqual('price: $5 for 3', actual, 'A dollar sign not followed by { must be preserved literally');
	}

	// -- Placeholder name whitespace probes ---------------------------------
	// sfapex uses the entire content between ${ and } as the map key,
	// byte-for-byte: no trimming, no collapsing, no normalization. These
	// tests pin down that behavior from multiple angles.
	@IsTest
	static void leading_space_in_placeholder_requires_matching_leading_space_in_key() {
		String actual = '${ leadingSpace}'.template(new Map<String, Object>{ ' leadingSpace' => 'value' });
		System.Assert.areEqual('value', actual, 'Leading space inside ${} is part of the key name — matching map key must also have that leading space');
	}

	@IsTest
	static void trailing_space_in_placeholder_requires_matching_trailing_space_in_key() {
		String actual = '${trailingSpace }'.template(new Map<String, Object>{ 'trailingSpace ' => 'value' });
		System.Assert.areEqual('value', actual, 'Trailing space inside ${} is part of the key name — matching map key must also have that trailing space');
	}

	@IsTest
	static void preserves_single_internal_space_in_placeholder_name() {
		String actual = '${inline space}'.template(new Map<String, Object>{ 'inline space' => 'value' });
		System.Assert.areEqual('value', actual, 'Internal whitespace inside ${} must be preserved for key lookup');
	}

	@IsTest
	static void preserves_runs_of_internal_whitespace_verbatim() {
		String actual = '${  some    arbitrary space}'.template(new Map<String, Object>{ '  some    arbitrary space' => 'value' });
		System.Assert.areEqual('value', actual, 'Runs of internal whitespace must be preserved verbatim for key lookup');
	}

	@IsTest
	static void placeholder_with_leading_space_raises_when_key_has_no_leading_space() {
		// Because sfapex does not trim, ${ leadingSpace} looks up the key
		// ' leadingSpace' (with the leading space). A map that has only
		// 'leadingSpace' does not contain that key.
		Exception ex;
		try {
			'${ leadingSpace}'.template(new Map<String, Object>{ 'leadingSpace' => 'value' });
		} catch (Exception e) {
			ex = e;
		}
		System.Assert.isInstanceOfType(ex, StringException.class, 'Leading whitespace must be part of the lookup key, so a map without that key must throw');
		System.Assert.areEqual('No value found for key  leadingSpace', ex.getMessage(), 'Exception message must include the full placeholder name including the leading space');
	}

	@IsTest
	static void placeholder_with_internal_whitespace_raises_when_key_has_no_whitespace() {
		// If sfapex collapsed or stripped internal whitespace this would match
		// 'inlinespace'. Because it does not, the lookup fails.
		Exception ex;
		try {
			'${inline space}'.template(new Map<String, Object>{ 'inlinespace' => 'value' });
		} catch (Exception e) {
			ex = e;
		}
		System.Assert.isInstanceOfType(ex, StringException.class, 'Internal whitespace must not be stripped or collapsed');
		System.Assert.areEqual('No value found for key inline space', ex.getMessage(), 'Exception message must include the internal whitespace verbatim');
	}

	// -- Multi-byte variable names ------------------------------------------
	// These tests probe whether the placeholder name parser operates on
	// bytes or on Unicode code points. UTF-8 accented letters, CJK
	// ideographs, and supplementary-plane emoji are all tested.
	@IsTest
	static void matches_placeholder_with_accented_latin_name() {
		String actual = 'greet=${café}'.template(new Map<String, Object>{ 'café' => 'welcome' });
		System.Assert.areEqual('greet=welcome', actual, 'Placeholder names containing accented Latin characters must match a map key with the same characters');
	}

	@IsTest
	static void matches_placeholder_with_cjk_name() {
		String actual = 'lang=${日本語}'.template(new Map<String, Object>{ '日本語' => 'Japanese' });
		System.Assert.areEqual('lang=Japanese', actual, 'Placeholder names containing CJK ideographs must match a map key with the same characters');
	}

	@IsTest
	static void matches_placeholder_with_supplementary_plane_emoji_name() {
		// 🚀 is outside the BMP — encoded as a UTF-16 surrogate pair in Apex
		// and a 4-byte sequence in UTF-8. The parser must handle it in both.
		String actual = 'go=${🚀}'.template(new Map<String, Object>{ '🚀' => 'launch' });
		System.Assert.areEqual('go=launch', actual, 'Placeholder names containing supplementary-plane emoji must match a map key with the same character');
	}

	@IsTest
	static void matches_placeholder_with_mixed_unicode_name() {
		String actual = 'val=${café_日本_🚀}'.template(new Map<String, Object>{ 'café_日本_🚀' => 'mixed' });
		System.Assert.areEqual('val=mixed', actual, 'Placeholder names combining multiple multi-byte scripts must match a map key with the same characters');
	}

	@IsTest
	static void placeholder_name_lookup_preserves_surrounding_whitespace_and_multi_byte_bytes() {
		// Confirms that the verbatim-key lookup handles UTF-8 bytes adjacent
		// to whitespace without corrupting the multi-byte sequence. The map
		// key must include the same surrounding whitespace as the placeholder.
		String actual = 'val=${  café  }'.template(new Map<String, Object>{ '  café  ' => 'welcome' });
		System.Assert.areEqual('val=welcome', actual, 'Lookup key must be the verbatim placeholder name, including leading/trailing whitespace around a multi-byte body');
	}
}
