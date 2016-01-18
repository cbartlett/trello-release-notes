#!/usr/bin/env ruby

require 'trello'
PUBLIC_KEY = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
TOKEN = ENV['TRELLO_MEMBER_TOKEN']

Trello.configure do |config|
  config.developer_public_key = PUBLIC_KEY
  config.member_token = TOKEN
end

class Card < SimpleDelegator
  def primary_label
    @primary_label ||= labels.first.try(:name)
  end

  def link
    @link ||= "[#{name}](#{short_url})"
  end

  def bullet
    "* #{link}"
  end
end

class Generator
  BOARD_ID = ENV['BOARD_ID']
  LIST_NAME = ENV['LIST_NAME']

  def list
    Trello::Board.find(BOARD_ID).lists.find {|l| l.name == LIST_NAME }
  end

  def cards
    list.cards.map {|c| Card.new(c) }
  end

  def groups
    cards.group_by(&:primary_label)
  end

  def output
    puts "Here's a list of all the work deployed in the last week:"
    groups.each do |headline,cards|
      puts "## #{headline}" if headline
      puts cards.map(&:bullet)
    end
    puts "_This list was automatically generated. Contact @cbartlett for questions or comments._"
  end
end

Generator.new.output
