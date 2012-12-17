require 'nokogiri'
require 'open-uri'

class AmISpeaking
  attr_reader :my_talk

  class Color
    require 'term/ansicolor'
    extend Term::ANSIColor
  end

  Proposal = Struct.new(:title, :abstract, :votes) do
    def <=>(other)
      votes <=> other.votes
    end
  end

  def initialize(my_talk)
    @my_talk = (my_talk.empty? ? default_talk : my_talk).downcase
  end

  def run
    print_proposals
    print_summary
  end

  private

  def html
    @html ||= Nokogiri::HTML(open('http://larubyconf.com/proposals'))
  end

  def proposals
    @proposals ||= html.css('.proposal').map do |proposal|
      title    = proposal.css('.title a').first.content
      abstract = proposal.css('.abstract').children.first.content
      votes    = proposal.css('.actions').children.last.content.split.last.to_i

      Proposal.new(title, abstract, votes)
    end
  end

  def total_votes
    @total_votes ||= proposals.inject(0) do |sum, proposal|
      sum += proposal.votes
    end
  end

  def default_talk
    "Impressive Ruby Productivity with Vim and Tmux"
  end

  def print_summary
    print Color.green, "#{proposals.size} proposals, #{total_votes} votes.\n"
    print Color.clear
  end

  def print_proposals
    proposals.sort.each_with_index do |proposal, index|
      print Color.blue
      print "%02d" % (proposals.size - index)
      print " "

      print Color.red, "("
      print "%02d" % proposal.votes
      print ") ", Color.clear

      if proposal.title.downcase == my_talk
        print Color.yellow, Color.bold
      end

      print proposal.title, Color.clear, "\n"
    end
  end
end

my_talk = ARGV.join(' ')
AmISpeaking.new(my_talk).run
