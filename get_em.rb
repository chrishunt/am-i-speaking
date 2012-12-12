require 'nokogiri'
require 'open-uri'

class Color
  require 'term/ansicolor'
  extend Term::ANSIColor
end

Proposal = Struct.new(:title, :abstract, :votes) do
  def <=>(other)
    votes <=> other.votes
  end
end

doc = Nokogiri::HTML(open('http://larubyconf.com/proposals'))

proposals = doc.css('.proposal').map do |proposal|
  title    = proposal.css('.title a').first.content
  abstract = proposal.css('.abstract').children.first.content
  votes    = proposal.css('.actions').children.last.content.split.last.to_i

  Proposal.new(title, abstract, votes)
end

proposals.sort.each do |proposal|
  print Color.red, "(#{proposal.votes}) "
  print Color.yellow, proposal.title, "\n"
  print Color.clear, proposal.abstract, "\n"
end

print Color.green, "#{proposals.size} total proposals", Color.clear, "\n"
