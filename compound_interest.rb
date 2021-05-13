# frozen_string_literal: true

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

I18n.load_path << Dir["#{File.expand_path('locales')}/*.yml"]
I18n.default_locale = :en
@prompt = TTY::Prompt.new
compound_interest = CompoundInterest::Calculation

def select_periodicity(periodicity)
  day = I18n.t(:day)
  week = I18n.t(:week)
  month = I18n.t(:month)
  year = I18n.t(:year)
  @prompt.select(periodicity, { day => 365.0, week => 365.0 / 7.0, month => 12.0, year => 1.0 })
end

def get_number(question)
  @prompt.ask(question) do |q|
    q.required true
    q.modify :remove
    q.convert :float
    q.in 1..Float::INFINITY if question != I18n.t(:nominal_rate) && question != I18n.t(:payment)
    q.messages[:range?] = I18n.t(:positive_number)
    q.messages[:required?] = I18n.t(:required)
    q.messages[:float?] = I18n.t(:must_be_number)
  end
end

language = @prompt.select('Choose language?', %w[English Russian])
I18n.locale = :ru if language == 'Russian'
puts(I18n.t(:lang))

initial_payment = get_number(I18n.t(:init_payment))
term = get_number(I18n.t(:term))
term_month_or_year = @prompt.select(I18n.t(:months_or_years),
                                    [I18n.t(:months), I18n.t(:years)])
interest_rate = get_number(I18n.t(:nominal_rate))
capitalization_periodicity = select_periodicity(I18n.t(:capitalization_periodicity))
term /= 12 if term_month_or_year == I18n.t(:months)

payment = get_number(I18n.t(:payment))
payment_periodicity = select_periodicity(I18n.t(:payment_periodicity)) if payment.positive?

hh = {
  initial_payment: initial_payment,
  term: term,
  interest_rate: interest_rate,
  capitalization_periodicity: capitalization_periodicity,
  payment: payment,
  payment_periodicity: payment_periodicity
}
puts(compound_interest.calculate(hh).round(3))
