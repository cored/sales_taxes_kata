# Problem Statement

This problem requires some kind of input. You are free to implement any mechanism for feeding the input into your solution. You should provide sufficient evidence that your solution is complete by, as a minimum, indicating that it works correctly against the supplied test data.

Basic sales tax is applicable at a rate of 10% on all goods, except books, food, and medical products that are exempt. Import duty is an additional sales tax applicable on all imported goods at a rate of 5%, with no exemptions.

When I purchase items I receive a receipt which lists the name of all the items and their price (including tax), finishing with the total cost of the items, and the total amounts of sales taxes paid. The rounding rules for sales tax are that for a tax rate of n%, a shelf price of p contains (np/100 rounded up to the nearest 0.05) amount of sales tax.

## Provided Inputs

### input 1:

2 book at 12.49
1 music CD at 14.99
1 chocolate bar at 0.85

### Input 2:

1 imported box of chocolates at 10.00
1 imported bottle of perfume at 47.50

### Input 3:

1 imported bottle of perfume at 27.99
1 bottle of perfume at 18.99
1 packet of headache pills at 9.75
3 imported boxes of chocolates at 11.25


# Setup

* Dependencies installation
  * `bundle install`
* Running the application
  * `bin/subscribe`

# Development

The application is divided by components suggested by the requirements.

The core logic is handle by the two main concepts:

`Subscribe::Line` - Handles parsing of line attributes
`Subscribe::SalesTaxes` - Handles calculation of taxes

Display logic is handle by `Subscribe::Receipt`, however, this logic does not represent most of the complexity within the system.

## Implementation details

The approach taken was towards maintaining a good enough amount of extensibility without compromising comprehension, that being said if the need to add a new tax is part of future requirements then the implementation within `Subscribe::SalesTaxes` will need some refactoring in order to make it open for extension.

## Trade offs

At the moment there's a precision bug which I was not able to identify and that's the reason why we are losing 0.05 cents when the sales includes `3 box of chocolates`.

I didn't spend too much time trying to figure out what is the problem due to time constraints.

