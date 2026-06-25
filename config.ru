# frozen_string_literal: true

# Rack entry point. Used in dev (`rackup`/`puma`) and on AWS.
require_relative "app"

run YnotFitness
