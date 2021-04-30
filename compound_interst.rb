require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby '>= 2.4.0'
  gem 'tty-prompt'
  gem 'i18n'
end

require 'i18n'
require 'tty-prompt'

I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']
I18n.default_locale = :en
prompt = TTY::Prompt.new

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

language = prompt.select('Choose language?', %w[English Russian])
I18n.locale = :ru if language == 'Russian'
p(I18n.t(:lang))

p(I18n.t(:init_payment))
initial_payment = gets.chomp.to_f
p(I18n.t(:term))
term = gets.chomp.to_f
term_month_or_year = prompt.select(I18n.t(:months_or_years), [I18n.t(:months), I18n.t(:years)])
p(I18n.t(:nominal_rate))
interest_rate = gets.chomp.to_f / 100.0
capitalization_periodicity = prompt.select(I18n.t(:capitalization_periodicity),
                                           [I18n.t(:day), I18n.t(:week),
                                             I18n.t(:month), I18n.t(:year)])
capitalization_periodicity = periodicity(capitalization_periodicity)
term = 12 if term_month_or_year == I18n.t(:months)

result = initial_payment * (1.0 + interest_rate / capitalization_periodicity) **
  (term * capitalization_periodicity)
p(I18n.t(:payment))
payment = gets.chomp.to_f
if payment > 0
  payment_periodicity = prompt.select(I18n.t(:payment_periodicity),
                                      [I18n.t(:day), I18n.t(:week),
                                        I18n.t(:month), I18n.t(:year)])
  payment_periodicity = periodicity(payment_periodicity)
  arr = []
  times = (payment_periodicity * term).to_i
  (1..times).each do |i|
    sum_one_payment = payment * (1.0 + interest_rate / capitalization_periodicity) **
      ((term * capitalization_periodicity) -
       ((capitalization_periodicity / payment_periodicity) * i))
    arr << sum_one_payment
  end
  result = result + arr.sum - payment
end
p(result.round(3))
