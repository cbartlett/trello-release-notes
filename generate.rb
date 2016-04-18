#!/usr/bin/env ruby

require 'humantime'
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

  def bullet(done_list, in_progress_list=nil)
    total = lifespan(done_list).floor
    active = active_lifespan(done_list, in_progress_list).floor
    total_label = total > 0 ? HumanTime.output(total) : nil
    active_label =  active > 0 ? HumanTime.output(active) : nil
    if active_label && total_label != active_label
      "* #{link} (#{total_label}, active #{active_label})"
    elsif total_label
      "* #{link} (#{total_label})"
    else
      "* #{link}"
    end
  end

  def cached_actions
    @cached_actions ||= actions
  end

  def created_at
    cached_actions.map(&:date).min
  end

  def last_moved_at
    cached_actions
      .select { |a| a if a.type == 'createCard' || (a.type == 'updateCard' && a.data['listAfter']) }
      .map(&:date)
      .max
  end

  def dates_appeared_in(list)
    cached_actions
      .select { |a|
        a if (a.type == 'createCard' && a.data['list']['id'] == list.id) \
        || (a.type == 'updateCard' && (a.data['listAfter'] || a.data['list'] || {})['id'] == list.id)
      }
      .map(&:date)
  end

  def first_appeared_in(list)
    dates_appeared_in(list).min
  end

  def last_appeared_in(list)
    dates_appeared_in(list).max
  end

  def lifespan(done_list)
    last_appeared_in(done_list) - created_at
  end

  def active_lifespan(done_list, in_progress_list)
    starting = (first_appeared_in(in_progress_list) || created_at)
    ending = last_appeared_in(done_list)
    ending - starting
  end
end

class Generator
  BOARD_ID = ENV['BOARD_ID']
  LIST_NAME = ENV['LIST_NAME']
  IN_PROGRESS_LIST_NAME = ENV['IN_PROGRESS_LIST_NAME']

  def lists
    @lists ||= Trello::Board.find(BOARD_ID).lists
  end

  def list
    lists.find { |l| l.name == LIST_NAME }
  end

  def in_progress_list
    lists.find { |l| l.name == IN_PROGRESS_LIST_NAME }
  end

  def cards
    list.cards.map { |c| Card.new(c) }.sort_by(&:created_at)
  end

  def groups
    cards.group_by(&:primary_label)
  end

  def output
    puts "Here's a list of all the work deployed in the last week:"
    groups.each do |headline, cards|
      puts "## #{headline || 'New Features & Changes'}:"
      puts cards.map { |c| c.bullet(list, in_progress_list) }
    end
    puts "_This list was automatically generated. Contact #{ENV['SLACK_NAME'] || '@cbartlett'} for questions or comments._"
  end
end

Generator.new.output
