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

total_votes = 0

proposals = doc.css('.proposal').map do |proposal|
  title    = proposal.css('.title a').first.content
  abstract = proposal.css('.abstract').children.first.content
  votes    = proposal.css('.actions').children.last.content.split.last.to_i

  total_votes += votes

  Proposal.new(title, abstract, votes)
end

proposals.sort.each do |proposal|
  print Color.red, "(#{proposal.votes}) "

  if proposal.title =~ /Impressive Ruby Productivity with Vim and Tmux/
    print Color.yellow, Color.bold
  else
    print Color.blue
  end

  print proposal.title, Color.clear, "\n", proposal.abstract, "\n"
end

print Color.green, "#{proposals.size} proposals, #{total_votes} votes."
print Color.clear, "\n"
