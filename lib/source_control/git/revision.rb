module SourceControl
  class Git
    class Revision < AbstractRevision

      attr_reader :number, :author, :time 

      def initialize(number, author, time)
        @number, @author, @time = number, author, time
      end

      def ==(other)
        other.is_a?(Git::Revision) && number == other.number
      end
      
      def to_s
        "commit #{@number}\nauthor #{@author} #{@time.to_i} +0500\n    o hai, iz hax"
      end
    end
  end
end