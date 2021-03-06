require(File.expand_path(File.dirname(__FILE__) + '/helper'))

class TestRubyHazePersistedClassMethods < Test::Unit::TestCase

  def test_right_store
    store = Foo.map
    assert_equal store.class.name, "RubyHaze::Map"
    assert_equal store.name, "RubyHaze::Persisted Foo"
    assert_equal store.name, RubyHaze::Map.new("RubyHaze::Persisted Foo").name
  end

  def test_right_fields
    assert_equal Foo.attributes, [[:uid, :string, {}], [:name, :string, {}], [:age, :int, {}]]
    assert_equal Foo.attribute_names, [:uid, :name, :age]
    assert_equal Foo.attribute_types, [:string, :string, :int]
    assert_equal Foo.attribute_options, [{}, {}, {}]

    assert_equal Sub::Foo.attributes, [[:uid, :string, {}], [:name, :string, {}]]
    assert_equal Sub::Foo.attribute_names, [:uid, :name]
    assert_equal Sub::Foo.attribute_types, [:string, :string]
    assert_equal Sub::Foo.attribute_options, [{}, {}]
  end

  def test_right_shadow_class
    assert_equal Foo.map_java_class.name, "Java::OrgRubyhazePersistedShadowClasses::Foo"
    assert_equal Sub::Foo.map_java_class.name, "Java::OrgRubyhazePersistedShadowClassesSub::Foo"
  end

end

class TestRubyHazePersistedStorage < Test::Unit::TestCase

  def test_store_reload_objects
    Foo.map.clear
    assert_equal Foo.map.size, 0
    @a = Foo.create :name => "Leonardo", :age => 65
    assert_equal Foo.map.size, 1
    @b = Foo.create :name => "Michelangelo", :age => 45
    assert_equal Foo.map.size, 2
    @b.age = 47
    @b.reload
    assert_equal Foo.map.size, 2
    assert_equal @b.age, 45
    Foo.map.clear
    assert_equal Foo.map.size, 0
  end

  def test_find_through_predicates
    Foo.map.clear
    @a = Foo.create :name => "Leonardo", :age => 65
    @b = Foo.create :name => "Michelangelo", :age => 45
    @c = Foo.create :name => "Raffaello", :age => 32

    res = Foo.find 'age < 40'
    assert_equal res.size, 1
    assert_equal res.first, @c
    assert_equal res.first.name, @c.name

    res = Foo.find 'age BETWEEN 40 AND 50'
    assert_equal res.size, 1
    assert_equal res.first, @b
    assert_equal res.first.name, @b.name

    res = Foo.find "name LIKE 'Leo%'"
    assert_equal res.size, 1
    assert_equal res.first, @a
    assert_equal res.first.name, @a.name

#    # Throws an internal exception
#    res = Foo.find "age IN (32, 65)"
#    assert_equal res.size, 2
#    names = res.map{|x| x.name }.sort
#    assert_equal names.first, @a.name
#    assert_equal names.last, @b.name

    res = Foo.find "age < 60 AND name LIKE '%ae%'"
    assert_equal res.size, 1
    assert_equal res.first, @c
    assert_equal res.first.name, @c.name
  end

end
