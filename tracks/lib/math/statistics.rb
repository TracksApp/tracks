=begin
= module Math::Statistics

== SYNOPSIS

  ----
     require "math/statistics"

     class Array
       include Math::Statistics
     end

     a = [-2,-1,1,2]
     p a.sum
     p a.avg
     p a.var
     p a.std
     p a.Min
     p a.Max
  ----

produces

  ----
     0.0
     0.0
     2.5
     1.58113883
     -2
     2
  ----

For hashes, 

  ----
     require "math/statistics"

     class Hash
       include Math::Statistics
       Hash::default_block = lambda{|i,j| j}
     end

     h = {'alice'=>-2, 'bob'=>-1, 'cris'=>1, 'diana'=>2}
     p h.sum
     p h.avg
     p h.var
     p h.std
     p h.Min
     p h.Max
  ----

produces

  ----
     0.0
     0.0
     2.5
     1.58113883
     -2
     2
  ----

== DESCRIPTION

(({Math::Statistics})) provides basic statistical methods, i.e., 
sum, average, variance, standard deviation, min and max. 
This module can be used after including to the target class. 
The target class must be Enumerable, more precisely, this module 
uses each, size, min, and max.  

== CLASS METHOD

: default_block= aProc

  Sets default block of the class.  This block will be used by the methods. 

: default_block

  Returns default block for class if defined.  Otherwise nil will be returnd. 

== METHOD

: default_block= aProc

  Sets default block of the object.  This block will be used by the methods. 
  Priority of the blocks is in the other: in-place given block, 
  object's default then class's default. 

: default_block

  Returns default block if defined.  Otherwise nil will be returnd. 

: sum
: sum{...}

  Returns sum.  When a block is given, summation is taken over the 
  each result of block evaluation.  The role of blocks in the below
  are same to this one. 

: average
: average{...}
: avg
: avg{...}

  Returns average.

: variance
: variance{...}
: var
: var{...}

  Returns variance. 

: standard_deviation
: standard_deviation{...}
: std
: std{...}

  Returns standard deviation. 

: Min
: Min{...}

  Returns minimum. 

: Max
: Max{...}

  Returns maximam. 

== AUTHORS

Gotoken

== HISTORY

 2001-02-28 created (gotoken#notwork.org)

=end

module Math
  module Statistics
    VERSION = "2001_02_18"

    def self.append_features(mod)
      unless mod < Enumerable
	raise TypeError, 
	  "`#{self}' can't be included non Enumerable (#{mod})"
      end

      def mod.default_block= (blk)
	self.const_set("STAT_BLOCK", blk)
      end

      def mod.default_block
	defined?(self::STAT_BLOCK) && self::STAT_BLOCK
      end

      super
    end

    def default_block
      @stat_block || type.default_block
    end

    def default_block=(blk)
      @stat_block = blk
    end

    def sum
      sum = 0.0
      if block_given?
	each{|i| sum += yield(i)}
      elsif default_block
	each{|i| sum += default_block[*i]}
      else
	each{|i| sum += i}
      end
      sum
    end

    def average(&blk)
      sum(&blk)/size
    end

    def variance(&blk)
      sum2 = if block_given?
	       sum{|i| j=yield(i); j*j}
	     elsif default_block
	       sum{|i| j=default_block[*i]; j*j}
	     else
	       sum{|i| i**2}
	     end
      sum2/size - average(&blk)**2
    end

    def standard_deviation(&blk)
      Math::sqrt(variance(&blk))
    end

    def Min(&blk)
      if block_given?
	if min = find{|i| i}
	  min = yield(min)
	  each{|i|
	    j = yield(i)
	    min = j if min > j
	  }
	  min
	end
      elsif default_block
	if min = find{|i| i}
	  min = default_block[*min]
	  each{|i|
	    j = default_block[*i]
	    min = j if min > j
	  }
	  min
	end
      else
	min()
      end
    end

    def Max(&blk)
      if block_given?
	if max = find{|i| i}
	  max = yield(max)
	  each{|i|
	    j = yield(i)
	    max = j if max < j
	  }
	  max
	end
      elsif default_block
	if max = find{|i| i}
	  max = default_block[*max]
	  each{|i|
	    j = default_block[*i]
	    max = j if max > j
	  }
	  max
	end
      else
	max()
      end
    end

    alias avg average
    alias std standard_deviation
    alias var variance
  end
end
