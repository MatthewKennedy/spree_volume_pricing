# Spree Volume Pricing With Multiple Currency Support

[![Build Status](https://travis-ci.org/MatthewKennedy/spree_volume_pricing.svg?branch=master)](https://travis-ci.org/MatthewKennedy/spree_volume_pricing)

Volume Pricing is an extension to Spree (a complete open source commerce solution for Ruby on Rails) that uses predefined ranges of quantities to determine the price for a particular product variant. For instance, this allows you to set a price for quantities between 1-10, another price for quantities between (10-100) and another for quantities of 100 or more.  If no volume price is defined for a variant, then the standard price is used.

## Multiple Currency Support
This fork of the spree_volume_pricing extension adds multiple currency support by reducing the complexity of having three different discount types. This version of the extension only lets the user create `price based` tables for different quantities in different currencies.

Each VolumePrice contains the following values:

1. **Variant:** Each VolumePrice is associated with a _Variant_, which is used to link products to particular prices.
1. **Name:** The human readable representation of the quantity range (Ex. 10-100).  (Optional)
1. **Range:** The quantity range for which the price is valid (See Below for Examples of Valid Ranges.)
1. **Amount:** The price of the product if the line item quantity falls within the specified range.
1. **Position:** Integer value for `acts_as_list` (Helps keep the volume prices in a defined order.)
1. **Currency:** The store current currency that the line item falls within.
1. **Role:** Use `None` for the discount to apply to all customers, or `wholesale` for wholesale only users.

---

## Installation

1. Add this extension to your Gemfile with these lines:

  ```ruby
  gem 'spree_multi_currency', github: 'spree-contrib/spree_multi_currency'
  gem 'spree_volume_pricing', github: 'matthewkennedy/spree_volume_pricing'
  ```

2. Install the gem using Bundler:
  ```ruby
  bundle install
  ```

3. Copy & run migrations
  ```ruby
  bundle exec rails g spree_multi_currency:install
  bundle exec rails g spree_volume_pricing:install
  ```

  4. Add to  ```vendor/assets/stylesheets/spree/frontend/all.css```
  ```ruby
  *= require spree/frontend/spree_volume_pricing
  ```

4. Restart your server

  If your server was running, restart it so that it can find the assets properly.


## Partials for use in Product view files
  ```ruby
  <%= render partial: 'spree/products/is_on_sale', locals: { product: @product } %>
  <%= render partial: 'spree/products/volume_pricing', locals: { product: @product } %>

  ```

---

## Ranges

Ranges are expressed as Strings and are similar to the format of a Range object in Ruby.  The lower number of the range is always inclusive.  If the range is defined with '..' then it also includes the upper end of the range.  If the range is defined with '...' then the upper end of the range is not inclusive.

Ranges can also be defined as "open ended."  Open ended ranges are defined with an integer followed by a '+' character.  These ranges are inclusive of the integer and any value higher then the integer.

All ranges need to be expressed as Strings and can include or exclude parentheses.  "(1..10)" and "1..10" are considered to be a valid range.

---

## Examples

Consider the following examples of volume prices:

       Variant                Name               Range        Amount         Position
       -------------------------------------------------------------------------------
       Rails T-Shirt          1-5                (1..5)       19.99          1
       Rails T-Shirt          6-9                (6...10)     18.99          2
       Rails T-Shirt          10 or more         (10+)        17.99          3

### Example 1

Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          1              19.99       19.99

### Example 2

Cart Contents:

       Product                Quantity       Price       Total
       ----------------------------------------------------------------
       Rails T-Shirt          5              19.99       99.95

### Example 3

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          6              18.99       113.94

### Example 4

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          10             17.99       179.90

### Example 5

Cart Contents:

      Product                Quantity       Price       Total
      ----------------------------------------------------------------
      Rails T-Shirt          20             17.99       359.80

---

## Contributing

See corresponding [contributing guidelines][1].

---

## License

Copyright (c) 2009-2015 [Spree Commerce][2] and [contributors][3], released under the [New BSD License][4]

[1]: https://github.com/spree-contrib/spree_volume_pricing/blob/master/CONTRIBUTING.md
[2]: https://github.com/spree
[3]: https://github.com/spree-contrib/spree_volume_pricing/graphs/contributors
[4]: https://github.com/spree-contrib/spree_volume_pricing/blob/master/LICENSE.md
