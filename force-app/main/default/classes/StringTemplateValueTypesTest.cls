@IsTest
@SuppressWarnings('AER.referenceVerified')
private class StringTemplateValueTypesTest {
	// Helper class used to validate how user-defined class instances render
	// when interpolated by String.template(). A toString() override is provided
	// so we can assert a deterministic string form.
	public class Person {
		public String name;
		public Integer age;
		public Person(String name, Integer age) {
			this.name = name;
			this.age = age;
		}
		public override String toString() {
			return 'Person(' + name + ', ' + age + ')';
		}
	}

	// Second helper without a toString override, so we can see the default
	// class rendering used by String.template().
	public class Point {
		public Integer x;
		public Integer y;
		public Point(Integer x, Integer y) {
			this.x = x;
			this.y = y;
		}
	}

	// Helper with an SObject field, to validate how a custom class that
	// contains an SObject renders when interpolated.
	public class Owner {
		public String label;
		public Account account;
		public Owner(String label, Account account) {
			this.label = label;
			this.account = account;
		}
	}

	// -- Primitive types --------------------------------------------------
	@IsTest
	static void renders_string_primitive_as_itself() {
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => 'hello' });
		System.Assert.areEqual('v=hello', actual, 'String value must render unchanged');
	}

	@IsTest
	static void renders_integer_primitive_as_decimal_string() {
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => 42 });
		System.Assert.areEqual('v=42', actual, 'Integer must render as its decimal digits');
	}

	@IsTest
	static void renders_long_primitive_as_decimal_string() {
		Long big = 9999999999L;
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => big });
		System.Assert.areEqual('v=9999999999', actual, 'Long must render as its decimal digits without suffix');
	}

	@IsTest
	static void renders_double_primitive_with_decimal_point() {
		Double d = 3.14;
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => d });
		System.Assert.areEqual('v=3.14', actual, 'Double must render in standard decimal form');
	}

	@IsTest
	static void renders_double_whole_number_with_trailing_zero() {
		Double d = 2.0;
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => d });
		System.Assert.areEqual('v=2.0', actual, 'Double whole numbers render with trailing .0');
	}

	@IsTest
	static void renders_decimal_primitive_preserving_scale() {
		Decimal dec = 3.140;
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => dec });
		System.Assert.areEqual('v=3.140', actual, 'Decimal must preserve trailing zeros from its literal scale');
	}

	@IsTest
	static void renders_boolean_true_as_lowercase_true() {
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => true });
		System.Assert.areEqual('v=true', actual, 'Boolean true must render as "true"');
	}

	@IsTest
	static void renders_boolean_false_as_lowercase_false() {
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => false });
		System.Assert.areEqual('v=false', actual, 'Boolean false must render as "false"');
	}

	@IsTest
	static void renders_date_with_zero_time_suffix() {
		Date d = Date.newInstance(2024, 1, 15);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => d });
		System.Assert.areEqual('v=2024-01-15 00:00:00', actual, 'Date must render as yyyy-MM-dd 00:00:00');
	}

	@IsTest
	static void renders_datetime_in_gmt() {
		Datetime dt = Datetime.newInstanceGmt(2024, 1, 15, 12, 30, 45);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => dt });
		System.Assert.areEqual('v=2024-01-15 12:30:45', actual, 'Datetime must render in GMT as yyyy-MM-dd HH:mm:ss');
	}

	@IsTest
	static void renders_time_with_milliseconds_and_z_suffix() {
		Time t = Time.newInstance(12, 30, 45, 0);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => t });
		System.Assert.areEqual('v=12:30:45.000Z', actual, 'Time must render as HH:mm:ss.SSSZ');
	}

	@IsTest
	static void renders_id_as_its_canonical_string() {
		Account account = new Account(Name = 'Acme');
		insert account;
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => account.Id });
		System.Assert.areEqual('v=' + account.Id, actual, 'Id must render as its canonical string form');
	}

	@IsTest
	static void renders_blob_as_blob_placeholder() {
		// Note: aer's convertToString renders Blob values as "Blob[<length>]".
		// This test is here to compare against sfapex, which may render differently.
		Blob b = Blob.valueOf('abc');
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => b });
		System.Assert.areEqual('v=Blob[3]', actual, 'Blob renders using aer debug-style notation');
	}

	// -- Collection types -------------------------------------------------
	@IsTest
	static void renders_empty_list_as_parenthesized_form() {
		List<String> items = new List<String>();
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		System.Assert.areEqual('v=()', actual, 'Empty List renders as ()');
	}

	@IsTest
	static void renders_string_list_comma_separated_in_parens() {
		List<String> items = new List<String>{ 'a', 'b', 'c' };
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		System.Assert.areEqual('v=(a, b, c)', actual, 'List<String> renders as (a, b, c)');
	}

	@IsTest
	static void renders_integer_list_comma_separated_in_parens() {
		List<Integer> items = new List<Integer>{ 1, 2, 3 };
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		System.Assert.areEqual('v=(1, 2, 3)', actual, 'List<Integer> renders as (1, 2, 3)');
	}

	@IsTest
	static void renders_empty_set_as_empty_braces() {
		Set<String> items = new Set<String>();
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		System.Assert.areEqual('v={}', actual, 'Empty Set renders as {}');
	}

	@IsTest
	static void renders_string_set_comma_separated_in_braces() {
		Set<String> items = new Set<String>{ 'a', 'b' };
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		// Set insertion order is preserved in Apex LinkedHashSet-style implementations.
		System.Assert.areEqual('v={a, b}', actual, 'Set<String> renders with insertion-order elements in braces');
	}

	@IsTest
	static void renders_map_as_brace_delimited_key_equals_value() {
		Map<String, String> m = new Map<String, String>{
			'k1' => 'v1',
			'k2' => 'v2'
		};
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => m });
		// aer renders maps with alphabetically sorted keys.
		System.Assert.areEqual('v={k1=v1, k2=v2}', actual, 'Map renders as {k=v, k=v} with sorted keys');
	}

	@IsTest
	static void renders_nested_list_within_list() {
		List<Object> items = new List<Object>{ new List<String>{ 'a', 'b' }, new List<String>{ 'c' } };
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => items });
		System.Assert.areEqual('v=((a, b), (c))', actual, 'Nested List renders with nested parenthesized form');
	}

	// -- Class instances --------------------------------------------------
	@IsTest
	static void renders_custom_class_without_tostring_using_default_form() {
		Point p = new Point(3, 7);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => p });
		System.Assert.areEqual('v=Point:[x=3, y=7]', actual, 'Custom class without toString renders as ClassName:[field=value, ...] in declared order');
	}

	@IsTest
	static void renders_custom_class_with_tostring_override() {
		Person p = new Person('Ada', 30);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => p });
		System.Assert.areEqual('v=Person(Ada, 30)', actual, 'Custom class toString() override must be honored');
	}

	@IsTest
	static void renders_custom_class_containing_sobject_field() {
		// A user-defined class that has an SObject-typed field. The nested
		// SObject is rendered inline using its own SObject form, and the
		// outer class renders fields alphabetically (matching sfapex).
		Account a = new Account(Name = 'Acme', AccountNumber = 'A-100');
		Owner o = new Owner('primary', a);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => o });
		System.Assert.areEqual('v=Owner:[account=Account:{Name=Acme, AccountNumber=A-100}, label=primary]',
			actual,
			'Custom class with an SObject field must expand the nested SObject inline and emit outer fields alphabetically');
	}

	@IsTest
	static void renders_custom_class_containing_queried_sobject_field() {
		// Populate an Account, its parent, and a child Contact, then read
		// them back with a SOQL query that pulls the parent relationship
		// and a child subquery. The Owner wrapper embeds that queried
		// record. This validates how template() renders an SObject that
		// carries parent/child relationship payloads.
		Account parent = new Account(Name = 'Parent Inc');
		insert parent;
		Account child = new Account(Name = 'Child Inc', ParentId = parent.Id);
		insert child;
		Contact c = new Contact(
			FirstName = 'Ada',
			LastName = 'Lovelace',
			AccountId = child.Id
		);
		insert c;

		Account queried = [
			SELECT
				Id,
				Name,
				Parent.Name,
				(SELECT
					Id,
					Name
				FROM
					Contacts)
			FROM
				Account
			WHERE
				Id = :child.Id
			LIMIT 1
		];
		Owner o = new Owner('primary', queried);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => o });
		// sfapex omits relationship payloads from the default SObject
		// stringification — the Parent sub-record (`Parent.Name`) and the
		// Contacts subquery list do not appear. Only the scalar and
		// lookup-Id fields (Id, Name, ParentId) are emitted, in SELECT order.
		String expected = 'v=Owner:[account=Account:{Id=' + queried.Id +
			', Name=Child Inc, ParentId=' +
			queried.ParentId +
			'}, label=primary]';
		System.Assert.areEqual(expected,
			actual,
			'Queried SObject stringification must include scalar/lookup fields in SELECT order and omit relationship payloads (parent sub-record, Contacts subquery)');
	}

	@IsTest
	static void renders_stdlib_exception_instance() {
		// Standard library class (DmlException) that has its own toString/message.
		Exception ex;
		try {
			throw new DmlException('boom');
		} catch (Exception e) {
			ex = e;
		}
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => ex });
		// The exact form is stdlib-defined; this assertion documents aer behavior
		// so any sfapex difference is visible.
		System.Assert.isTrue(actual.startsWith('v=System.DmlException'), 'Stdlib Exception must render starting with System.DmlException, got: ' +
			actual);
		System.Assert.isTrue(actual.contains('boom'), 'Stdlib Exception rendering must contain the message, got: ' +
			actual);
	}

	// -- SObjects ---------------------------------------------------------
	@IsTest
	static void renders_sobject_with_single_field() {
		Account a = new Account(Name = 'Acme');
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => a });
		System.Assert.areEqual('v=Account:{Name=Acme}', actual, 'SObject with single field renders as TypeName:{Field=value}');
	}

	@IsTest
	static void renders_sobject_with_multiple_fields_in_declared_order() {
		Account a = new Account(Name = 'Acme', AccountNumber = 'A-100');
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => a });
		System.Assert.areEqual('v=Account:{Name=Acme, AccountNumber=A-100}', actual, 'SObject fields render in the order they were set on the record');
	}

	@IsTest
	static void renders_sobject_with_six_fields_in_declared_order() {
		// Fields are set in an order that is neither alphabetical nor reverse
		// alphabetical, so any ordering other than declared (setter) order
		// will produce a distinct assertion message.
		Account a = new Account(
			Website = 'https://example.com',
			Name = 'Acme',
			Industry = 'Technology',
			AccountNumber = 'A-100',
			Phone = '555-0100',
			Description = 'An account'
		);
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => a });
		String expected = 'v=Account:{Website=https://example.com, Name=Acme, Industry=Technology, AccountNumber=A-100, Phone=555-0100, Description=An account}';
		System.Assert.areEqual(expected, actual, 'SObject fields render in the order they were set on the record');
	}

	@IsTest
	static void renders_empty_sobject_as_type_with_empty_braces() {
		Account a = new Account();
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => a });
		System.Assert.areEqual('v=Account:{}', actual, 'SObject with no populated fields renders as TypeName:{}');
	}

	// -- Null ------------------------------------------------------------
	@IsTest
	static void renders_explicit_null_value_as_literal_null_word() {
		String actual = 'v=${v}'.template(new Map<String, Object>{ 'v' => null });
		System.Assert.areEqual('v=null', actual, 'Explicit null binding renders as the literal word "null"');
	}
}
