require_relative '../test_helper'

module PlanOut
  class OperatorTest < Minitest::Test
    def setup

      @tester_unit = 4
      @tester_salt = 'test_salt'

      @a = Assignment.new(@tester_salt)
    end

    def test_execute
      operator = Operator.new({ foo: 'bar' })
      op_simple = OpSimple.new({ bar: 'qux' })
      assert_equal(@tester_salt, operator.execute(@a))
      assert_equal(-1, op_simple.execute(@a))
    end

    def test_uniform_choice
      @a['foo'] = UniformChoice.new(
        choices: ['a', 'b'],
        unit: @tester_unit
      )
      @a['bar'] = UniformChoice.new(
        choices: ['a', 'b'],
        unit: @tester_unit
      )
      @a['fiz'] = UniformChoice.new(
        choices: ['a', 'b'],
        unit: @tester_unit
      )
      @a['buz'] = UniformChoice.new(
        choices: ['a', 'b'],
        unit: @tester_unit
      )

      assert_equal('b', @a['foo'])
      assert_equal('a', @a['bar'])
      assert_equal('b', @a['fiz'])
      assert_equal('a', @a['buz'])
    end

    def test_weighted_choice
      weighted = WeightedChoice.new({
        choices: ["c1", "c2", "c1"],
        weights: [20, 40, 60],
        unit: @tester_unit
      })
      assert_equal("c2", weighted.execute(@a))
    end

    def test_salts
      i = 20
      a = Assignment.new('assign_salt_a')

      # assigning variables with different names and the same unit should yield
      # different randomizations, when salts are not explicitly specified
      a['x'] = RandomInteger.new(min: 0, max: 100000, unit: i)
      a['y'] = RandomInteger.new(min: 0, max: 100000, unit: i)
      assert(a['x'] != a['y'])

      # when salts are specified, they act the same way auto-salting does
      a['z'] = RandomInteger.new(min: 0, max: 100000, unit: i, salt: 'x')
      assert(a['x'] == a['z'])

      # when the Assignment-level salt is different, variables with the same
      # name (or salt) should generally be assigned to different values
      b = Assignment.new('assign_salt_b')
      b['x'] = RandomInteger.new(min: 0, max: 100000, unit: i)
      assert(a['x'] != b['x'])

      # when a full salt is specified, only the full salt is used to do
      # hashing
      a['f'] = RandomInteger.new(min: 0, max: 100000, unit: i, full_salt: 'fs')
      b['f'] = RandomInteger.new(min: 0, max: 100000, unit: i, full_salt: 'fs')
      assert(a['f'] == b['f'])

      a['f'] = RandomInteger.new(min: 0, max: 100000, unit: i, full_salt: 'fs2')
      b['f'] = RandomInteger.new(min: 0, max: 100000, unit: i, full_salt: 'fs2')
      assert(a['f'] == b['f'])
    end
  end
end
