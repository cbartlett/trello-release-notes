This simple script generates a Markdown-compliant text list with links each card in a given Trello list.

At Assembled Brands, we use this to generate release notes which we paste into Slack. Then we archive all the cards in the list and start off a new week.

## Requirements

* Ruby
* Bundler

## Environment Variables

Specify several environment variables on the command line when running this:

Two Trello keys you can get by following the [Ruby Trello gem README](https://github.com/jeremytregunna/ruby-trello) instructions:

* `TRELLO_DEVELOPER_PUBLIC_KEY`
* `TRELLO_MEMBER_TOKEN`

And two keys to specify the Trello board and list:

* `BOARD_ID` You can grab this from the URL of your board. Looks something like `Xq0l01mR`.
* `LIST_NAME` This is just the name of the list you want to pull the cards from.

## Labels

In our organization, we label some cards with specific labels to indicate certain attributes.
For example, if the request was a regression or in response to a user support request.
Therefore, this script groups the cards by the first (and likely only in our case) label and
uses that as a simple headline. Your usage may vary. It's open source so fork and edit as you
please.

## License

Copyright (c) 2016 Assembled Brands.  Distributed under the terms of the MIT License.
