require_relative '../test_helper'
require_relative '../examples/banner_namespace'

module PlanOut
  class NamespaceTest < Minitest::Test
    def setup
      nil
    end

    def base_namespace(userid)
      base_namespace = BannerNamespaceBase.new(:userid => userid)

      assert_equal(BannerDefault, base_namespace.default_experiment_class)
      assert_equal(base_namespace.num_segments, base_namespace.available_segments.length)

      base_namespace
    end

    def zero_allocated_namespace(userid)
      zero_allocated_namespace = base_namespace(userid)

      assert_equal(0, zero_allocated_namespace.segment_allocations.length)
      assert_equal(100, zero_allocated_namespace.available_segments.length)

      zero_allocated_namespace
    end

    def test_zero_allocated_namespace
      assert_equal('Banner Text 0', zero_allocated_namespace(5).get('banner_text'))
    end

    def partial_allocated_namespace(userid)
      partial_allocated_namespace = base_namespace(userid)
      partial_allocated_namespace.add_experiment('V1 small audience', V1, 20)

      assert_equal(20, partial_allocated_namespace.segment_allocations.length)
      assert_equal(80, partial_allocated_namespace.available_segments.length)

      partial_allocated_namespace
    end

    def test_partial_allocated_namespace
      assert_equal('Banner Text 0', partial_allocated_namespace(4).get('banner_text'))
      assert_equal('Banner Text 1', partial_allocated_namespace(5).get('banner_text'))
    end

    def fully_allocated_namespace(userid)
      fully_allocated_namespace = base_namespace(userid)
      fully_allocated_namespace.add_experiment('V1 small audience', V1, 20)
      fully_allocated_namespace.add_experiment('V1 large audience', V1, 60)
      fully_allocated_namespace.add_experiment('V2 small audience', V2, 20)

      assert_equal(100, fully_allocated_namespace.segment_allocations.length)
      assert_equal(0, fully_allocated_namespace.available_segments.length)

      fully_allocated_namespace
    end

    def test_fully_allocated_namespace
      assert_equal('Banner Text 1', fully_allocated_namespace(6).get('banner_text'))
      assert_equal('Banner Text 2', fully_allocated_namespace(7).get('banner_text'))
      assert_equal('Banner Text 3', fully_allocated_namespace(8).get('banner_text'))
      assert_equal('Banner Text 4', fully_allocated_namespace(9).get('banner_text'))
    end

    def test_remove_experiments
      ns = fully_allocated_namespace(10)

      assert_equal(100, ns.segment_allocations.length)
      assert_equal(0, ns.available_segments.length)

      ns.remove_experiment('V1 small audience')

      assert_equal(80, ns.segment_allocations.length)
      assert_equal(20, ns.available_segments.length)
    end
  end
end
