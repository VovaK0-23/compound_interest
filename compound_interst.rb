require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby '>= 2.4.0'
  gem 'tty-prompt'
  gem 'i18n'
  gem 'compound_interest'
end

require 'i18n'
require 'tty-prompt'
require 'compound_interest'

I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']
I18n.default_locale = :en
prompt = TTY::Prompt.new
compound_interest = CompoundInterest::Calculation

def periodicity(period)
  case period
  when I18n.t(:day)
    period = 365.0
  when I18n.t(:week)
    period = 365.0 / 7.0
  when I18n.t(:month)
    period = 12.0
  when I18n.t(:year)
    period = 1.0
  end
end

def select_periodicity(periodicity)
  prompt = TTY::Prompt.new
  prompt.select((periodicity),
    [I18n.t(:day), I18n.t(:week),
      I18n.t(:month), I18n.t(:year)])
end

language = prompt.select('Choose language?', %w[English Russian])
I18n.locale = :ru if language == 'Russian'
puts(I18n.t(:lang))

puts(I18n.t(:init_payment))
initial_payment = gets.chomp.to_f
puts(I18n.t(:term))
term = gets.chomp.to_f
term_month_or_year = prompt.select(I18n.t(:months_or_years),
  [I18n.t(:months), I18n.t(:years)])
puts(I18n.t(:nominal_rate))
interest_rate = gets.chomp.to_f
capitalization_periodicity = select_periodicity(I18n.t(:capitalization_periodicity))
capitalization_periodicity = periodicity(capitalization_periodicity)
term /= 12 if term_month_or_year == I18n.t(:months)

puts(I18n.t(:payment))
payment = gets.chomp.to_f 
payment_periodicity = 0
if payment > 0
  payment_periodicity = select_periodicity(I18n.t(:payment_periodicity))
  payment_periodicity = periodicity(payment_periodicity)
end

hh = {
  initial_payment: initial_payment,
  term: term,
  interest_rate: interest_rate,
  capitalization_periodicity: capitalization_periodicity,
  payment: payment,
  payment_periodicity: payment_periodicity
}
puts(compound_interest.calculate(hh).round(3))

