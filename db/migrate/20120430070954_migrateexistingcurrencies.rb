#coding: utf-8
class Migrateexistingcurrencies < ActiveRecord::Migration
  def up
     Currency.create(name: "Us Dollar", symbol: "$", country: "USA", currency_code: "USD", active: 1, position: 1,currency_abbreviation:"US" )
     Currency.create(name: "Singapure Dollar", symbol: "$", country: "SG", currency_code: "SGD", active: 1, position: 2,currency_abbreviation:"SG" )
     Currency.create(name: "Hong Kong Dollar", symbol: "$", country: "HK", currency_code: "HKD", active: 1, position:3,currency_abbreviation:"HK" )
     Currency.create(name: "UK Pound", symbol: "£", country: "UK", currency_code: "GBP", active: 1, position: 4,currency_abbreviation:"GB" )
     Currency.create(name: "Malaysian ringgits", symbol: "$", country: "MAL", currency_code: "MYR", active: 1, position: 5,currency_abbreviation:"RM" )
     Currency.create(name: "Aus Dollar", symbol: "$", country: "AU", currency_code: "AUD", active: 1, position: 6,currency_abbreviation:"A" )
  end
end
