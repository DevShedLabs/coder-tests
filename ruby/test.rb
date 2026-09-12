#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'

TASK_STATUSES = %i[pending running complete].freeze

Task = Data.define(:id, :title, :status) do
  def open?
    status != :complete
  end

  def to_h
    { id:, title:, status: status.to_s, open: open? }
  end
end

# Stores tasks and provides enumerable queries over their statuses.
class TaskBoard
  include Enumerable

  def initialize(tasks = [])
    @tasks = tasks.dup
  end

  def add(task)
    raise ArgumentError, 'invalid status' unless TASK_STATUSES.include?(task.status)

    @tasks << task
    self
  end

  def each(&)
    @tasks.each(&)
  end

  def open_tasks
    filter(&:open?)
  end

  def summary
    tally = each_with_object(Hash.new(0)) { |task, counts| counts[task.status] += 1 }
    { total: count, open: open_tasks.count, by_status: tally }
  end
end

def parse_task(json)
  data = JSON.parse(json, symbolize_names: true)
  Task.new(data.fetch(:id), data.fetch(:title), data.fetch(:status).to_sym)
rescue JSON::ParserError, KeyError, TypeError => e
  warn "Could not parse task: #{e.message}"
  nil
end

def with_timing(label)
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = yield
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
  puts format('%<label>s completed in %<elapsed>.3fms', label:, elapsed: elapsed * 1000)
  result
ensure
  puts "timing scope closed for #{label}"
end

if $PROGRAM_NAME == __FILE__
  board = TaskBoard.new
  board
    .add(Task.new(1, 'parse input', :complete))
    .add(Task.new(2, 'compile project', :running))
    .add(Task.new(3, 'run tests', :pending))

  with_timing('open task query') do
    board.open_tasks.each { |task| puts "##{task.id}: #{task.title} (#{task.status})" }
  end

  puts JSON.pretty_generate(board.summary)
  puts JSON.generate(board.first.to_h)
  puts "tags: #{Set.new(%w[ruby editor syntax]).to_a.join(', ')}"

  parsed = parse_task('{"id": 4, "title": "ship feature", "status": "pending"}')
  puts "parsed: #{parsed.title}" if parsed
end
