module Query

  # Combinations are a number of Combination-s.
  #
  # They are, in effect, the core of an allocation.
  #
  class Combinations

    attr_reader :type, :combinations

    delegate :empty?, :to => :@combinations

    def initialize type, combinations = []
      @type         = type # TODO Remove.
      @combinations = combinations
    end

    def hash
      @combinations.hash
    end

    # Uses user specific weights to calculate a score for the combinations.
    #
    def calculate_score weights
      @score ||= sum_score
      @score + add_score(weights) # TODO Ok to just cache the weights?
    end
    def sum_score
      @combinations.sum &:weight
    end
    def add_score weights
      weights.score @combinations
    end

    # Gets all ids for the allocations.
    #
    # Sorts the ids by size and & through them in the following order (sizes):
    # 0. [100_000, 400, 30, 2]
    # 1. [2, 30, 400, 100_000]
    # 2. (100_000 & (400 & (30 & 2))) # => result
    #
    # Returns the ids. Also sets the count.
    #
    # Note: Uses a C-optimized intersection routine for speed and memory efficiency.
    #
    def ids
      return [] if @combinations.empty?

      # Get the ids for each combination.
      #
      id_arrays = @combinations.inject([]) do |total, combination|
        total << combination.ids
      end

      # Order by smallest size first such that the intersect can be performed faster.
      #
      # TODO Move into the memory_efficient_intersect such that
      #      this precondition for a fast algorithm is always given.
      #
      id_arrays.sort! { |this_array, that_array| this_array.size <=> that_array.size }

      # Call the optimized C algorithm.
      #
      Performant::Array.memory_efficient_intersect id_arrays
    end

    #
    #
    def pack_into_allocation
      allocation = Allocation.new self
      allocation.result_type = @type.result_type # TODO Rewrite.
      allocation
    end

    # Filters the tokens and identifiers such that only identifiers
    # that are passed in, remain, including their tokens.
    #
    # Note: This method is not totally independent of the calculate_ids one.
    #       Since identifiers are only nullified, we need to not include the
    #       ids that have an associated identifier that is nil.
    #
    def keep identifiers = []
      # TODO Rewrite to use the category!!!
      #
      @combinations.reject! { |combination| !combination.in?(identifiers) }
    end

    # Filters the tokens and identifiers such that identifiers
    # that are passed in, are removed, including their tokens.
    #
    # Note: This method is not totally independent of the calculate_ids one.
    #       Since identifiers are only nullified, we need to not include the
    #       ids that have an associated identifier that is nil.
    #
    def remove identifiers = []
      # TODO Rewrite to use the category!!!
      #
      @combinations.reject! { |combination| combination.in?(identifiers) }
    end

    #
    #
    def to_result
      @combinations.map &:to_result
    end

  end

end