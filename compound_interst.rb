# ruby version >=2.4.0
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  ruby ">= 2.4.0"
  gem 'tty-prompt'
  gem 'i18n'
end

require 'i18n'
require 'tty-prompt'

I18n.load_path << Dir[File.expand_path('locales') + '/*.yml']
I18n.default_locale = :en
prompt = TTY::Prompt.new

language = prompt.select('Choose your language?', %w[English Russian])
I18n.locale = :ru if language == 'Russian'
p(I18n.t(:lang))

p("Начальная сумма вложенных средств")
initial_payment = gets.chomp.to_f
p("Период на который положен депозит")
time = gets.chomp.to_f
time_month_or_year = prompt.select("лет или месяцев?", %w(Лет Месяцев))
p("Годовая процентная ставка")
interest_rate = gets.chomp.to_f / 100.0
capitalization_periodicity = prompt.select("Выплаты процентов каждый/каждую",
                                %w(День Неделю Месяц Год))
if time_month_or_year == "Месяцев"
  time = time / 12
end
case capitalization_periodicity
when "День"
  capitalization_periodicity = 365
when "Неделю"
  capitalization_periodicity = 365 / 7
when "Месяц"
  capitalization_periodicity = 12
when "Год"
  capitalization_periodicity = 1
end

result = initial_payment * (1.0 + interest_rate / capitalization_periodicity ) **
                                (time * capitalization_periodicity)
p("payment")
payment = gets.chomp.to_f
if payment > 0
  p("payment periodicality")
  payment_periodicity = gets.chomp.to_f
  arr = []
  times = (payment_periodicity * time).to_i
  for i in 1..times
    sum_one_payment = payment * (1.0 + interest_rate / capitalization_periodicity ) **
                            ((time * capitalization_periodicity) - ((capitalization_periodicity / payment_periodicity)*i))
    arr << sum_one_payment
  end
  result = result + arr.sum - payment
end
p(result.round(3))

